import '../../Entities (ordenarlas en base a los features)/Auth/user_entity.dart';
import '../../repositories/Auth/ProfileUser_RepositoryDomain.dart';

abstract class CallRegister {
  Future<Profile> call({
    required String email,
    required String password,
  });
}

class RegisterUseCases implements CallRegister {
  final ProfileUserRepositoryDomain repository;

  RegisterUseCases(this.repository);

  @override
  Future<Profile> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty ) {
      throw Exception('Email, password, and name must not be empty');
    }
    final user = await repository.registerUser(
      email: email,
      password: password,
    );
    return user;
  }
}
