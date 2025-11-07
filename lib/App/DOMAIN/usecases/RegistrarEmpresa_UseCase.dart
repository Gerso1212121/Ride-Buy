import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/App/DOMAIN/repositories/EmpresaRepository_domain.dart';

class RegistrarEmpresaUseCase {
  final EmpresaRepositoryDomain repository;

  RegistrarEmpresaUseCase(this.repository);

  Future<EmpresasModel> execute({
    required String ownerId,
    required String nombre,
    required String nit,
    required String nrc,
    required String direccion,
    required String telefono,
    String? email,
    required double latitud,  // Nuevo parámetro
    required double longitud, // Nuevo parámetro
  }) async {
    // Crear la empresa en el repositorio (retorna una instancia de Empresas)
    final empresa = await repository.crearEmpresa({
      'owner_id': ownerId,
      'nombre': nombre,
      'nit': nit,
      'nrc': nrc,
      'direccion': direccion,
      'telefono': telefono,
      'email': email ?? '',
      'latitud': latitud,  // Agregar latitud
      'longitud': longitud, // Agregar longitud
    });

    // Convertir la empresa de tipo 'Empresas' a 'EmpresasModel'
    final empresaModel = EmpresasModel.fromEmpresas(empresa);

    // Actualizar el rol del usuario
    await repository.actualizarRolUsuario(ownerId, 'empresario');

    // Devolver la empresa como 'EmpresasModel'
    return empresaModel;
  }
}
