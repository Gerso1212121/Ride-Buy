import 'package:ezride/Core/enums/enums.dart';

class Empresas {
  final String id;
  final String ownerId;
  final String nombre;
  final String nit;
  final String nrc;
  final String direccion;
  final String telefono;
  final String email;
  final double latitud;
  final double longitud;

  // ✅ nuevas columnas
  final String? imagenPerfil;
  final String? imagenBanner;

  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Empresas({
    required this.id,
    required this.ownerId,
    required this.nombre,
    required this.nit,
    required this.nrc,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.latitud,
    required this.longitud,

    // ✅ nuevas columnas
    this.imagenPerfil,
    this.imagenBanner,

    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
  });
}
