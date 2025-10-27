import 'dart:convert';

import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';
import 'package:ezride/Core/enums/enums.dart';

/// Modelo de datos para mapear los registros de la tabla `profiles`.
class AuthProfilesUserModel extends Profile {
  const AuthProfilesUserModel({
    required super.id,
    required super.role,
    super.displayName,
    super.phone,
    super.verificationStatus,
    super.duiNumber,
    super.licenseNumber,
    super.dateOfBirth,
    super.emailVerified,
    required super.createdAt,
    required super.updatedAt,
  });
  // ---------------------------------------------------------------------------
  // 🏗️ FACTORY: Convertir desde Map (por ejemplo, datos del backend o DB)
  // ---------------------------------------------------------------------------
  factory AuthProfilesUserModel.fromMap(Map<String, dynamic> map) {
    UserRole parseRole(String? value) {
      switch (value) {
        case 'cliente':
          return UserRole.cliente;
        case 'empleado':
          return UserRole.empleado;
        case 'empresario':
          return UserRole.empresario;
        case 'soporte':
          return UserRole.soporte;
        case 'admin':
          return UserRole.admin;
        default:
          return UserRole.cliente;
      }
    }

    VerificationStatus parseVerificationStatus(String? value) {
      switch (value) {
        case 'pendiente':
          return VerificationStatus.pendiente;
        case 'en_revision':
          return VerificationStatus.enRevision;
        case 'verificado':
          return VerificationStatus.verificado;
        case 'rechazado':
          return VerificationStatus.rechazado;
        default:
          return VerificationStatus.pendiente;
      }
    }

    return AuthProfilesUserModel(
      id: map['id'] as String,
      role: parseRole(map['role'] as String?),
      displayName: map['display_name'] as String?,
      phone: map['phone'] as String?,
      verificationStatus:
          parseVerificationStatus(map['verification_status'] as String?),
      duiNumber: map['dui_number'] as String?,
      licenseNumber: map['license_number'] as String?,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'] as String)
          : null,
      emailVerified: map['email_verified'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
// ---------------------------------------------------------------------------
  // 🔁 CONVERSIÓN A MAP (para enviar a PostgreSQL o APIs REST)
  // ---------------------------------------------------------------------------
  Map<String, dynamic> toMap() => {
        'id': id,
        'role': role.name,
        'display_name': displayName,
        'phone': phone,
        'verification_status': verificationStatus.name,
        'dui_number': duiNumber,
        'license_number': licenseNumber,
        'date_of_birth': dateOfBirth?.toIso8601String(),
        'email_verified': emailVerified,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
  // ---------------------------------------------------------------------------
  // 🌐 JSON CONVERSIÓN
  // ---------------------------------------------------------------------------
  factory AuthProfilesUserModel.fromJson(String source) =>
      AuthProfilesUserModel.fromMap(json.decode(source));

  @override
  Map<String, dynamic> toJson() => toMap();
  // ---------------------------------------------------------------------------
  // 🧩 COPYWITH: Para actualizaciones parciales (ej. editar perfil)
  // ---------------------------------------------------------------------------
  @override
  AuthProfilesUserModel copyWith({
    String? id,
    UserRole? role,
    String? displayName,
    String? phone,
    VerificationStatus? verificationStatus,
    String? duiNumber,
    String? licenseNumber,
    DateTime? dateOfBirth,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AuthProfilesUserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      duiNumber: duiNumber ?? this.duiNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  // ---------------------------------------------------------------------------
  // 🧠 DEBUG / LOG
  // ---------------------------------------------------------------------------
  @override
  String toString() =>
      'AuthProfilesUserModel(id: $id, role: ${role.name}, displayName: $displayName, phone: $phone, verificationStatus: ${verificationStatus.name}, duiNumber: $duiNumber, licenseNumber: $licenseNumber, emailVerified: $emailVerified)';
}
