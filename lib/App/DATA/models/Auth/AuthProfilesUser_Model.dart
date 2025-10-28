import 'dart:convert';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/PROFILE_user_entity.dart';
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
      passwd: map['password'] as String?,
      duiNumber: map['dui_number'] as String?,
      licenseNumber: map['license_number'] as String?,
      dateOfBirth: map['date_of_birth'] != null
          ? DateTime.parse(map['date_of_birth'] as String)
          : null,
      emailVerified: map['email_verified'] as bool? ?? false,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      token: map['token'] as String?, // solo local
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
      'password': passwd,
      'dui_number': duiNumber,
      'license_number': licenseNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'email_verified': emailVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
    if (token != null) map['token'] = token;
    return map;
  }

  // ------------------- JSON -------------------
  factory AuthProfilesUserModel.fromJson(String source) =>
      AuthProfilesUserModel.fromMap(json.decode(source));

  @override
  Map<String, dynamic> toJson() => toMap();

  // ------------------- COPYWITH -------------------
  AuthProfilesUserModel copyWith({
    String? id,
    UserRole? role,
    String? displayName,
    String? email, // ⚠ debe estar para coincidir con la base
    String? phone,
    VerificationStatus? verificationStatus,
    String? passwd,
    String? duiNumber,
    String? licenseNumber,
    DateTime? dateOfBirth,
    bool? emailVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? token, // nuevo parámetro exclusivo del modelo
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
      emailVerified: emailVerified ?? this.emailVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      token: token ?? this.token,
    );
  }

  /// 🧩 Convierte una entidad `Profile` a un modelo `AuthProfilesUserModel`
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
      emailVerified: entity.emailVerified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      token: token, // opcional, útil para guardar sesión local
    );
  }

  @override
  String toString() =>
      'AuthProfilesUserModel(id: $id, role: ${role.name}, displayName: $displayName, phone: $phone, verificationStatus: ${verificationStatus.name}, emailVerified: $emailVerified, token: $token)';
}
