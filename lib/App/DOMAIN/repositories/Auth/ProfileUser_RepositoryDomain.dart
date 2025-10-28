import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
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

  Future<Profile> getUserProfile({required String email});

  // Sesión local
  Future<AuthProfilesUserModel?> getLocalSession();

  // ✅ Nuevo método para verificar OTP
  Future<bool> verifyOtp({
    required String email,
    required String inputOtp,
  });
}
