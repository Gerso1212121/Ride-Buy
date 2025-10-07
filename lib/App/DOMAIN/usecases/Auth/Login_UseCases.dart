import '../../Entities (ordenarlas en base a los features)/Auth/user_entity.dart';
import '../../repositories/Auth/ProfileUser_RepositoryDomain.dart';

abstract class CallLogin {
  Future<Profile> call({
    required String email,
    required String password,
  });
}

class LoginUseCases implements CallLogin {
  final ProfileUserRepositoryDomain repository;

  LoginUseCases(this.repository);

  @override
  Future<Profile> call({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email and password must not be empty');
    }
    final user = await repository.loginUser(
      email: email,
      password: password,
    );
    return user;
  }
}
