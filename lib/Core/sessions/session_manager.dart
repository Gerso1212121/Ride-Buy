import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';

class SessionManager {
  static Profile? _currentProfile;

  /// Obtener el perfil actual en memoria
  static Profile? get currentProfile => _currentProfile;

  /// Guardar perfil en sesión (memoria + SharedPreferences)
  static Future<void> setProfile(Profile profile) async {
    _currentProfile = profile;

    final prefs = await SharedPreferences.getInstance();
    final userModel = AuthProfilesUserModel.fromEntity(profile);
    await prefs.setString('user_session', jsonEncode(userModel.toJson()));
  }

  /// Cargar sesión desde almacenamiento local (SharedPreferences)
  static Future<Profile?> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user_session');

    if (userJson != null) {
      final userModel = AuthProfilesUserModel.fromJson(userJson);
      _currentProfile = userModel;
      return _currentProfile;
    }
    return null;
  }

  /// Limpiar sesión (memoria + almacenamiento local)
  static Future<void> clearProfile() async {
    _currentProfile = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
  }
}
