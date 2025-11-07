import 'package:ezride/Core/enums/enums.dart';

class Empresas {
  final String id;
  final String ownerId;
  final String nombre;
  final String nit;
  final String ncr;
  final String direccion;
  final String telefono;
  final String email;
  final double latitud;
  final double longitud;
  final VerificationStatus verificationStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  Empresas({
    required this.id,
    required this.ownerId,
    required this.nombre,
    required this.nit,
    required this.ncr,
    required this.direccion,
    required this.telefono,
    required this.email,
    required this.latitud,
    required this.longitud,
    required this.verificationStatus,
    required this.createdAt,
    required this.updatedAt,
  });
}
