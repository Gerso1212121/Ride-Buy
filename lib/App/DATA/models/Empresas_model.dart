import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/App/DOMAIN/Entities/empresas_entity.dart';

class EmpresasModel extends Empresas {
  EmpresasModel({
    required String id,
    required String ownerId,
    required String nombre,
    required String nit,
    required String ncr,
    required String direccion,
    required String telefono,
    required String email,
    required double latitud,  // Nueva propiedad
    required double longitud, // Nueva propiedad
    VerificationStatus verificationStatus = VerificationStatus.pendiente,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          ownerId: ownerId,
          nombre: nombre,
          nit: nit,
          ncr: ncr,
          direccion: direccion,
          telefono: telefono,
          email: email,
          latitud: latitud,
          longitud: longitud,
          verificationStatus: verificationStatus,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  // Método para convertir de Empresas a EmpresasModel
  factory EmpresasModel.fromEmpresas(Empresas empresa) {
    return EmpresasModel(
      id: empresa.id,
      ownerId: empresa.ownerId,
      nombre: empresa.nombre,
      nit: empresa.nit,
      ncr: empresa.ncr,
      direccion: empresa.direccion,
      telefono: empresa.telefono,
      email: empresa.email,
      latitud: empresa.latitud,
      longitud: empresa.longitud,
      verificationStatus: empresa.verificationStatus,
      createdAt: empresa.createdAt,
      updatedAt: empresa.updatedAt,
    );
  }

  /// Convierte un objeto `Map` en un modelo `EmpresasModel`
  factory EmpresasModel.fromMap(Map<String, dynamic> map) {
    return EmpresasModel(
      id: map['id'] as String,
      ownerId: map['owner_id'] as String,
      nombre: map['nombre'] ?? '',
      nit: map['nit'] ?? '',
      ncr: map['nrc'] ?? '',
      direccion: map['direccion'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
      latitud: map['latitud'] as double,
      longitud: map['longitud'] as double,
      verificationStatus: _parseStatus(map['estado_verificacion']),
      createdAt: DateTime.parse(map['created_at'].toString()),
      updatedAt: DateTime.parse(map['updated_at'].toString()),
    );
  }

  // Método para enviar los datos a la base de datos
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'owner_id': ownerId,
      'nombre': nombre,
      'nit': nit,
      'ncr': ncr,
      'direccion': direccion,
      'telefono': telefono,
      'email': email,
      'latitud': latitud,
      'longitud': longitud,
      'estado_verificacion': verificationStatus.toString().split('.').last,
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
      default:
        return VerificationStatus.pendiente;
    }
  }
}

