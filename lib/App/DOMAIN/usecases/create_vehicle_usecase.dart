import 'package:ezride/App/DATA/models/Vehiculo_model.dart';
import 'package:ezride/App/DOMAIN/Entities/VEHICLE_ENTITY.dart';
import 'package:ezride/App/DOMAIN/repositories/vehicle_repository_domain.dart';
import 'dart:io';

class CreateVehicleUseCase {
  final VehicleRepositoryDomain repository;

  CreateVehicleUseCase(this.repository);

  Future<VehicleModel> execute({
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
  }) async {
    return await repository.createVehicle(
      empresaId: empresaId,
      titulo: titulo,
      marca: marca,
      modelo: modelo,
      anio: anio,
      placa: placa,
      precioPorDia: precioPorDia,
      imagenVehiculo: imagenVehiculo,
      imagenPlaca: imagenPlaca,
      color: color,
      tipo: tipo, // ✅ PASAR ESTE PARÁMETRO
      capacidad: capacidad,
      transmision: transmision,
      combustible: combustible,
      kilometraje: kilometraje,
      puertas: puertas,
      duenoActual: duenoActual,
      soaNumber: soaNumber,
      circulacionVence: circulacionVence,
      soaVence: soaVence,
      multasPendientes: multasPendientes,
      insuranceProvider: insuranceProvider,
    );
  }
}