import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/Auth/ProfileUser_RepositoryDomain.dart';

class ProfileUserUseCaseGlobal {
  final ProfileUserRepositoryDomain repository;

  ProfileUserUseCaseGlobal(this.repository);

  // Login
  Future<Profile> login(
      {required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password must not be empty');
    }
    return await repository.loginUser(email: email, password: password);
  }

  // Register
  Future<Profile> register(
      {required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password must not be empty');
    }
    return await repository.registerUser(email: email, password: password);
  }

  // Get user profile
  Future<Profile?> getProfile(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID must not be empty');
    }
    return await repository.getUserProfile(userId: userId);
  }

  // Logout
  Future<bool> logout() async {
    return await repository.logoutUser();
  }
}
