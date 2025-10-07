class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}

class UserNotFoundException extends AuthException {
  UserNotFoundException() : super('Usuario no encontrado.');
}

class WrongPasswordException extends AuthException {
  WrongPasswordException() : super('Contraseña incorrecta.');
}

class EmailAlreadyInUseException extends AuthException {
  EmailAlreadyInUseException() : super('El correo electrónico ya está en uso.');
}

class WeakPasswordException extends AuthException {
  WeakPasswordException() : super('La contraseña es demasiado débil.');
}

class InvalidEmailException extends AuthException {
  InvalidEmailException() : super('El correo electrónico no es válido.');
}

class NetworkException extends AuthException {
  NetworkException() : super('Error de red. Por favor, inténtalo de nuevo.');
}

class UnknownAuthException extends AuthException {
  UnknownAuthException() : super('Ocurrió un error desconocido.');
}
