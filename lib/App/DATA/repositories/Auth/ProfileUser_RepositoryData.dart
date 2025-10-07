import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../DOMAIN/Entities (ordenarlas en base a los features)/Auth/user_entity.dart';
import '../../../DOMAIN/repositories/Auth/ProfileUser_RepositoryDomain.dart';
import '../../models/Auth/ProfileUser_Model.dart';
import '../../../../Core/enums/enums.dart';

class ProfileUserRepositoryData implements ProfileUserRepositoryDomain {
  final SupabaseClient supabaseClient;

  ProfileUserRepositoryData(this.supabaseClient);

  @override
  Future<Profile> registerUser({
    required String email,
    required String password,
  }) async {
    final response = await supabaseClient.auth.signUp(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw Exception('Failed to register user');
    }
    final profileModel = ProfileUserModel(
      id: response.user!.id,
      role: UserRole.cliente,
      country: 'SV',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return profileModel;
  }

  @override
  Future<Profile> loginUser({
    required String email,
    required String password,
  }) async {
    final response = await supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Error iniciando sesión');
    }

    final profileModel = ProfileUserModel(
      id: response.user!.id,
      role: UserRole.cliente,
      displayName: response.user!.userMetadata!['name'] as String? ?? '',
      country: 'SV',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return profileModel;
  }
}
