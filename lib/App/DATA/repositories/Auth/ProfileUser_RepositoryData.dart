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
      // Evitar duplicados
      if (await _userExists(email)) {
        throw Exception('El correo ya está registrado.');
      }

      final now = DateTime.now().toUtc();
      final newId = const Uuid().v4();
      final otp = _generateOTP();
      final hashedPass = _hashPassword(password);

      // Creamos el modelo temporal
      final pendingModel = AuthRegisterPendingModel(
        id: newId,
        email: email,
        passwd: hashedPass,
        otpCode: otp,
        otpCreatedAt: now,
        otpExpiresAt: now.add(const Duration(minutes: 10)),
        verified: false,
        createdAt: now,
        updatedAt: now,
      );

      // Guardamos en la tabla register_pending
      await RenderDbClient.runTransaction((ctx) async {
        const sql = '''
          INSERT INTO register_pending (
            id, email, passwd, otp_code, otp_created_at, otp_expires_at, verified, created_at, updated_at
          ) VALUES (
            @id, @email, @passwd, @otp_code, @otp_created_at, @otp_expires_at, @verified, @created_at, @updated_at
          )
        ''';
        await ctx.execute(Sql.named(sql), parameters: pendingModel.toMap());
      });

      // Enviar el OTP al correo
      await _sendOTPEmail(email, otp);

      return pendingModel.toEntity();
    } catch (e) {
      print('❌ Error en registerPendingUser: $e');
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
      if (model.passwd != _hashPassword(password)) {
        throw Exception('Contraseña incorrecta.');
      }

      final updated = model.copyWith(
        token: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await _saveUserSession(updated);
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
    final r1 = await RenderDbClient.query(sql, parameters: {'e': email});

    const sql2 =
        'SELECT COUNT(*) AS count FROM register_pending WHERE email = @e';
    final r2 = await RenderDbClient.query(sql2, parameters: {'e': email});

    return (r1.first['count'] ?? 0) > 0 || (r2.first['count'] ?? 0) > 0;
  }

  Future<void> _sendOTPEmail(String email, String otp) async {
    final smtpEmail = dotenv.env['SMTP_EMAIL'];
    final smtpPassword = dotenv.env['SMTP_PASSWORD'];
    if (smtpEmail == null || smtpPassword == null) {
      throw Exception('SMTP no configurado');
    }

    final smtpServer = gmail(smtpEmail, smtpPassword);
    final message = Message()
      ..from = Address(smtpEmail, 'EZRide')
      ..recipients.add(email)
      ..subject = 'RIDE&BUY OTP Verificacion'
      ..html = '''
<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8">
  <title>Verificación de cuenta - EZRide</title>
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
      letter-spacing: 1px;
    }
    .content {
      padding: 30px;
      color: #333;
    }
    .content h2 {
      font-size: 20px;
      margin-bottom: 10px;
      color: #007bff;
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
      letter-spacing: 4px;
      color: #007bff;
      user-select: all;
    }
    .copy-button {
      display: inline-block;
      margin-top: 10px;
      padding: 10px 18px;
      background-color: #007bff;
      color: white;
      border-radius: 6px;
      text-decoration: none;
      font-size: 14px;
      transition: background-color 0.3s;
    }
    .copy-button:hover {
      background-color: #0056b3;
    }
    .footer {
      background-color: #f1f1f1;
      text-align: center;
      padding: 15px;
      font-size: 12px;
      color: #777;
    }
    .car-icon {
      width: 40px;
      margin-bottom: 8px;
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <img class="car-icon" src="https://cdn-icons-png.flaticon.com/512/743/743922.png" alt="Car Icon">
      <h1>EZRide Rent a Car</h1>
    </div>

    <div class="content">
      <h2>Verifica tu cuenta</h2>
      <p>Hola 👋,</p>
      <p>Gracias por registrarte en <b>EZRide</b>. Para continuar con tu proceso de verificación y activar tu cuenta, usa el siguiente código:</p>

      <div class="otp-box">
        <div class="otp-code" id="otp">$otp</div>
        <a href="#" class="copy-button" onclick="navigator.clipboard.writeText('$otp'); alert('Código copiado'); return false;">📋 Copiar código</a>
      </div>

      <p>Este código expira en <b>10 minutos</b>. Si no solicitaste esta verificación, puedes ignorar este mensaje.</p>
    </div>

    <div class="footer">
      © ${DateTime.now().year} EZRide Rent a Car — Tu viaje comienza aquí 🚗
    </div>
  </div>
</body>
</html>
''';

    await send(message, smtpServer);
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
}) async {
  try {
    const sql = '''
      UPDATE profiles
      SET
        display_name = @display_name,
        phone = @phone,
        dui_number = @dui_number,
        date_of_birth = @date_of_birth,
        updated_at = now()
      WHERE id = @id
    ''';

    await RenderDbClient.query(sql, parameters: {
      'id': id,
      'display_name': displayName,
      'phone': phone,
      'dui_number': duiNumber,
      'date_of_birth': dateOfBirth,
    });

    print('✅ Perfil actualizado correctamente en la base de datos.');
  } catch (e) {
    print('❌ Error al actualizar el perfil: $e');
    rethrow;
  }
}

}
