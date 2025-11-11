import 'package:ezride/App/DOMAIN/Entities/rentas_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/rentas_repository_domain.dart';

class GetRentasByClienteUseCase {
  final RentaRepositoryDomain repository;

  GetRentasByClienteUseCase(this.repository);

  Future<List<Renta>> execute(String clienteId) async {
    return await repository.getRentasByCliente(clienteId);
  }
}