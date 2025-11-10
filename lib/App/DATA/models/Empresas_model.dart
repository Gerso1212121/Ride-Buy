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

      // ✅ nuevas columnas
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

      // ✅ nuevas columnas
      'imagen_perfil': imagenPerfil,
      'imagen_banner': imagenBanner,

      'estado_verificacion': verificationStatus.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
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
}
