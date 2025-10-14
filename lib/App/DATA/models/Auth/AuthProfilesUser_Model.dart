import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PPROFILE_user_entity.dart';
import 'package:ezride/Core/enums/enums.dart';

class AuthProfilesUserModel extends Profile {
  AuthProfilesUserModel({
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

  // Mapeo desde Supabase o JSON
  factory AuthProfilesUserModel.fromMap(Map<String, dynamic> map) {
    UserRole parseRole(String? value) {
      switch (value) {
        case 'cliente': return UserRole.cliente;
        case 'empleado': return UserRole.empleado;
        case 'empresario': return UserRole.empresario;
        case 'soporte': return UserRole.soporte;
        case 'admin': return UserRole.admin;
        default: return UserRole.cliente;
      }
    }

    VerificationStatus parseVerificationStatus(String? value) {
      switch (value) {
        case 'pendiente': return VerificationStatus.pendiente;
        case 'en_revision': return VerificationStatus.enRevision;
        case 'verificado': return VerificationStatus.verificado;
        case 'rechazado': return VerificationStatus.rechazado;
        default: return VerificationStatus.pendiente;
      }
    }

    return AuthProfilesUserModel(
      id: map['id'] as String,
      role: parseRole(map['role'] as String?),
      displayName: map['display_name'] as String?,
      phone: map['phone'] as String?,
      country: map['country'] as String? ?? 'SV',
      verificationStatus: parseVerificationStatus(map['verification_status'] as String?),
      duiNumber: map['dui_number'] as String?,
      licenseNumber: map['license_number'] as String?,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'] as String)
          : null,
      verificationScore: (map['verification_score'] as num?)?.toDouble() ?? 0,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() => {
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
