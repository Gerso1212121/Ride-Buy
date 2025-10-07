import 'package:ezride/Core/enums/enums.dart';

class Profile {
  final String id;
  final UserRole role;
  final String? displayName;
  final String? phone;
  final String country;
  final VerificationStatus verificationStatus;
  final String? duiNumber;
  final String? licenseNumber;
  final DateTime? dateOfBirth;
  final double verificationScore;
  final DateTime createdAt;
  final DateTime updatedAt;

  Profile({
    required this.id,
    required this.role,
    this.displayName,
    this.phone,
    this.country = 'SV',
    this.verificationStatus = VerificationStatus.pendiente,
    this.duiNumber,
    this.licenseNumber,
    this.dateOfBirth,
    this.verificationScore = 0,
    required this.createdAt,
    required this.updatedAt,
  });
}
