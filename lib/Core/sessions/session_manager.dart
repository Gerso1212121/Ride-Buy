import 'dart:convert';
import 'package:ezride/Core/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:flutter/foundation.dart'; // 👈 Necesario para ValueNotifier

class SessionManager {
  static const _sessionKey = 'user_session';
  static Profile? _currentProfile;

  /// 🔥 Notificador global del perfil
  static final ValueNotifier<Profile?> profileNotifier = ValueNotifier(null);

  /// Obtener el perfil actual en memoria
  static Profile? get currentProfile => _currentProfile;

  /// Verificar si hay una sesión activa
  static bool get hasSession => _currentProfile != null;

  /// Verificar si el usuario está verificado
  /// ✅ Usuario 100% verificado solo si pasó identidad
  static bool get isVerified {
    return _currentProfile?.verificationStatus == VerificationStatus.verificado;
  }

  /// Guardar perfil en sesión (memoria + SharedPreferences)
  static Future<void> setProfile(Profile profile) async {
    try {
      print('💾 Guardando perfil en sesión...');
      print('  ID: ${profile.id}');
      print('  Email: ${profile.email}');
      print('  Verificado: ${profile.emailVerified}');

      _currentProfile = profile;

      final prefs = await SharedPreferences.getInstance();

      final userModel = profile is AuthProfilesUserModel
          ? profile
          : AuthProfilesUserModel.fromEntity(profile);

      final jsonString = jsonEncode(userModel.toMap());
      await prefs.setString(_sessionKey, jsonString);

      /// 🚀 Notificar listeners del cambio en el perfil
      profileNotifier.value = profile;

      print('✅ Perfil guardado exitosamente');
    } catch (e, st) {
      print('❌ Error guardando perfil: $e');
      print('Stack trace: $st');
      rethrow;
    }
  }

  /// Cargar sesión desde almacenamiento local
  static Future<Profile?> loadSession() async {
    try {
      if (_currentProfile != null) {
        print('✅ Sesión recuperada desde memoria');
        return _currentProfile;
      }

      print('🔍 Cargando sesión desde SharedPreferences...');
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_sessionKey);

      if (userJson == null || userJson.isEmpty) {
        print('⚠️ No hay sesión guardada');
        return null;
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final userModel = AuthProfilesUserModel.fromMap(userMap);

      _currentProfile = userModel;

      /// 🟦 Notificar al cargar sesión
      profileNotifier.value = userModel;

      print('✅ Sesión cargada exitosamente');
      return _currentProfile;
    } catch (e, st) {
      print('❌ Error cargando sesión: $e');
      print('Stack trace: $st');
      await clearProfile();
      return null;
    }
  }

  /// Actualizar campos específicos
  static Future<void> updateProfile({
    String? displayName,
    String? phone,
    bool? emailVerified,
  }) async {
    if (_currentProfile == null) return;

    try {
      print('🔄 Actualizando perfil...');

      final model = _currentProfile is AuthProfilesUserModel
          ? _currentProfile as AuthProfilesUserModel
          : AuthProfilesUserModel.fromEntity(_currentProfile!);

      final updatedModel = model.copyWith(
        displayName: displayName,
        phone: phone,
        emailVerified: emailVerified,
      );

      await setProfile(updatedModel);
      print('✅ Perfil actualizado exitosamente');
    } catch (e, st) {
      print('❌ Error actualizando perfil: $e');
      print('Stack trace: $st');
    }
  }

  /// Limpiar sesión
  static Future<void> clearProfile() async {
    try {
      print('🗑️ Limpiando sesión...');

      _currentProfile = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove('otp_key');

      /// ✨ También limpiar notifier
      profileNotifier.value = null;

      print('✅ Sesión limpiada exitosamente');
    } catch (e) {
      print('❌ Error limpiando sesión: $e');
    }
  }

//de momento no se usa en ningun lado
  static Future<bool> isSessionValid() async {
    final profile = await loadSession();
    if (profile == null ||
        profile.id.isEmpty ||
        (profile.email?.isEmpty ?? true)) {
      print('⚠️ Sesión inválida');
      await clearProfile();
      return false;
    }
    return true;
  }

  static String? get currentUserId => _currentProfile?.id;
  static String? get currentUserEmail => _currentProfile?.email;
}
