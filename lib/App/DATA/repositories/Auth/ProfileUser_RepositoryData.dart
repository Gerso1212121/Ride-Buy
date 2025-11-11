import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:ezride/App/DATA/models/Auth/AuthProfilePendingUser_Model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/REGISTER_PENDING_user_entity.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import '../../../DOMAIN/repositories/Auth/ProfileUser_RepositoryDomain.dart';

class ProfileUserRepositoryData implements ProfileUserRepositoryDomain {
  static const _sessionKey = 'user_session';

  final Dio dio;

  ProfileUserRepositoryData({required this.dio});

  // ------------------------------
  // UTILIDADES
  // ------------------------------
  String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  String _generateOTP() => (100000 + Random().nextInt(900000)).toString();

  // ------------------------------
  // REGISTRO PENDIENTE
  // ------------------------------
  @override
  Future<RegisterPending> registerPendingUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🔄 INICIANDO REGISTRO PENDIENTE');
      print('📧 Email recibido: $email');
      print('🔐 Password length: ${password.length}');

      // 🔒 Verifica si ya existe como usuario verificado CON TIMEOUT
      const checkUserSql =
          'SELECT COUNT(*) AS count FROM profiles WHERE email = @e';
      final userCheckResult = await RenderDbClient.queryWithTimeout(
        checkUserSql,
        parameters: {'e': email},
        timeout: Duration(seconds: 10),
      );

      final userExists = (userCheckResult.first['count'] ?? 0) > 0;
      if (userExists) {
        print('❌ Usuario ya existe en profiles: $email');
        throw Exception('El correo ya está registrado.');
      }

      // 🔍 Verificar si ya está en "register_pending" CON TIMEOUT
      const sqlCheckPending = 'SELECT * FROM register_pending WHERE email = @e';
      final existingPending = await RenderDbClient.queryWithTimeout(
        sqlCheckPending,
        parameters: {'e': email},
        timeout: Duration(seconds: 10),
      );

      print('📊 Usuario en pending: ${existingPending.isNotEmpty}');

      // ✅ USAR UTC CONSISTENTEMENTE
      final now = DateTime.now().toUtc();
      final otp = _generateOTP();
      final hashedPass = _hashPassword(password);

      // ✅ Crear expiración en UTC
      final otpExpiresAt = now.add(const Duration(minutes: 10));

      print('⏰ OTP generado: $otp');
      print('⏰ Hora creación (UTC): $now');
      print('⏰ Hora expiración (UTC): $otpExpiresAt');

      // 🌀 Si ya existe en pending, actualiza OTP y reenvía
      if (existingPending.isNotEmpty) {
        print('🔁 Actualizando OTP existente para: $email');

        const sqlUpdate = '''
        UPDATE register_pending
        SET otp_code = @otp_code,
            otp_created_at = @otp_created_at,
            otp_expires_at = @otp_expires_at,
            passwd = @passwd,
            updated_at = @updated_at
        WHERE email = @email
      ''';

        await RenderDbClient.queryWithTimeout(
          sqlUpdate,
          parameters: {
            'otp_code': otp,
            'otp_created_at': now,
            'otp_expires_at': otpExpiresAt,
            'passwd': hashedPass,
            'updated_at': now,
            'email': email,
          },
          timeout: Duration(seconds: 10),
        );

        await _sendOTPEmail(email, otp);
        print('✅ OTP actualizado y reenviado a $email');

        final updatedModel = AuthRegisterPendingModel.fromMap({
          ...existingPending.first,
          'otp_code': otp,
          'otp_created_at': now,
          'otp_expires_at': otpExpiresAt,
          'updated_at': now,
        });

        print('📦 Modelo actualizado creado: ${updatedModel.id}');
        return updatedModel.toEntity();
      }

      // 🆕 Si no existe en pending, crear nuevo registro
      print('🆕 Creando nuevo registro pendiente para: $email');
      final newId = const Uuid().v4();

      final pendingModel = AuthRegisterPendingModel(
        id: newId,
        email: email,
        passwd: hashedPass,
        otpCode: otp,
        otpCreatedAt: now,
        otpExpiresAt: otpExpiresAt,
        verified: false,
        createdAt: now,
        updatedAt: now,
      );

