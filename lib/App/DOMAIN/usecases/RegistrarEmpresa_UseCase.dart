import 'package:ezride/App/DOMAIN/Entities/empresas_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/EmpresaRepository_domain.dart';

class RegistrarEmpresaUseCase {
  final EmpresaRepositoryDomain repository;

  RegistrarEmpresaUseCase(this.repository);

  Future<Empresas> execute({
    required String ownerId,
    required String nombre,
    required String nit,
    required String nrc,
    required String direccion,
    required String telefono,
    String? email,
  }) async {
    final empresa = await repository.crearEmpresa({
      'owner_id': ownerId,
      'nombre': nombre,
      'nit': nit,
      'nrc': nrc,
      'direccion': direccion,
      'telefono': telefono,
      'email': email ?? '',
    });

    await repository.actualizarRolUsuario(ownerId, 'empresario');
    return empresa;
  }
}
