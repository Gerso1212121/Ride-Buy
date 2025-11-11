import 'package:ezride/App/DOMAIN/Entities/rentas_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/rentas_repository_domain.dart';

class GetRentasByEmpresaUseCase {
  final RentaRepositoryDomain repository;

  GetRentasByEmpresaUseCase(this.repository);

  Future<List<Renta>> execute(String empresaId) async {
    return await repository.getRentasByEmpresa(empresaId);
  }
}