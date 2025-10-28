import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/Auth/ProfileUser_RepositoryDomain.dart';

class ProfileUserUseCaseGlobal {
  final ProfileUserRepositoryDomain repository;

  ProfileUserUseCaseGlobal(this.repository);

  // ------------------------------
  // LOGIN
  // ------------------------------
  Future<Profile> login({required String email, required String password}) async {
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
  Future<Profile> register({required String email, required String password}) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw Exception('Email y contraseña no pueden estar vacíos');
    }

    try {
      final profile = await repository.registerUser(
        email: email.trim(),
        password: password.trim(),
      );
      return profile;
    } catch (e) {
      print('❌ Error registrando usuario $email: $e');
      rethrow;
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
