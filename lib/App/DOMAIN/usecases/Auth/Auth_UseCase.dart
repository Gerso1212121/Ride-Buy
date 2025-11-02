import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/REGISTER_PENDING_user_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/Auth/ProfileUser_RepositoryDomain.dart';

class ProfileUserUseCaseGlobal {
  final ProfileUserRepositoryDomain repository;

  ProfileUserUseCaseGlobal(this.repository);

  // ------------------------------
  // LOGIN
  // ------------------------------
  Future<Profile> login(
      {required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email y contraseña no pueden estar vacíos');
    }

    try {
      final profile = await repository.loginUser(
        email: email.trim(),
        password: password.trim(),
      );
      return profile;
    } catch (e) {
      print('❌ Error iniciando sesión para $email: $e');
      rethrow;
    }
  }

  // ------------------------------
  // REGISTER
  // ------------------------------
  Future<RegisterPending> registerPending({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email y contraseña no pueden estar vacíos');
    }

    // Validación simple de formato
    if (!email.contains('@') || !email.contains('.')) {
      throw Exception('Formato de correo inválido');
    }

    try {
      final pending = await repository.registerPendingUser(
        email: email.trim(),
        password: password.trim(),
      );

      // Aquí podrías loguear métricas o registrar eventos de analytics, si querés.
      print('✅ Usuario pendiente creado y OTP enviado: ${pending.email}');

      return pending;
    } catch (e) {
      print('❌ Error registrando usuario pendiente $email: $e');
      rethrow; // Se deja a la capa de presentación manejar el mensaje
    }
  }

  // ------------------------------
  // GET PROFILE
  // ------------------------------
  Future<Profile?> getProfile(String email) async {
    if (email.trim().isEmpty) {
      throw Exception('Email no puede estar vacío');
    }

    try {
      final profile = await repository.getUserProfile(email: email.trim());
      return profile;
    } catch (e) {
      print('❌ Error obteniendo perfil para $email: $e');
      return null;
    }
  }

  // ------------------------------
  // LOGOUT
  // ------------------------------
  Future<bool> logout() async {
    try {
      return await repository.logoutUser();
    } catch (e) {
      print('❌ Error cerrando sesión: $e');
      return false;
    }
  }
}
