import 'package:ezride/App/DOMAIN/Entities/Auth/REGISTER_PENDING_user_entity.dart';

/// 🧩 Modelo de datos que representa la tabla `register_pending`
///
/// Este modelo sirve para la capa de DATA y gestiona conversiones
/// entre mapas (de la base de datos) y entidades de dominio.
class AuthRegisterPendingModel extends RegisterPending {
  const AuthRegisterPendingModel({
    required super.id,
    required super.email,
    required super.passwd,
    required super.otpCode,
    required super.otpCreatedAt,
    required super.otpExpiresAt,
    required super.verified,
    required super.createdAt,
    required super.updatedAt,
  });

  // ----------------------------------------------------------
  // 🏗️ FROM MAP → Crea un modelo a partir de una fila SQL
  // ----------------------------------------------------------
  factory AuthRegisterPendingModel.fromMap(Map<String, dynamic> map) {
    return AuthRegisterPendingModel(
      id: map['id'].toString(),
      email: map['email'].toString(),
      passwd: map['passwd'].toString(),
      otpCode: map['otp_code'].toString(),
      otpCreatedAt: DateTime.parse(map['otp_created_at'].toString()),
      otpExpiresAt: DateTime.parse(map['otp_expires_at'].toString()),
      verified: map['verified'] == true || map['verified'] == 1,
      createdAt: DateTime.parse(map['created_at'].toString()),
      updatedAt: DateTime.parse(map['updated_at'].toString()),
    );
  }

  // ----------------------------------------------------------
  // 🗺️ TO MAP → Convierte el modelo a un mapa para enviar a la DB
  // ----------------------------------------------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'passwd': passwd,
      'otp_code': otpCode,
      'otp_created_at': otpCreatedAt.toIso8601String(),
      'otp_expires_at': otpExpiresAt.toIso8601String(),
      'verified': verified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ----------------------------------------------------------
  // 🧠 TO ENTITY → Convierte el modelo en una entidad pura de dominio
  // ----------------------------------------------------------
  RegisterPending toEntity() {
    return RegisterPending(
      id: id,
      email: email,
      passwd: passwd,
      otpCode: otpCode,
      otpCreatedAt: otpCreatedAt,
      otpExpiresAt: otpExpiresAt,
      verified: verified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // ----------------------------------------------------------
  // 🏗️ FROM ENTITY → Crea un modelo desde una entidad del dominio
  // ----------------------------------------------------------
  factory AuthRegisterPendingModel.fromEntity(RegisterPending entity) {
    return AuthRegisterPendingModel(
      id: entity.id,
      email: entity.email,
      passwd: entity.passwd,
      otpCode: entity.otpCode,
      otpCreatedAt: entity.otpCreatedAt,
      otpExpiresAt: entity.otpExpiresAt,
      verified: entity.verified,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // ----------------------------------------------------------
  // 🔁 COPYWITH → Crea una copia modificada del modelo
  // ----------------------------------------------------------
  AuthRegisterPendingModel copyWith({
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
    return AuthRegisterPendingModel(
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
}
