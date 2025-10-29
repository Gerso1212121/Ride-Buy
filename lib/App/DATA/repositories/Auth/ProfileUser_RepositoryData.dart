import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import '../../../DOMAIN/repositories/Auth/ProfileUser_RepositoryDomain.dart';

class ProfileUserRepositoryData implements ProfileUserRepositoryDomain {
  static const _sessionKey = 'user_session';
  static const _otpKey = 'user_otp'; // OTP temporal

  final Dio dio;
  final String emailJsServiceId;
  final String emailJsTemplateId;
  final String emailJsPublicKey;

  ProfileUserRepositoryData({
    required this.dio,
    required this.emailJsServiceId,
    required this.emailJsTemplateId,
    required this.emailJsPublicKey,
  });

  // 🔑 Hashear contraseña (SHA-256)
  String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  // ------------------------------
  // REGISTRO DE USUARIO + OTP
  // ------------------------------
  @override
  Future<Profile> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      final now = DateTime.now();
      final hashedPassword = _hashPassword(password);

      final profile = AuthProfilesUserModel(
        id: email,
        role: UserRole.cliente,
        verificationStatus: VerificationStatus.pendiente,
        emailVerified: false,
        createdAt: now,
        updatedAt: now,
        passwd: hashedPassword,
      );
      print("INICIANDO INSERCCIÓN");
      // Guardar usuario en DB
      await RenderDbClient.runTransaction((ctx) async {
        const sql = '''
          INSERT INTO profiles (
            id, role, verification_status, email_verified, created_at, updated_at, password
          ) VALUES (
            @id, @role, @verificationStatus, @emailVerified, @createdAt, @updatedAt, @password
          )
        ''';
        await ctx.execute(Sql.named(sql), parameters: profile.toMap());
      });

      // Generar OTP
      final otp = _generateOTP();

      // Guardar OTP localmente (SharedPreferences)
      await _saveOtpLocally(email, otp);

      // Enviar OTP al correo
      await _sendOTPEmail(email, otp);

      print('✅ Usuario registrado y OTP enviado a $email');
      return profile;
    } catch (e, st) {
      print('❌ Error en registerUser: $e');
      print(st);
      throw Exception('Error al registrar usuario');
    }
  }

  // ------------------------------
  // LOGIN DE USUARIO
  // ------------------------------
  @override
  Future<AuthProfilesUserModel> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      const sql = 'SELECT * FROM profiles WHERE id=@id';
      final result = await RenderDbClient.query(sql, parameters: {'id': email});

      if (result.isEmpty) throw Exception('Usuario no encontrado');

      final profile = AuthProfilesUserModel.fromMap(result.first);

      // Verificar contraseña
      if (profile.passwd != _hashPassword(password)) {
        throw Exception('Contraseña incorrecta');
      }

      // Generar token local (solo sesión)
      final token = DateTime.now().millisecondsSinceEpoch.toString();
      final updatedProfile = profile.copyWith(token: token);

      // Guardar sesión local
      await _saveUserSession(updatedProfile);

      return updatedProfile;
    } catch (e, st) {
      print('❌ Error en loginUser: $e');
      print(st);
      throw Exception('Error al iniciar sesión');
    }
  }

  // ------------------------------
  // GUARDAR SESIÓN LOCAL
  // ------------------------------
  Future<void> _saveUserSession(AuthProfilesUserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(user.toMap()));
  }

  // ------------------------------
  // OBTENER SESIÓN LOCAL
  // ------------------------------
  @override
  Future<AuthProfilesUserModel?> getLocalSession() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_sessionKey);
    if (data == null) return null;

    try {
      return AuthProfilesUserModel.fromMap(jsonDecode(data));
    } catch (e) {
      print('⚠️ Error decodificando sesión: $e');
      return null;
    }
  }

  // ------------------------------
  // CERRAR SESIÓN
  // ------------------------------
  @override
  Future<bool> logoutUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove(_otpKey);
      return true;
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      return false;
    }
  }

  // ------------------------------
  // OBTENER PERFIL DESDE LA BD
  // ------------------------------
  @override
  Future<Profile> getUserProfile({required String userId}) async {
    const sql = 'SELECT * FROM profiles WHERE id=@id';
    final result = await RenderDbClient.query(sql, parameters: {'id': userId});
    if (result.isEmpty) throw Exception('Perfil no encontrado');
    return AuthProfilesUserModel.fromMap(result.first);
  }

  // ------------------------------
  // MÉTODOS AUXILIARES OTP
  // ------------------------------

  // Generar OTP aleatorio
  String _generateOTP() => (Random().nextInt(900000) + 100000).toString();

  // Guardar OTP localmente
  Future<void> _saveOtpLocally(String email, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_otpKey, jsonEncode({'email': email, 'otp': otp}));
  }

  // Verificar OTP ingresado por usuario
// ------------------------------
// Verificar OTP ingresado por usuario
// ------------------------------
  @override
  Future<bool> verifyOtp(
      {required String email, required String inputOtp}) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_otpKey);
    if (data == null) return false;

    try {
      final map = jsonDecode(data);
      if (map['email'] == email && map['otp'] == inputOtp) {
        await prefs.remove(_otpKey); // eliminar OTP luego de verificar
        return true;
      }
      return false;
    } catch (e) {
      print('⚠️ Error verificando OTP: $e');
      return false;
    }
  }

  Future<void> _sendOTPEmail(String email, String otp) async {
    final payload = {
      'service_id': emailJsServiceId,
      'template_id': emailJsTemplateId,
      'user_id': emailJsPublicKey,
      'template_params': {
        'email': email, // coincide con {{email}} en tu plantilla
        'passcode': otp, // coincide con {{passcode}} en tu plantilla
      },
    };

    final response = await dio.post(
      'https://api.emailjs.com/api/v1.0/email/send',
      data: jsonEncode(payload),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error enviando OTP: ${response.data}');
    }

    print('✅ OTP enviado a $email: $otp');
  }

// ------------------------------
// ACTUALIZAR DATOS FALTANTES DEL PERFIL (DUI, LICENCIA, ETC.)
// ------------------------------
  @override
  Future<void> updateProfileData({
    required String userId,
    required String displayName,
    required String duiNumber,
    required String phone,
    DateTime? dateOfBirth,
  }) async {
    try {
      final fields = <String, dynamic>{
        'display_name': displayName,
        'dui_number': duiNumber,
        'phone': phone,
        'date_of_birth': dateOfBirth?.toIso8601String(),
      }..removeWhere((key, value) => value == null); // 🔥 elimina nulls

      if (fields.isEmpty) return;

      final setClause = fields.keys.map((k) => '$k=@$k').join(', ');
      final sql =
          'UPDATE profiles SET $setClause, updated_at=NOW() WHERE id=@id';

      await RenderDbClient.query(sql, parameters: {
        ...fields,
        'id': userId,
      });

      print('✅ Perfil actualizado correctamente');
    } catch (e, st) {
      print('❌ Error al actualizar perfil: $e');
      print(st);
      throw Exception('Error actualizando perfil');
    }
  }
}
