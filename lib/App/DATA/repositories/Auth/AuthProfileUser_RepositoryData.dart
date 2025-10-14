import 'package:ezride/App/DATA/models/Auth/AuthProfilesUser_Model.dart';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PPROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/Auth/AuthProfileUser_RepositoryDomain.dart';
import 'package:ezride/Services/supabase/supabase_client.dart';

class AuthProfileUserRepositoryData implements AuthProfileUserRepositoryDomain {
  @override
  Future<Profile> getUserProfile({required String userId}) async {
    // 👇 Consulta en Supabase
    final response = await SupabaseClientService.client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle(); // devuelve un solo registro o null

    if (response == null) {
      throw Exception('No se encontró el perfil del usuario');
    }

    // 👇 Convertir el resultado a tu modelo
    final profile = AuthProfilesUserModel.fromMap(response);

    // 👇 Retornar la entidad (la clase base es Profile)
    return profile;
  }

}
