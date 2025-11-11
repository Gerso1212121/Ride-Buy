import 'package:ezride/App/DATA/models/Vehiculo_model.dart';
import '../Entities/VEHICLE_ENTITY.dart';
import 'dart:io';

abstract class VehicleRepositoryDomain {
  Future<List<VehicleModel>> searchVehicles({
    required String query,
    String? type,
    String? transmission,
    double? minPrice,
    double? maxPrice,
  });

  Future<List<VehicleModel>> getRecommendedVehicles();

  // NUEVOS MÉTODOS - ACTUALIZADO
  Future<VehicleModel> createVehicle({
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
    String? tipo, // ✅ AGREGAR ESTE PARÁMETRO
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