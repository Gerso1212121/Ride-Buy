import '../../Entities (ordenarlas en base a los features)/Auth/user_entity.dart';
import '../../repositories/Auth/ProfileUser_RepositoryDomain.dart';

abstract class CallRegister {
  Future<Profile> call({
    required String email,
    required String password,
    String? emailRedirectTo,
  });
}

class RegisterUseCases implements CallRegister {
  final ProfileUserRepositoryDomain repository;

  RegisterUseCases(this.repository);

  @override
  Future<Profile> call({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('El correo y la contraseña son obligatorios.');
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      throw Exception('Formato de correo electrónico inválido.');
    }

    final redirectUrl =
        emailRedirectTo ?? 'https://consult-al2i.onrender.com/auth/verify';

    return await repository.registerUser(
      email: email,
      password: password,
      emailRedirectTo: redirectUrl,
    );
  }
}
