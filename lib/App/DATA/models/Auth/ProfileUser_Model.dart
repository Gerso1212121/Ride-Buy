import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PPROFILE_user_entity.dart';
import 'package:ezride/Core/enums/enums.dart';

class ProfileUserModel extends Profile {
  ProfileUserModel({
    required super.id,
    required super.role,
    super.displayName,
    super.phone,
    super.country,
    super.verificationStatus,
    super.duiNumber,
    super.licenseNumber,
    super.dateOfBirth,
    super.verificationScore,
    required super.createdAt,
    required super.updatedAt,
  });

  ///Convertimos un JSON recibido desde SUPABASE/LOGICA a un objeto de tipo ProfileModel
  factory ProfileUserModel.fromJson(Map<String, dynamic> json) {
    return ProfileUserModel(
      id: json['id'],
      role: UserRole.values.byName(json['role'] as String),
      displayName: json['display_name'] as String?,
      phone: json['phone'] as String?,
      country: json['country'] as String? ?? 'SV',
      verificationStatus: VerificationStatus.values
          .byName(json['verification_status'] as String? ?? 'pendiente'),
      duiNumber: json['dui_number'] as String?,
      licenseNumber: json['license_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      verificationScore: (json['verification_score'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  ///Convertimos un objeto de tipo ProfileModel a un JSON para enviarlo a SUPABASE/LOGICA
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'role': role.name,
      'display_name': displayName,
      'phone': phone,
      'country': country,
      'verification_status': verificationStatus.name,
      'dui_number': duiNumber,
      'license_number': licenseNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'verification_score': verificationScore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
