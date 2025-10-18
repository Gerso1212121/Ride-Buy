class AuthResult {
  final bool ok;
  final String? message;
  final String? error;
  final dynamic data;
  final bool verified;

  const AuthResult._({
    required this.ok,
    this.message,
    this.error,
    this.data,
    this.verified = false,
  });

  factory AuthResult.success(dynamic data, [String? message]) {
    return AuthResult._(ok: true, data: data, message: message);
  }

  factory AuthResult.failure(String error) {
    return AuthResult._(ok: false, error: error);
  }
}
