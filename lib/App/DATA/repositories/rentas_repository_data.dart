import 'package:ezride/App/DATA/datasources/Auth/rentas_remote_datasource.dart';
import 'package:ezride/App/DATA/datasources/Auth/vehicle_remote_datasource.dart'; // ✅ Agregar esta importación
import 'package:ezride/App/DATA/models/rentas_model.dart';
import 'package:ezride/App/DOMAIN/Entities/rentas_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/rentas_repository_domain.dart';
import 'package:ezride/Core/enums/enums.dart';

class RentaRepositoryData implements RentaRepositoryDomain {
  final RentaRemoteDataSource remoteDataSource;
  final VehicleRemoteDataSource vehicleDataSource; // ✅ Agregar vehicleDataSource

  RentaRepositoryData(this.remoteDataSource, this.vehicleDataSource); // ✅ Actualizar constructor

  @override
  Future<Renta> createRenta(Renta renta) async {
    // ✅ VERIFICAR DISPONIBILIDAD ANTES DE CREAR LA RENTA
    await _verificarDisponibilidadVehiculo(
      renta.vehiculoId,
      renta.fechaInicioRenta,
      renta.fechaEntregaVehiculo,
    );

    final rentaModel = RentaModel.fromEntity(renta);
    final createdRenta = await remoteDataSource.createRenta(rentaModel);
    
    // ✅ ACTUALIZAR ESTADO DEL VEHÍCULO A "reservado" si es una reserva
    if (renta.tipo == RentaTipo.reserva) {
      await vehicleDataSource.actualizarEstadoVehiculo(
        renta.vehiculoId, 
        'reservado'
      );
    }
    
    return createdRenta;
  }

  // ✅ MÉTODO PRIVADO PARA VERIFICAR DISPONIBILIDAD
  Future<void> _verificarDisponibilidadVehiculo(
    String vehiculoId,
    DateTime fechaInicio,
    DateTime fechaFin,
  ) async {
    try {
      // 1. Verificar estado general del vehículo
      final estadoVehiculo = await vehicleDataSource.getEstadoVehiculo(vehiculoId);
      
      if (estadoVehiculo != 'disponible') {
        throw Exception('El vehículo no está disponible para renta. Estado actual: $estadoVehiculo');
      }

      // 2. Verificar que no haya rentas solapadas
      final disponible = await vehicleDataSource.verificarDisponibilidadVehiculo(
        vehiculoId,
        fechaInicio,
        fechaFin,
      );

      if (!disponible) {
        throw Exception('El vehículo ya tiene rentas/reservas en las fechas seleccionadas');
      }

      print('✅ Vehículo disponible para las fechas seleccionadas');
    } catch (e) {
      print('❌ Error en verificación de disponibilidad: $e');
      rethrow;
    }
  }

  // ✅ MÉTODO PARA CANCELAR RENTA Y LIBERAR VEHÍCULO
  @override
  Future<bool> cancelarRenta(String rentaId) async {
    try {
      // 1. Obtener información de la renta
      final renta = await getRentaById(rentaId);
      
      // 2. Actualizar estado de la renta a cancelada
      await remoteDataSource.updateRentaStatus(rentaId, RentalStatus.cancelada.name);
      
      // 3. Liberar el vehículo (cambiar estado a disponible)
      await vehicleDataSource.actualizarEstadoVehiculo(
        renta.vehiculoId, 
        'disponible'
      );
      
      return true;
    } catch (e) {
      print('❌ Error cancelando renta: $e');
      return false;
    }
  }

  // ✅ MÉTODO PARA FINALIZAR RENTA Y LIBERAR VEHÍCULO
  Future<bool> finalizarRenta(String rentaId) async {
    try {
      // 1. Obtener información de la renta
      final renta = await getRentaById(rentaId);
      
      // 2. Actualizar estado de la renta a finalizada
      await remoteDataSource.updateRentaStatus(rentaId, RentalStatus.finalizada.name);
      
      // 3. Liberar el vehículo
      await vehicleDataSource.actualizarEstadoVehiculo(
        renta.vehiculoId, 
        'disponible'
      );
      
      return true;
    } catch (e) {
      print('❌ Error finalizando renta: $e');
      return false;
    }
  }

  // 🎯 LOS DEMÁS MÉTODOS PERMANECEN EXACTAMENTE IGUAL
  @override
  Future<List<Renta>> getRentasByCliente(String clienteId) async {
    final rentas = await remoteDataSource.getRentasByCliente(clienteId);
    return rentas;
  }

  @override
  Future<List<Renta>> getRentasByEmpresa(String empresaId) async {
    final rentas = await remoteDataSource.getRentasByEmpresa(empresaId);
    return rentas;
  }

  @override
  Future<List<Renta>> getRentasActivasByVehiculo(String vehiculoId) async {
    final rentas = await remoteDataSource.getRentasActivasByVehiculo(vehiculoId);
    return rentas;
  }

  @override
  Future<Renta> getRentaById(String rentaId) async {
    final renta = await remoteDataSource.getRentaById(rentaId);
    return renta;
  }

  @override
  Future<Renta> updateRentaStatus(String rentaId, RentalStatus status) async {
    final renta = await remoteDataSource.updateRentaStatus(rentaId, status.name);
    return renta;
  }

  @override
  Future<Renta> addPickupPhotos(String rentaId, List<String> photos) async {
    final renta = await remoteDataSource.addPickupPhotos(rentaId, photos);
    return renta;
  }

  @override
  Future<Renta> addReturnPhotos(String rentaId, List<String> photos) async {
    final renta = await remoteDataSource.addReturnPhotos(rentaId, photos);
    return renta;
  }
}