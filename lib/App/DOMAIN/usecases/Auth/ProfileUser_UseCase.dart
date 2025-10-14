
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PPROFILE_user_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/Auth/AuthProfileUser_RepositoryDomain.dart';

class ProfileUserUsecase {
  final AuthProfileUserRepositoryDomain repository;

  ProfileUserUsecase(this.repository);

  Future<Profile?> call(String id) async {
    return await repository.getUserProfile(userId: id);
  }
}
