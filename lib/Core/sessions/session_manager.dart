import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';

class SessionManager {
  static Profile? _currentProfile;

  // Obtener el perfil actual en sesión
  static Profile? get currentProfile => _currentProfile;

  // Guardar perfil en sesión
  static void setProfile(Profile profile) => _currentProfile = profile;

  // Limpiar perfil de sesión
  static Future<void> clearProfile() async {
    _currentProfile = null;
  }
}
