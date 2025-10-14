import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PPROFILE_user_entity.dart';

class SessionManager {
  static Profile? _currentProfile;

  static Profile? get currentProfile => _currentProfile;

  static void setProfile(Profile profile) => _currentProfile = profile;

  static void clearProfile() => _currentProfile = null;
}
