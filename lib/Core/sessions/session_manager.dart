import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';

class SessionManager {
  static const _sessionKey = 'user_session';
  static Profile? _currentProfile;

  /// Obtener el perfil actual en memoria
  static Profile? get currentProfile => _currentProfile;

  /// Verificar si hay una sesión activa
  static bool get hasSession => _currentProfile != null;

  /// Verificar si el usuario está verificado
  static bool get isVerified => _currentProfile?.emailVerified ?? false;

  /// Guardar perfil en sesión (memoria + SharedPreferences)
  static Future<void> setProfile(Profile profile) async {
    try {
      print('💾 Guardando perfil en sesión...');
      print('  ID: ${profile.id}');
      print('  Email: ${profile.email}');
      print('  Verificado: ${profile.emailVerified}');
      
      _currentProfile = profile;

      final prefs = await SharedPreferences.getInstance();
      
      // Convertir Profile a AuthProfilesUserModel si es necesario
      final userModel = profile is AuthProfilesUserModel 
          ? profile 
          : AuthProfilesUserModel.fromEntity(profile);
      
      final jsonString = jsonEncode(userModel.toMap());
      await prefs.setString(_sessionKey, jsonString);
      
      print('✅ Perfil guardado exitosamente');
    } catch (e, st) {
      print('❌ Error guardando perfil: $e');
      print('Stack trace: $st');
      rethrow;
    }
  }

  /// Cargar sesión desde almacenamiento local (SharedPreferences)
  static Future<Profile?> loadSession() async {
    try {
      // Si ya está en memoria, retornar directamente
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
      
      print('✅ Sesión cargada exitosamente');
      print('  ID: ${userModel.id}');
      print('  Email: ${userModel.email}');
      print('  Verificado: ${userModel.emailVerified}');
      
      return _currentProfile;
    } catch (e, st) {
      print('❌ Error cargando sesión: $e');
      print('Stack trace: $st');
      
      // Si hay error, limpiar la sesión corrupta
      await clearProfile();
      return null;
    }
  }

  /// Actualizar campos específicos del perfil
  static Future<void> updateProfile({
    String? displayName,
    String? phone,
    bool? emailVerified,
  }) async {
    if (_currentProfile == null) {
      print('⚠️ No hay perfil activo para actualizar');
      return;
    }

    try {
      print('🔄 Actualizando perfil...');
      
      // Si el perfil es un AuthProfilesUserModel, usar copyWith
      if (_currentProfile is AuthProfilesUserModel) {
        final currentModel = _currentProfile as AuthProfilesUserModel;
        final updatedModel = currentModel.copyWith(
          displayName: displayName,
          phone: phone,
          emailVerified: emailVerified,
        );
        
        await setProfile(updatedModel);
      } else {
        // Si es un Profile básico, convertir a AuthProfilesUserModel primero
        final model = AuthProfilesUserModel.fromEntity(_currentProfile!);
        final updatedModel = model.copyWith(
          displayName: displayName,
          phone: phone,
          emailVerified: emailVerified,
        );
        
        await setProfile(updatedModel);
      }
      
      print('✅ Perfil actualizado exitosamente');
    } catch (e, st) {
      print('❌ Error actualizando perfil: $e');
      print('Stack trace: $st');
      rethrow;
    }
  }

  /// Limpiar sesión (memoria + almacenamiento local)
  static Future<void> clearProfile() async {
    try {
      print('🗑️ Limpiando sesión...');
      
      _currentProfile = null;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      
      // Limpiar también otros datos relacionados
      await prefs.remove('otp_key');
      
      print('✅ Sesión limpiada exitosamente');
    } catch (e, st) {
      print('❌ Error limpiando sesión: $e');
      print('Stack trace: $st');
    }
  }

  /// Verificar si la sesión es válida
  static Future<bool> isSessionValid() async {
    try {
      final profile = await loadSession();
      
      if (profile == null) {
        print('⚠️ No hay sesión');
        return false;
      }

      // Verificar que el perfil tenga los datos mínimos necesarios
if (profile.id.isEmpty || (profile.email?.isEmpty ?? true)) {
  print('⚠️ Sesión inválida: faltan datos requeridos');
  await clearProfile();
  return false;
}

      print('✅ Sesión válida');
      return true;
    } catch (e) {
      print('❌ Error validando sesión: $e');
      return false;
    }
  }

  /// Obtener el ID del usuario actual
  static String? get currentUserId => _currentProfile?.id;

  /// Obtener el email del usuario actual
  static String? get currentUserEmail => _currentProfile?.email;

  /// Debug: Imprimir información de la sesión actual
  static void debugPrintSession() {
    if (_currentProfile == null) {
      print('📊 DEBUG: No hay sesión activa');
      return;
    }

    print('📊 DEBUG: Información de sesión');
    print('  ID: ${_currentProfile!.id}');
    print('  Email: ${_currentProfile!.email}');
    print('  Email Verificado: ${_currentProfile!.emailVerified}');
    print('  Rol: ${_currentProfile!.role}');
    print('  Estado: ${_currentProfile!.verificationStatus}');
    
    if (_currentProfile is AuthProfilesUserModel) {
      final model = _currentProfile as AuthProfilesUserModel;
      print('  Display Name: ${model.displayName ?? "N/A"}');
      print('  Phone: ${model.phone ?? "N/A"}');
      print('  Creado: ${model.createdAt}');
      print('  Actualizado: ${model.updatedAt}');
    }
  }
}