      print('📋 Insertando en base de datos...');
      const sqlInsert = '''
      INSERT INTO register_pending (
        id, email, passwd, otp_code, otp_created_at, otp_expires_at, verified, created_at, updated_at
      ) VALUES (
        @id, @email, @passwd, @otp_code, @otp_created_at, @otp_expires_at, @verified, @created_at, @updated_at
      )
    ''';

      await RenderDbClient.queryWithTimeout(
        sqlInsert,
        parameters: pendingModel.toMap(),
        timeout: Duration(seconds: 10),
      );

      print('✅ Registro insertado en base de datos');

      await _sendOTPEmail(email, otp);
      print('✅ OTP enviado por primera vez a $email');
      print('🎉 Registro pendiente completado exitosamente');

      return pendingModel.toEntity();
    } catch (e) {
      print('❌ Error en registerPendingUser: $e');
      print('🔍 Stack trace: ${e.toString()}');
      rethrow;
    }
  }

  // ------------------------------
  // VERIFICAR OTP Y MIGRAR
  // ------------------------------
  @override
  Future<Profile?> verifyOtp({
    required String email,
    required String inputOtp,
  }) async {
    const maxAttempts = 5; // 🔒 límite de intentos
    final prefs = await SharedPreferences.getInstance();
    final attemptKey = 'otp_attempts_$email';

    try {
      // Leer intentos previos desde memoria
      final currentAttempts = prefs.getInt(attemptKey) ?? 0;
      if (currentAttempts >= maxAttempts) {
        await prefs.remove(attemptKey);
        await _deletePending(email);
        throw Exception('OTP expirado por intentos fallidos.');
      }

      // Buscar en DB
      const sql = 'SELECT * FROM register_pending WHERE email = @email';
      final result =
          await RenderDbClient.query(sql, parameters: {'email': email});
      if (result.isEmpty) throw Exception('Usuario no encontrado');

      final pending = AuthRegisterPendingModel.fromMap(result.first);

      // Validar expiración
      final now = DateTime.now().toUtc();
      final expiresAt = pending.otpExpiresAt.toUtc();

      print('🕒 now=$now | expiresAt=$expiresAt');

      if (now.isAfter(expiresAt)) {
        await prefs.remove(attemptKey);
        await _deletePending(email);
        throw Exception('OTP expirado.');
      }

      // Validar OTP
      if (pending.otpCode != inputOtp) {
        await prefs.setInt(attemptKey, currentAttempts + 1);
        final remaining = maxAttempts - (currentAttempts + 1);
        throw Exception('OTP inválido. Te quedan $remaining intentos.');
      }

      // OTP correcto → limpiar intentos y migrar
      await prefs.remove(attemptKey);

      final profileModel = AuthProfilesUserModel.fromEntity(
        Profile(
          id: pending.id,
          role: UserRole.cliente,
          email: pending.email,
          passwd: pending.passwd,
          emailVerified: true,
          verificationStatus: VerificationStatus.pendiente,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );

      await RenderDbClient.runTransaction((ctx) async {
        const insertSql = '''
        INSERT INTO profiles (
          id, role, email, passwd, verification_status, email_verified, created_at, updated_at
        ) VALUES (
          @id, @role, @email, @passwd, @verification_status, @email_verified, @created_at, @updated_at
        )
      ''';
        await ctx.execute(Sql.named(insertSql),
            parameters: profileModel.toDbMap(minimal: true));

        const deleteSql = 'DELETE FROM register_pending WHERE email = @email';
        await ctx.execute(Sql.named(deleteSql), parameters: {'email': email});
      });

      return profileModel.toEntity();
    } catch (e) {
      print('❌ Error en verifyOtp: $e');
      rethrow;
    }
  }

  // ------------------------------
  // LOGIN
  // ------------------------------
  @override
  Future<Profile> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      const sql = 'SELECT * FROM profiles WHERE email = @email';
      final result =
          await RenderDbClient.query(sql, parameters: {'email': email});

      if (result.isEmpty) throw Exception('Usuario no encontrado.');

      final model = AuthProfilesUserModel.fromMap(result.first);

      // 🔒 Validar contraseña
      if (model.passwd != _hashPassword(password)) {
        throw Exception('Contraseña incorrecta.');
      }

      // ⚠️ Verificar estado de verificación
      if (model.verificationStatus != VerificationStatus.verificado) {
        // No lanzamos error, dejamos entrar pero lo mandamos a completar verificación
        return model.toEntity();
      }

      // 🟢 Generar token y guardar sesión local
      final updated = model.copyWith(
        token: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      return updated.toEntity();
    } catch (e) {
      print('❌ Error en loginUser: $e');
      rethrow;
    }
  }

  // ------------------------------
  // PERFIL
  // ------------------------------
  @override
  Future<Profile> getUserProfile({required String email}) async {
    const sql = 'SELECT * FROM profiles WHERE email = @email';
    final result =
        await RenderDbClient.query(sql, parameters: {'email': email});
    if (result.isEmpty) throw Exception('Usuario no encontrado');
    return AuthProfilesUserModel.fromMap(result.first).toEntity();
  }

  // ------------------------------
  // SESIÓN LOCAL
  // ------------------------------
  Future<void> _saveUserSession(AuthProfilesUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user.toMap()));
  }

  @override
  Future<AuthProfilesUserModel?> getLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_sessionKey);
    if (data == null) return null;
    return AuthProfilesUserModel.fromMap(jsonDecode(data));
  }

  @override
  Future<bool> logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ------------------------------
  // AUXILIARES
  // ------------------------------
  Future<bool> _userExists(String email) async {
    const sql = 'SELECT COUNT(*) AS count FROM profiles WHERE email = @e';
    try {
      final result = await RenderDbClient.queryWithTimeout(
        sql,
        parameters: {'e': email},
        timeout: Duration(seconds: 10),
      );
      return (result.first['count'] ?? 0) > 0;
    } on TimeoutException {
      print('⏰ Timeout verificando usuario existente: $email');
      // En caso de timeout, asumimos que el usuario no existe para permitir el registro
      return false;
    } catch (e) {
      print('❌ Error verificando usuario existente: $e');
      rethrow;
    }
  }

