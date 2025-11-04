import 'package:ezride/App/DOMAIN/Entities/empresas_entity.dart';

abstract class EmpresaRepositoryDomain {
  Future<Empresas> crearEmpresa(Map<String, dynamic> empresaData);
  Future<bool> actualizarRolUsuario(String userId, String nuevoRol);
  Future<List<Empresas>> obtenerEmpresasPorOwner(String ownerId);
}
