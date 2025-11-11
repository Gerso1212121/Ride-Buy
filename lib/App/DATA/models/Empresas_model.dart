import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/App/DOMAIN/Entities/empresas_entity.dart';

class EmpresasModel extends Empresas {
  final String? imagenPerfil;
  final String? imagenBanner;

  EmpresasModel({
    required String id,
    required String ownerId,
    required String nombre,
    required String nit,
    required String nrc,
    required String direccion,
    required String telefono,
    required String email,
    required double latitud,
    required double longitud,
    this.imagenPerfil,
    this.imagenBanner,
    VerificationStatus verificationStatus = VerificationStatus.pendiente,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          ownerId: ownerId,
          nombre: nombre,
          nit: nit,
          nrc: nrc,
          direccion: direccion,
          telefono: telefono,
          email: email,
          latitud: latitud,
          longitud: longitud,
          imagenPerfil: imagenPerfil,
          imagenBanner: imagenBanner,
          verificationStatus: verificationStatus,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  // ✅ MÉTODO FALTANTE: fromJson
  factory EmpresasModel.fromJson(Map<String, dynamic> json) {
    return EmpresasModel(
      id: json['id']?.toString() ?? '',
      ownerId: json['owner_id']?.toString() ?? '',
      nombre: json['nombre']?.toString() ?? '',
      nit: json['nit']?.toString() ?? '',
      nrc: json['nrc']?.toString() ?? '',
      direccion: json['direccion']?.toString() ?? '',
      telefono: json['telefono']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      latitud: _parseDouble(json['latitud']),
      longitud: _parseDouble(json['longitud']),
      imagenPerfil: json['imagen_perfil']?.toString(),
      imagenBanner: json['imagen_banner']?.toString(),
      verificationStatus: _parseStatus(json['estado_verificacion']),
      createdAt: _parseDateTime(json['created_at']),
      updatedAt: _parseDateTime(json['updated_at']),
    );
  }

  factory EmpresasModel.fromMap(Map<String, dynamic> map) {
    return EmpresasModel(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      nombre: map['nombre'] ?? '',
      nit: map['nit'] ?? '',
      nrc: map['nrc'] ?? '',
      direccion: map['direccion'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
      latitud: (map['latitud'] ?? 0).toDouble(),
      longitud: (map['longitud'] ?? 0).toDouble(),
      imagenPerfil: map['imagen_perfil'],
      imagenBanner: map['imagen_banner'],
      verificationStatus: _parseStatus(map['estado_verificacion']),
      createdAt: DateTime.tryParse(map['created_at'].toString()) ??
          DateTime.now(),
      updatedAt: DateTime.tryParse(map['updated_at'].toString()) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'nombre': nombre,
      'nit': nit,
      'nrc': nrc,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'latitud': latitud,
      'longitud': longitud,
      'imagen_perfil': imagenPerfil,
      'imagen_banner': imagenBanner,
      'estado_verificacion': verificationStatus.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ✅ MÉTODO FALTANTE: toJson
  Map<String, dynamic> toJson() {
    return toMap();
  }

  // ✅ MÉTODOS AUXILIARES PARA PARSING SEGURO
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  static VerificationStatus _parseStatus(String? value) {
    switch (value) {
      case 'verificado':
        return VerificationStatus.verificado;
      case 'rechazado':
        return VerificationStatus.rechazado;
      case 'en_revision':
        return VerificationStatus.enRevision;
      default:
        return VerificationStatus.pendiente;
    }
  }

  // ✅ MÉTODO PARA CREAR COPIA (ÚTIL PARA INMUTABILIDAD)
  EmpresasModel copyWith({
    String? id,
    String? ownerId,
    String? nombre,
    String? nit,
    String? nrc,
    String? direccion,
    String? telefono,
    String? email,
    double? latitud,
    double? longitud,
    String? imagenPerfil,
    String? imagenBanner,
    VerificationStatus? verificationStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmpresasModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      nombre: nombre ?? this.nombre,
      nit: nit ?? this.nit,
      nrc: nrc ?? this.nrc,
      direccion: direccion ?? this.direccion,
      telefono: telefono ?? this.telefono,
      email: email ?? this.email,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      imagenPerfil: imagenPerfil ?? this.imagenPerfil,
      imagenBanner: imagenBanner ?? this.imagenBanner,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // ✅ MÉTODO PARA CONVERTIR A STRING (DEBUG)
  @override
  String toString() {
    return 'EmpresasModel{id: $id, nombre: $nombre, direccion: $direccion, telefono: $telefono, email: $email, verificationStatus: $verificationStatus}';
  }
}