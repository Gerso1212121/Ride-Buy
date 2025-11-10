import 'dart:convert';
import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:ezride/Services/render/render_db_client.dart';

class SessionManager {
  static const _sessionKey = 'user_session';
  static const _empresaKey = 'user_empresa';

  static Profile? _currentProfile;
  static EmpresasModel? _currentEmpresa;

  static final ValueNotifier<Profile?> profileNotifier = ValueNotifier(null);
  static final ValueNotifier<EmpresasModel?> empresaNotifier =
      ValueNotifier(null);

  // GETTERS
  static Profile? get currentProfile => _currentProfile;
  static EmpresasModel? get currentEmpresa => _currentEmpresa;

  static bool get hasSession => _currentProfile != null;

  static bool get isVerified =>
      _currentProfile?.verificationStatus == VerificationStatus.verificado;

  // ===========================================================
  // ✅ GUARDAR PERFIL + EMPRESA
  // ===========================================================
  static Future<void> setProfile(Profile profile,
      {EmpresasModel? empresa}) async {
    try {
      _currentProfile = profile;
      _currentEmpresa = empresa;

      final prefs = await SharedPreferences.getInstance();

      final userModel = profile is AuthProfilesUserModel
          ? profile
          : AuthProfilesUserModel.fromEntity(profile);

      // ✅ Guardar perfil en local
      await prefs.setString(_sessionKey, jsonEncode(userModel.toMap()));

      // ✅ Guardar empresa si existe
      if (empresa != null) {
        await prefs.setString(_empresaKey, jsonEncode(empresa.toMap()));
      } else {
        await prefs.remove(_empresaKey);
      }

      profileNotifier.value = profile;
      empresaNotifier.value = empresa;
    } catch (e) {
      print('❌ Error guardando sesión completa: $e');
    }
  }

  // ===========================================================
  // ✅ CARGAR PERFIL + EMPRESA
  // ===========================================================
  static Future<Profile?> loadSession() async {
    try {
      if (_currentProfile != null) return _currentProfile;

      final prefs = await SharedPreferences.getInstance();
      final jsonData = prefs.getString(_sessionKey);

      if (jsonData == null) return null;

      final map = jsonDecode(jsonData);
      final model = AuthProfilesUserModel.fromMap(map);

      // ✅ Verificar existencia real en BD
      if (!await _checkUserExistence(model.id)) {
        await clearProfile();
        return null;
      }

      // ✅ Cargar perfil en memoria
      _currentProfile = model;
      profileNotifier.value = model;

      // =====================================================
      // ✅ Paso 1: Intentar cargar empresa desde local
      // =====================================================
      final empresaJson = prefs.getString(_empresaKey);
      if (empresaJson != null) {
        try {
          final empresaMap = jsonDecode(empresaJson);
          final empresaLocal = EmpresasModel.fromMap(empresaMap);

          _currentEmpresa = empresaLocal;
          empresaNotifier.value = empresaLocal;

          return _currentProfile;
        } catch (e) {
          print('⚠️ Empresa local corrupta, borrando…');
          await prefs.remove(_empresaKey);
        }
      }

      // =====================================================
      // ✅ Paso 2: Si no había empresa local → buscar en BD
      // =====================================================
      final empresaBD = await _getEmpresaData(model.id);

      _currentEmpresa = empresaBD;
      empresaNotifier.value = empresaBD;

      // ✅ IMPORTANTE: guardar también en local
      if (empresaBD != null) {
        await prefs.setString(_empresaKey, jsonEncode(empresaBD.toMap()));
      }

      return _currentProfile;
    } catch (e) {
      print('❌ Error cargando sesión: $e');
      await clearProfile();
      return null;
    }
  }

  // ===========================================================
  // ✅ Verificar si usuario existe en BD
  // ===========================================================
  static Future<bool> _checkUserExistence(String userId) async {
    const sql = '''
      SELECT id
      FROM public.profiles
      WHERE id = @uid
    ''';

    try {
      final result =
          await RenderDbClient.query(sql, parameters: {'uid': userId});
      return result.isNotEmpty;
    } catch (e) {
      print('❌ Error comprobando existencia de usuario: $e');
      return false;
    }
  }

  // ===========================================================
  // ✅ Obtener empresa asociada (desde BD)
  // ===========================================================
  static Future<EmpresasModel?> _getEmpresaData(String userId) async {
    const sql = '''
      SELECT *
      FROM public.empresas
      WHERE owner_id = @uid;
    ''';

    try {
      final result =
          await RenderDbClient.query(sql, parameters: {'uid': userId});
      if (result.isEmpty) return null;

      final row = result.first;

      return EmpresasModel.fromMap(row);
    } catch (e) {
      print('❌ Error obteniendo empresa en BD: $e');
      return null;
    }
  }

  static Future<EmpresasModel?> getEmpresaFromDB(String userId) async {
    const sql = '''
    SELECT *
    FROM public.empresas
    WHERE owner_id = @uid;
  ''';

    try {
      final result =
          await RenderDbClient.query(sql, parameters: {'uid': userId});
      if (result.isEmpty) return null;
      return EmpresasModel.fromMap(result.first);
    } catch (e) {
      print('❌ Error obteniendo empresa desde login: $e');
      return null;
    }
  }

  // ===========================================================
  // ✅ Actualizar perfil LOCAL + mantener empresa
  // ===========================================================
  static Future<void> updateProfile({
    String? displayName,
    String? phone,
    bool? emailVerified,
  }) async {
    if (_currentProfile == null) return;

    try {
      final model = _currentProfile is AuthProfilesUserModel
          ? _currentProfile as AuthProfilesUserModel
          : AuthProfilesUserModel.fromEntity(_currentProfile!);

      final updated = model.copyWith(
        displayName: displayName,
        phone: phone,
        emailVerified: emailVerified,
      );

      await setProfile(updated, empresa: _currentEmpresa);
    } catch (e) {
      print('❌ Error actualizando perfil local: $e');
    }
  }

  // ===========================================================
  // ✅ LIMPIAR SESIÓN COMPLETA
  // ===========================================================
  static Future<void> clearProfile() async {
    try {
      _currentProfile = null;
      _currentEmpresa = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove(_empresaKey);

      profileNotifier.value = null;
      empresaNotifier.value = null;
    } catch (e) {
      print('❌ Error limpiando sesión: $e');
    }
  }

  static String? get currentUserId => _currentProfile?.id;
  static String? get currentUserEmail => _currentProfile?.email;
}
