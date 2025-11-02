import 'package:ezride/Core/enums/enums.dart';

/// Entidad base que representa la tabla `profiles` en la base de datos.
class Profile {
  final String id;
  final UserRole role;
  final String? displayName;
  final String? phone;
  final VerificationStatus verificationStatus;
  final String? email;
  final String? passwd;
  final String? duiNumber;
  final String? licenseNumber;
  final DateTime? dateOfBirth;
  final bool emailVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Profile({
    required this.id,
    this.role = UserRole.cliente,
    this.displayName,
    this.phone,
    this.verificationStatus = VerificationStatus.pendiente,
    this.email,
    this.passwd,
    this.duiNumber,
    this.licenseNumber,
    this.dateOfBirth,
    this.emailVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });

  Profile copyWith({
    String? id,
    UserRole? role,
    String? displayName,
    String? phone,
    VerificationStatus? verificationStatus,
    String? email,
    String? passwd,
    String? duiNumber,
    String? licenseNumber,
    DateTime? dateOfBirth,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Profile(
      id: id ?? this.id,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      email: email ?? this.email,
      passwd: passwd ?? this.passwd,
      duiNumber: duiNumber ?? this.duiNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
