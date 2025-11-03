import 'dart:convert';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:ezride/Core/enums/enums.dart';

/// Modelo de datos para mapear los registros de la tabla `profiles`.
/// Incluye token opcional para manejo local de sesión.
class AuthProfilesUserModel extends Profile {
  final String? token; // Token solo local

  const AuthProfilesUserModel({
    required super.id,
    required super.role,
    super.displayName,
    super.phone,
    super.verificationStatus,
    super.passwd,
    super.duiNumber,
    super.licenseNumber,
    super.dateOfBirth,
    super.email,
    super.emailVerified,
    required super.createdAt,
    required super.updatedAt,
    this.token,
  });

  // ------------------- FROM MAP -------------------
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
      passwd: map['passwd'] as String?,
      duiNumber: map['dui_number'] as String?,
      licenseNumber: map['license_number'] as String?,
      dateOfBirth: map['date_of_birth'] is String
          ? DateTime.parse(map['date_of_birth'])
          : map['date_of_birth'] is DateTime
              ? map['date_of_birth']
              : null,
      email: map['email'] as String?,
      emailVerified: map['email_verified'] as bool? ?? false,
      createdAt: map['created_at'] is String
          ? DateTime.parse(map['created_at'])
          : map['created_at'],
      updatedAt: map['updated_at'] is String
          ? DateTime.parse(map['updated_at'])
          : map['updated_at'],
      token: map['token'] as String?,
    );
  }

  // ------------------- TO MAP -------------------
  @override
  Map<String, dynamic> toMap() {
    final map = {
      'id': id,
      'role': role.name,
      'display_name': displayName,
      'phone': phone,
      'verification_status': verificationStatus.name,
      'dui_number': duiNumber,
      'license_number': licenseNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'email': email,
      'email_verified': emailVerified,
      'passwd': passwd, // ✅ este faltaba
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (token != null) map['token'] = token;
    return map;
  }

  Map<String, dynamic> toDbMap({bool minimal = false}) {
    if (minimal) {
      return {
        'id': id,
        'role': role.name,
        'email': email,
        'passwd': passwd,
        'verification_status': verificationStatus.name,
        'email_verified': emailVerified,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
    } else {
      return toMap();
    }
  }

  // ------------------- COPYWITH -------------------
  AuthProfilesUserModel copyWith({
    String? id,
    UserRole? role,
    String? displayName,
    String? email,
    String? phone,
    VerificationStatus? verificationStatus,
    String? passwd,
    String? duiNumber,
    String? licenseNumber,
    DateTime? dateOfBirth,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? token,
  }) {
    return AuthProfilesUserModel(
      id: id ?? this.id,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      phone: phone ?? this.phone,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      passwd: passwd ?? this.passwd,
      duiNumber: duiNumber ?? this.duiNumber,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
    );
  }

  // ------------------- FROM ENTITY -------------------
  factory AuthProfilesUserModel.fromEntity(Profile entity, {String? token}) {
    return AuthProfilesUserModel(
      id: entity.id,
      role: entity.role,
      displayName: entity.displayName,
      phone: entity.phone,
      verificationStatus: entity.verificationStatus,
      passwd: entity.passwd,
      duiNumber: entity.duiNumber,
      licenseNumber: entity.licenseNumber,
      dateOfBirth: entity.dateOfBirth,
      email: entity.email,
      emailVerified: entity.emailVerified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      token: token,
    );
  }

  // ------------------- TO ENTITY -------------------
  Profile toEntity() {
    return Profile(
      id: id,
      role: role,
      displayName: displayName,
      phone: phone,
      verificationStatus: verificationStatus,
      email: email,
      passwd: passwd,
      duiNumber: duiNumber,
      licenseNumber: licenseNumber,
      dateOfBirth: dateOfBirth,
      emailVerified: emailVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() =>
      'AuthProfilesUserModel(id: $id, role: ${role.name}, displayName: $displayName, phone: $phone, verificationStatus: ${verificationStatus.name}, emailVerified: $emailVerified, token: $token)';
}