//ENVIO DE CORREO
  Future<void> _sendOTPEmail(String email, String otp) async {
    final apiKey = dotenv.env['SENDGRID_API_KEY'];
    final fromEmail =
        dotenv.env['MAIL_FROM_ADDRESS'] ?? 'noreply@carpinteriachavarria.com';
    final fromName = dotenv.env['MAIL_FROM_NAME'] ?? 'EZ RIDE';

    if (apiKey == null) {
      throw Exception('Falta la clave API de SendGrid');
    }

    final htmlContent = '''
  <!DOCTYPE html>
  <html lang="es">
  <head>
    <meta charset="UTF-8">
    <title>Verificación de cuenta - MAX EXPRESS</title>
    <style>
      body {
        font-family: 'Segoe UI', Arial, sans-serif;
        background-color: #f5f7fa;
        margin: 0;
        padding: 0;
      }
      .container {
        max-width: 520px;
        margin: 40px auto;
        background-color: #ffffff;
        border-radius: 12px;
        box-shadow: 0 4px 12px rgba(0,0,0,0.1);
        overflow: hidden;
      }
      .header {
        background-color: #007bff;
        color: white;
        text-align: center;
        padding: 20px;
      }
      .header h1 {
        margin: 0;
        font-size: 24px;
      }
      .content {
        padding: 30px;
        color: #333;
      }
      .otp-box {
        text-align: center;
        background-color: #f0f4ff;
        border: 1px dashed #007bff;
        padding: 15px;
        border-radius: 10px;
        margin: 20px 0;
      }
      .otp-code {
        font-size: 28px;
        font-weight: bold;
        color: #007bff;
      }
      .footer {
        background-color: #f1f1f1;
        text-align: center;
        padding: 15px;
        font-size: 12px;
        color: #777;
      }
    </style>
  </head>
  <body>
    <div class="container">
      <div class="header">
        <h1>MAX EXPRESS Rent a Car</h1>
      </div>
      <div class="content">
        <h2>Tu código de verificación</h2>
        <p>Hola 👋,</p>
        <p>Usa este código para verificar tu cuenta:</p>
        <div class="otp-box">
          <div class="otp-code">$otp</div>
        </div>
        <p>Este código expira en <b>10 minutos</b>.</p>
      </div>
      <div class="footer">
        © ${DateTime.now().year} MAX EXPRESS — Tu viaje comienza aquí 🚗
      </div>
    </div>
  </body>
  </html>
  ''';

    final data = {
      "personalizations": [
        {
          "to": [
            {"email": email}
          ],
          "subject": "Verificación de cuenta - MAX EXPRESS"
        }
      ],
      "from": {"email": fromEmail, "name": fromName},
      "content": [
        {"type": "text/html", "value": htmlContent}
      ]
    };

    final response = await Dio().post(
      'https://api.sendgrid.com/v3/mail/send',
      data: data,
      options: Options(
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (response.statusCode == 202) {
      print('✅ Correo enviado correctamente a $email');
    } else {
      print(
          '⚠️ Error al enviar correo: ${response.statusCode} - ${response.data}');
    }
  }

  Future<void> _deletePending(String email) async {
    const sql = 'DELETE FROM register_pending WHERE email = @email';
    await RenderDbClient.query(sql, parameters: {'email': email});
  }

  @override
  Future<void> updateUserProfile({
    required String id,
    required String displayName,
    required String phone,
    required String duiNumber,
    required String dateOfBirth,
    required String verificationStatus,
  }) async {
    try {
      // 1. Verificar si el DUI ya está asociado a otro perfil
      const checkDuiSql = '''
      SELECT COUNT(*) AS count 
      FROM profiles 
      WHERE dui_number = @dui_number AND id != @id
    ''';
      final result = await RenderDbClient.query(checkDuiSql, parameters: {
        'dui_number': duiNumber,
        'id': id,
      });

      final duiExists = result.first['count'] > 0;

      // Si el DUI ya está registrado en otro perfil, lanzar un error
      if (duiExists) {
        throw Exception('El DUI ya está registrado en otro perfil.');
      }

      // 2. Si el DUI no está duplicado, proceder con la actualización
      const sql = '''
      UPDATE profiles
      SET
        display_name = @display_name,
        phone = @phone,
        dui_number = @dui_number,
        date_of_birth = @date_of_birth,
        verification_status = @verification_status,
        updated_at = now()
      WHERE id = @id
    ''';

      await RenderDbClient.query(sql, parameters: {
        'id': id,
        'display_name': displayName,
        'phone': phone,
        'dui_number': duiNumber,
        'date_of_birth': dateOfBirth,
        'verification_status': verificationStatus,
      });

      print('✅ Perfil actualizado correctamente en la base de datos.');
    } catch (e) {
      print('❌ Error al actualizar el perfil: $e');
      rethrow;
    }
  }

  Future<void> updateFullProfile(Profile profile) async {
    const sql = '''
  UPDATE profiles
  SET
    role = @role,
    display_name = @display_name,
    phone = @phone,
    verification_status = @verification_status,
    email = @email,
    passwd = @passwd,
    dui_number = @dui_number,
    license_number = @license_number,
    date_of_birth = @date_of_birth,
    email_verified = @email_verified,
    updated_at = NOW()
  WHERE id = @id
  ''';

    await RenderDbClient.query(sql, parameters: {
      'id': profile.id,
      'role': profile.role.name,
      'display_name': profile.displayName,
      'phone': profile.phone,
      'verification_status': profile.verificationStatus.name,
      'email': profile.email,
      'passwd': profile.passwd,
      'dui_number': profile.duiNumber,
      'license_number': profile.licenseNumber,
      'date_of_birth': profile.dateOfBirth?.toIso8601String(),
      'email_verified': profile.emailVerified,
    });

    print("✅ Perfil completo actualizado en DB");
  }
}
