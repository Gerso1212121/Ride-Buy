/// Entidad base que representa la tabla `register_pending` en la base de datos.
///
/// Se usa para manejar registros temporales antes de confirmar el OTP.
class RegisterPending {
  final String id;
  final String email;
  final String passwd;
  final String otpCode;
  final DateTime otpCreatedAt;
  final DateTime otpExpiresAt;
  final bool verified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RegisterPending({
    required this.id,
    required this.email,
    required this.passwd,
    required this.otpCode,
    required this.otpCreatedAt,
    required this.otpExpiresAt,
    this.verified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// 🔁 Crea una nueva copia del objeto modificando solo los campos necesarios.
  RegisterPending copyWith({
    String? id,
    String? email,
    String? passwd,
    String? otpCode,
    DateTime? otpCreatedAt,
    DateTime? otpExpiresAt,
    bool? verified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RegisterPending(
      id: id ?? this.id,
      email: email ?? this.email,
      passwd: passwd ?? this.passwd,
      otpCode: otpCode ?? this.otpCode,
      otpCreatedAt: otpCreatedAt ?? this.otpCreatedAt,
      otpExpiresAt: otpExpiresAt ?? this.otpExpiresAt,
      verified: verified ?? this.verified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// ✅ Indica si el OTP sigue siendo válido.
  bool get isOtpValid => DateTime.now().isBefore(otpExpiresAt);

  /// 🚫 Indica si el OTP ha expirado.
  bool get isExpired => DateTime.now().isAfter(otpExpiresAt);

  /// 🔓 Indica si el registro puede ser migrado a `profiles`.
  bool get isReadyToRegister => verified && !isExpired;
}
