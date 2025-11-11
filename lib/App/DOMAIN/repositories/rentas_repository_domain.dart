import 'package:ezride/App/DOMAIN/Entities/rentas_entity.dart';
import 'package:ezride/Core/enums/enums.dart';

abstract class RentaRepositoryDomain {
  Future<Renta> createRenta(Renta renta);
  Future<List<Renta>> getRentasByCliente(String clienteId);
  Future<List<Renta>> getRentasByEmpresa(String empresaId);
  Future<List<Renta>> getRentasActivasByVehiculo(String vehiculoId);
  Future<Renta> updateRentaStatus(String rentaId, RentalStatus status);
  Future<Renta> getRentaById(String rentaId);
  Future<bool> cancelarRenta(String rentaId);
  Future<Renta> addPickupPhotos(String rentaId, List<String> photos);
  Future<Renta> addReturnPhotos(String rentaId, List<String> photos);
}