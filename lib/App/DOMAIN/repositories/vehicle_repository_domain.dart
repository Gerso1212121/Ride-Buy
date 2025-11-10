import '../Entities/vehicle_entity.dart';
import 'dart:io';

abstract class VehicleRepositoryDomain {
  Future<List<VehicleEntity>> searchVehicles({
    required String query,
    String? type,
    String? transmission,
    double? minPrice,
    double? maxPrice,
  });

  Future<List<VehicleEntity>> getRecommendedVehicles();

  // NUEVOS MÉTODOS
  Future<VehicleEntity> createVehicle({
    required String empresaId,
    required String titulo,
    required String marca,
    required String modelo,
    int? anio,
    required String placa,
    required double precioPorDia,
    required File imagenVehiculo,
    required File imagenPlaca,
    String? color,
    int? capacidad,
    String? transmision,
    String? combustible,
    int? kilometraje,
    int? puertas,
    String? duenoActual,
    String? soaNumber,
    DateTime? circulacionVence,
    DateTime? soaVence,
    bool? multasPendientes,
    String? insuranceProvider,
  });

  Future<List<VehicleEntity>> getVehiclesByEmpresa(String empresaId);
}
