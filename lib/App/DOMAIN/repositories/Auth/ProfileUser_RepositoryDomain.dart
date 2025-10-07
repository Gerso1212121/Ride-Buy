import '../../Entities (ordenarlas en base a los features)/Auth/user_entity.dart';

abstract class ProfileUserRepositoryDomain {
  Future<Profile> registerUser({
    required String email,
    required String password,
  });

  Future<Profile> loginUser({
    required String email,
    required String password,
  });
}
