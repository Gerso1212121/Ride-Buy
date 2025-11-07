import 'dart:convert';
import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/Entities/empresas_entity.dart'; // Importamos EmpresasModel
import 'package:flutter/foundation.dart'; // 👈 Necesario para ValueNotifier
import 'package:ezride/Services/render/render_db_client.dart'; // Para la consulta de base de datos

class SessionManager {
  static const _sessionKey = 'user_session';
  static Profile? _currentProfile;
  static EmpresasModel? _currentEmpresa; // Variable para guardar empresa

  /// 🔥 Notificador global del perfil
  static final ValueNotifier<Profile?> profileNotifier = ValueNotifier(null);
  static final ValueNotifier<EmpresasModel?> empresaNotifier = ValueNotifier(null);

  /// Obtener el perfil actual en memoria
  static Profile? get currentProfile => _currentProfile;
  static EmpresasModel? get currentEmpresa => _currentEmpresa;

  // Setter para cambiar la empresa de forma pública
  static set currentEmpresa(EmpresasModel? empresa) {
    _currentEmpresa = empresa;
    empresaNotifier.value = empresa; // Notificar a los listeners que la empresa ha cambiado
  }

  /// Verificar si hay una sesión activa
  static bool get hasSession => _currentProfile != null;
  /// Verificar si el usuario está verificado
  static bool get isVerified {
    return _currentProfile?.verificationStatus == VerificationStatus.verificado;
  }

  /// Guardar perfil en sesión (memoria + SharedPreferences)
  static Future<void> setProfile(Profile profile,
      {EmpresasModel? empresa}) async {
    try {
      print('💾 Guardando perfil en sesión...');
      print('  ID: ${profile.id}');
      print('  Email: ${profile.email}');
      print('  Verificado: ${profile.emailVerified}');

      _currentProfile = profile;
      _currentEmpresa = empresa; // Guardamos la empresa si existe

      final prefs = await SharedPreferences.getInstance();
      print('  Guardando en SharedPreferences...');

      final userModel = profile is AuthProfilesUserModel
          ? profile
          : AuthProfilesUserModel.fromEntity(profile);

      final jsonString = jsonEncode(userModel.toMap());
      await prefs.setString(_sessionKey, jsonString);

      /// 🚀 Notificar listeners del cambio en el perfil
      profileNotifier.value = profile;

      // Si existe empresa, también la guardamos
      if (empresa != null) {
        empresaNotifier.value = empresa;
      }

      print('✅ Perfil guardado exitosamente');
    } catch (e, st) {
      print('❌ Error guardando perfil: $e');
      print('Stack trace: $st');
      rethrow;
    }
  }

  /// Cargar sesión desde almacenamiento local y verificar en la base de datos
  static Future<Profile?> loadSession() async {
    try {
      print('🔍 Intentando cargar sesión desde SharedPreferences...');
      if (_currentProfile != null) {
        print('✅ Sesión recuperada desde memoria');
        return _currentProfile;
      }

      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_sessionKey);

      if (userJson == null || userJson.isEmpty) {
        print('⚠️ No hay sesión guardada');
        return null;
      }

      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      final userModel = AuthProfilesUserModel.fromMap(userMap);
      print('🔄 Perfil cargado desde SharedPreferences: ${userModel.id}');

      // Verificar que el usuario existe en la base de datos
      final profileExists = await _checkUserExistence(userModel.id);
      if (!profileExists) {
        print('⚠️ Usuario no existe en la base de datos, sesión eliminada.');
        await clearProfile();
        return null;
      }

      _currentProfile = userModel;

      // Verificar si el usuario tiene una empresa asociada
      final hasEmpresa = await _checkIfUserHasEmpresa(userModel.id);
      print('Usuario tiene empresa asociada: $hasEmpresa');

      if (hasEmpresa) {
        final empresaData = await _getEmpresaData(userModel.id);
        print('Empresa asociada encontrada: ${empresaData?.nombre}');
        _currentEmpresa = empresaData; // Guardamos los datos de la empresa
      } else {
        print('El usuario no tiene una empresa asociada.');
      }

      // Notificar a los listeners
      profileNotifier.value = _currentProfile;
      empresaNotifier.value = _currentEmpresa;

      print('✅ Sesión cargada exitosamente');
      return _currentProfile;
    } catch (e, st) {
      print('❌ Error cargando sesión: $e');
      print('Stack trace: $st');
      await clearProfile();
      return null;
    }
  }

  /// Verificar si el usuario existe en la base de datos
  static Future<bool> _checkUserExistence(String userId) async {
    const sql = '''
      SELECT id
      FROM public.profiles
      WHERE id = @user_id;
    ''';

    try {
      print('🔄 Verificando existencia del usuario en la base de datos...');
      final result = await RenderDbClient.query(sql, parameters: {
        'user_id': userId,
      });

      return result.isNotEmpty; // Si el resultado no está vacío, el usuario existe
    } catch (e) {
      print('❌ Error al verificar existencia del usuario: $e');
      return false;
    }
  }

  /// Verificar si el usuario tiene una empresa registrada
  static Future<bool> _checkIfUserHasEmpresa(String userId) async {
    const sql = '''
    SELECT 1
    FROM public.empresas
    WHERE owner_id = @user_id;
  ''';

    try {
      print('🔄 Verificando si el usuario tiene una empresa asociada...');
      final result = await RenderDbClient.query(sql, parameters: {
        'user_id': userId,
      });

      return result.isNotEmpty; // Si el resultado no está vacío, significa que ya tiene una empresa registrada
    } catch (e) {
      print('❌ Error al verificar si el usuario tiene empresa: $e');
      return false; // Si ocurre un error, no se asume que el usuario tiene empresa
    }
  }

  /// Obtener los datos de la empresa asociada al usuario
