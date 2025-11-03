import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/REGISTER_PENDING_user_entity.dart';

abstract class ProfileUserRepositoryDomain {
  // 🔑 Iniciar sesión
  Future<Profile> loginUser({
    required String email,
    required String password,
  });

  // 🕐 Registro inicial (guarda en register_pending)
  Future<RegisterPending> registerPendingUser({
    required String email,
    required String password,
  });

  // 🧾 Verificar OTP y migrar a profiles
  Future<Profile?> verifyOtp({
    required String email,
    required String inputOtp,
  });

  // 🚪 Cerrar sesión
  Future<bool> logoutUser();

  // 📋 Obtener perfil completo por email
  Future<Profile> getUserProfile({required String email});

  // 💾 Obtener sesión local almacenada (por token)
  Future<AuthProfilesUserModel?> getLocalSession();

  //Update Profile
Future<void> updateUserProfile({
  required String id,
  required String displayName,
  required String phone,
  required String duiNumber,
  required String dateOfBirth,
  required String verificationStatus,
});

}
