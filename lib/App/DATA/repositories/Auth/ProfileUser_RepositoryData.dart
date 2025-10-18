import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../DOMAIN/Entities (ordenarlas en base a los features)/Auth/user_entity.dart';
import '../../../DOMAIN/repositories/Auth/ProfileUser_RepositoryDomain.dart';
import '../../models/Auth/ProfileUser_Model.dart';

class ProfileUserRepositoryData implements ProfileUserRepositoryDomain {
  final SupabaseClient supabaseClient;

  ProfileUserRepositoryData(this.supabaseClient);

  @override
  Future<Profile> registerUser({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) async {
    try {
      // 1️⃣ Crear usuario y enviar correo de verificación
      final response = await supabaseClient.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: emailRedirectTo,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('No se pudo crear el usuario en Supabase Auth.');
      }

      final userId = user.id;

      // 2️⃣ Esperar la creación del perfil en la tabla 'profiles'
      final profileRow = await _waitForProfile(userId);

      if (profileRow == null) {
        throw Exception('El perfil no fue creado automáticamente.');
      }

      // 3️⃣ Convertir a modelo y devolver
      return ProfileUserModel.fromJson(profileRow);
    } on AuthException catch (e) {
      // Errores de Supabase Auth (correo duplicado, contraseña débil, etc.)
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      throw Exception('Error en el registro: ${e.toString()}');
    }
  }

  // 🔹 Función auxiliar para esperar el trigger de perfil
  Future<Map<String, dynamic>?> _waitForProfile(String userId) async {
    const maxRetries = 10;
    const delayBetween = Duration(seconds: 1);

    for (var i = 0; i < maxRetries; i++) {
      final res = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (res != null) return res;
      await Future.delayed(delayBetween);
    }

    return null;
  }

  @override
  Future<Profile> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final response = await supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        throw Exception('Credenciales incorrectas.');
      }

      final profileRow = await supabaseClient
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      if (profileRow == null) {
        throw Exception('Perfil no encontrado para el usuario.');
      }

      return ProfileUserModel.fromJson(profileRow);
    } on AuthException catch (e) {
      throw Exception('Error de autenticación: ${e.message}');
    } catch (e) {
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }
}