/// Obtener los datos de la empresa asociada al usuario
static Future<EmpresasModel?> _getEmpresaData(String userId) async {
  const sql = '''
  SELECT id, nombre, nit, direccion, telefono, latitud, longitud
  FROM public.empresas
  WHERE owner_id = @user_id;
  ''';

  try {
    print('🔄 Obteniendo los datos de la empresa asociada al usuario...');
    final result = await RenderDbClient.query(sql, parameters: {
      'user_id': userId,
    });

    if (result.isNotEmpty) {
      // Extraemos los datos de la empresa
      var empresaData = result.first;

      // Imprimir cada campo
      print('🔸 id: ${empresaData['id']}');
      print('🔸 nombre: ${empresaData['nombre']}');
      print('🔸 nit: ${empresaData['nit']}');
      print('🔸 direccion: ${empresaData['direccion']}');
      print('🔸 telefono: ${empresaData['telefono']}');
      print('🔸 latitud: ${empresaData['latitud']}');
      print('🔸 longitud: ${empresaData['longitud']}');

      // Validar que los campos necesarios no sean nulos
      final id = empresaData['id'] as String?;
      final nombre = empresaData['nombre'] as String? ?? 'Nombre no disponible'; // Asignamos un valor por defecto si es nulo
      final nit = empresaData['nit'] as String? ?? 'NIT no disponible'; // Asignamos un valor por defecto si es nulo
      final direccion = empresaData['direccion'] as String? ?? 'Dirección no disponible'; // Asignamos un valor por defecto si es nulo
      final telefono = empresaData['telefono'] as String? ?? 'Teléfono no disponible'; // Asignamos un valor por defecto si es nulo
      final latitud = empresaData['latitud'] as double? ?? 0.0; // Asignamos un valor por defecto si es nulo
      final longitud = empresaData['longitud'] as double? ?? 0.0; // Asignamos un valor por defecto si es nulo

      // Crear el modelo de empresa con los valores validados
      final empresaModel = EmpresasModel(
        id: id ?? '', // Si el id es nulo, lo asignamos como una cadena vacía
        ownerId: userId,
        nombre: nombre,
        nit: nit,
        ncr: empresaData['ncr'] as String? ?? 'NCR no disponible', // Manejar valores nulos
        direccion: direccion,
        telefono: telefono,
        email: empresaData['email'] as String? ?? 'Email no disponible',
        latitud: latitud,
        longitud: longitud,
        verificationStatus: VerificationStatus.pendiente, // Suponiendo que este campo no está en la base de datos
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('✅ Empresa asociada encontrada: ${empresaModel.nombre}');
      return empresaModel;
    } else {
      print('⚠️ El usuario no tiene una empresa asociada.');
      return null;
    }
  } catch (e) {
    print('❌ Error al obtener los datos de la empresa: $e');
    return null; // Si ocurre un error, retornar null
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

      // Actualizar solo los datos del perfil
      final model = _currentProfile is AuthProfilesUserModel
          ? _currentProfile as AuthProfilesUserModel
          : AuthProfilesUserModel.fromEntity(_currentProfile!);

      final updatedModel = model.copyWith(
        displayName: displayName,
        phone: phone,
        emailVerified: emailVerified,
      );

      // Guardamos el perfil actualizado, y mantenemos la empresa si existe
      await setProfile(updatedModel, empresa: _currentEmpresa);
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
      _currentEmpresa = null; // Limpiamos los datos de la empresa

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionKey);
      await prefs.remove('otp_key');

      /// ✨ También limpiar notifier
      profileNotifier.value = null;
      empresaNotifier.value = null;

      print('✅ Sesión limpiada exitosamente');
    } catch (e) {
      print('❌ Error limpiando sesión: $e');
    }
  }

  static String? get currentUserId => _currentProfile?.id;
  static String? get currentUserEmail => _currentProfile?.email;
}
