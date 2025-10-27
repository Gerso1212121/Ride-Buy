import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';

abstract class ProfileUserRepositoryDomain {
  Future<Profile> registerUser({
    required String email,
    required String password,
  });

  Future<Profile> loginUser({
    required String email,
    required String password,
  });
  Future<bool> logoutUser();

  Future<Profile> getUserProfile({required String userId});
}
