import 'package:ezride/App/DOMAIN/Entities/empresas_entity.dart';
import 'package:ezride/Core/enums/enums.dart';

class EmpresasModel extends Empresas {
  EmpresasModel({
    required super.id,
    required super.ownerId,
    required super.nombre,
    required super.nit,
    required super.ncr,
    required super.direccion,
    required super.telefono,
    required super.email,
    required super.verificationStatus,
    required super.createdAt,
    required super.updatedAt,
  });

  /// 🔁 Convierte una fila del query a modelo
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
      verificationStatus: _parseStatus(map['estado_verificacion']),
      createdAt: DateTime.parse(map['created_at'].toString()),
      updatedAt: DateTime.parse(map['updated_at'].toString()),
    );
  }

  static VerificationStatus _parseStatus(String? value) {
    switch (value) {
      case 'verificado':
        return VerificationStatus.verificado;
      case 'rechazado':
        return VerificationStatus.rechazado;
      // Si tu enum NO tiene 'en_revision', usamos pendiente
      default:
        return VerificationStatus.pendiente;
    }
  }
}
