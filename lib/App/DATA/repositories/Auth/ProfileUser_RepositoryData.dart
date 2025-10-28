import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:postgres/postgres.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import '../../../DOMAIN/repositories/Auth/ProfileUser_RepositoryDomain.dart';

class ProfileUserRepositoryData implements ProfileUserRepositoryDomain {
  static const _sessionKey = 'user_session';
  static const _otpPrefix = 'otp_';
  static const _otpTimestampPrefix = 'otp_ts_';

  final Dio dio;

  ProfileUserRepositoryData({required this.dio});

  String _hashPassword(String password) =>
      sha256.convert(utf8.encode(password)).toString();

  // ------------------------------
  // REGISTRO
  // ------------------------------
  @override
  Future<Profile> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      if (await _checkUserExists(email)) {
        throw Exception('Correo ya registrado');
      }

      final now = DateTime.now();
      final newId = Uuid().v4();
      final hashedPassword = _hashPassword(password);

      final profile = AuthProfilesUserModel(
        id: newId,
        role: UserRole.cliente,
        verificationStatus: VerificationStatus.pendiente,
        emailVerified: false,
        createdAt: now,
        updatedAt: now,
        passwd: hashedPassword,
        displayName: null,
        phone: null,
      );

      await RenderDbClient.runTransaction((ctx) async {
        const sql = '''
          INSERT INTO profiles (
            id, role, verification_status, email_verified, created_at, updated_at, passwd, email
          ) VALUES (
            @id, @role, @verification_status, @email_verified, @created_at, @updated_at, @passwd, @email
          )
        ''';
        await ctx.execute(Sql.named(sql), parameters: {
          'id': profile.id,
          'role': profile.role.name,
          'verification_status': profile.verificationStatus.name,
          'email_verified': profile.emailVerified,
          'created_at': profile.createdAt.toIso8601String(),
          'updated_at': profile.updatedAt.toIso8601String(),
          'passwd': profile.passwd,
          'email': email,
        });
      });

      final otp = _generateOTP();
      await _saveOtpLocally(email, otp);
      await _sendOTPEmail(email, otp);

      return profile;
    } catch (e) {
      print('❌ Error en registerUser: $e');
      rethrow;
    }
  }

  Future<bool> _checkUserExists(String email) async {
    try {
      const sql = 'SELECT COUNT(*) as count FROM profiles WHERE email = @email';
      final result = await RenderDbClient.query(sql, parameters: {'email': email});
      return (result.first['count'] as int? ?? 0) > 0;
    } catch (e) {
      print('⚠️ Error verificando usuario: $e');
      return false;
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
      final result = await RenderDbClient.query(sql, parameters: {'email': email});

      if (result.isEmpty) throw Exception('Usuario no encontrado');

      final profile = AuthProfilesUserModel.fromMap(result.first);
      if (profile.passwd != _hashPassword(password)) {
        throw Exception('Contraseña incorrecta');
      }

      if (!profile.emailVerified) {
        throw Exception('Email no verificado');
      }

      final updatedProfile = profile.copyWith(
        token: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      await _saveUserSession(updatedProfile);
      return updatedProfile;
    } catch (e) {
      print('❌ Error en loginUser: $e');
      rethrow;
    }
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

      for (var key in prefs.getKeys()) {
        if (key.startsWith(_otpPrefix) || key.startsWith(_otpTimestampPrefix)) {
          await prefs.remove(key);
        }
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  // ------------------------------
  // PERFIL
  // ------------------------------
  @override
  Future<Profile> getUserProfile({required String email}) async {
    const sql = 'SELECT * FROM profiles WHERE email = @email';
    final result = await RenderDbClient.query(sql, parameters: {'email': email});
    if (result.isEmpty) throw Exception('Usuario no encontrado');
    return AuthProfilesUserModel.fromMap(result.first);
  }

  // ------------------------------
  // OTP
  // ------------------------------
  String _generateOTP() => (100000 + Random().nextInt(900000)).toString();

  Future<void> _saveOtpLocally(String email, String otp) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_otpPrefix$email', otp);
    await prefs.setInt('$_otpTimestampPrefix$email', DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<bool> verifyOtp({required String email, required String inputOtp}) async {
    final prefs = await SharedPreferences.getInstance();
    final storedOtp = prefs.getString('$_otpPrefix$email');
    final timestamp = prefs.getInt('$_otpTimestampPrefix$email');

    if (storedOtp == null || timestamp == null) return false;

    if (DateTime.now().millisecondsSinceEpoch - timestamp > 600000) {
      await prefs.remove('$_otpPrefix$email');
      await prefs.remove('$_otpTimestampPrefix$email');
      throw Exception('OTP expirado');
    }

    if (storedOtp == inputOtp) {
      await _markEmailAsVerified(email);
      await prefs.remove('$_otpPrefix$email');
      await prefs.remove('$_otpTimestampPrefix$email');
      return true;
    }

    return false;
  }

  Future<void> _markEmailAsVerified(String email) async {
    await RenderDbClient.runTransaction((ctx) async {
      const sql = '''
        UPDATE profiles 
        SET email_verified = true, 
            verification_status = @status,
            updated_at = @updated_at
        WHERE email = @email
      ''';
      await ctx.execute(Sql.named(sql), parameters: {
        'email': email,
        'status': VerificationStatus.verificado.name,
        'updated_at': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> _sendOTPEmail(String email, String otp) async {
    final smtpEmail = dotenv.env['SMTP_EMAIL'];
    final smtpPassword = dotenv.env['SMTP_PASSWORD'];
    if (smtpEmail == null || smtpPassword == null) throw Exception('SMTP no configurado');

    final smtpServer = gmail(smtpEmail, smtpPassword);
    final message = Message()
      ..from = Address(smtpEmail, 'EZRide App')
      ..recipients.add(email)
      ..subject = 'Código de verificación EZRide'
      ..html = '<h1>Tu OTP: $otp</h1>';

    await send(message, smtpServer);
  }
}
