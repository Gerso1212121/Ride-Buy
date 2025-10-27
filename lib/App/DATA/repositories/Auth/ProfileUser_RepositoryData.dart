import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';
import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Services/PostgreSQL/PostgreSQL_Client.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import '../../../DOMAIN/repositories/Auth/ProfileUser_RepositoryDomain.dart';

/// Repositorio de autenticación basado en PostgreSQL
class ProfileUserRepositoryData implements ProfileUserRepositoryDomain {
  // 📍 REGISTRO DE USUARIO
  @override
  Future<Profile> registerUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Iniciando registro para: $email');

      // 1️⃣ Preparar el perfil
      final now = DateTime.now();
      final id = email; // aquí puedes usar email o generar UUID
      final profile = AuthProfilesUserModel(
        id: id,
        role: UserRole.cliente,
        verificationStatus: VerificationStatus.pendiente,
        emailVerified: false,
        createdAt: now,
        updatedAt: now,
        password: password, // agregar campo para almacenar contraseña hasheada
      );

      // 2️⃣ Insertar en la base de datos usando transacción
      await RenderDbClient.runTransaction((ctx) async {
        const sql = '''
          INSERT INTO profiles (id, role, verification_status, email_verified, created_at, updated_at, password)
          VALUES (@id, @role, @verificationStatus, @emailVerified, @createdAt, @updatedAt, @password)
        ''';

        await ctx.execute(Sql.named(sql), parameters: profile.toMap());
      });

      print('✅ Perfil creado exitosamente');
      return profile;
    } catch (e, st) {
      print('❌ Error en registro: $e');
      print(st);
      throw Exception('Error al registrar: $e');
    }
  }

  // 📍 LOGIN DE USUARIO
  @override
  Future<Profile> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Iniciando sesión para: $email');

      const sql = '''
        SELECT * FROM profiles WHERE id=@id
      ''';

      final result = await RenderDbClient.query(sql, parameters: {'id': email});

      if (result.isEmpty) {
        throw Exception('Usuario no encontrado.');
      }

      final profileData = result.first;

      // Aquí deberías verificar contraseña (hasheada)
      final profile = AuthProfilesUserModel.fromMap(profileData);

      if (profile.password != password) {
        throw Exception('Contraseña incorrecta.');
      }

      print('✅ Login completado con éxito');
      return profile;
    } catch (e, st) {
      print('❌ Error en login: $e');
      print(st);
      throw Exception('Error al iniciar sesión: $e');
    }
  }

  // 📍 LOGOUT DE USUARIO
  @override
  Future<bool> logoutUser() async {
    try {
      // En PostgreSQL puro no hay sesión de auth, esto solo se puede manejar en la app
      print('✅ Sesión cerrada correctamente');
      return true;
    } catch (e, st) {
      print('❌ Error al cerrar sesión: $e');
      print(st);
      return false;
    }
  }

  // 📍 OBTENER PERFIL DE USUARIO
  @override
  Future<Profile> getUserProfile({required String userId}) async {
    try {
      const sql = 'SELECT * FROM profiles WHERE id=@id';
      final result =
          await RenderDbClient.query(sql, parameters: {'id': userId});

      if (result.isEmpty) {
        throw Exception('No se encontró el perfil del usuario');
      }

      final profile = AuthProfilesUserModel.fromMap(result.first);
      return profile;
    } catch (e, st) {
      print('❌ Error al obtener perfil: $e');
      print(st);
      throw Exception('Error al obtener perfil: $e');
    }
  }
}
