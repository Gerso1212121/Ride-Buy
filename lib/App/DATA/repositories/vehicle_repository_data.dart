import 'package:ezride/App/DATA/datasources/Auth/vehicle_remote_datasource.dart';
import 'package:ezride/App/DOMAIN/Entities/vehicle_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/vehicle_repository_domain.dart';
import 'package:ezride/App/DATA/models/Vehiculo_model.dart';
import 'package:ezride/Services/api/azure_validator_service.dart';
import 'package:ezride/Services/api/s3_service.dart';
import 'dart:io';

class VehicleRepositoryData implements VehicleRepositoryDomain {
  final VehicleRemoteDataSource remote;

  VehicleRepositoryData(this.remote);

  @override
  Future<List<VehicleEntity>> searchVehicles({
    required String query,
    String? type,
    String? transmission,
    double? minPrice,
    double? maxPrice,
  }) {
    return remote.searchVehicles(
      query: query,
      type: type,
      transmission: transmission,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  @override
  Future<List<VehicleEntity>> getRecommendedVehicles() {
    return remote.getRecommendedVehicles();
  }

  @override
  Future<List<VehicleEntity>> getVehiclesByEmpresa(String empresaId) {
    return remote.getVehiclesByEmpresa(empresaId);
  }

  @override
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
  }) async {
    try {
      print('🚀 Iniciando creación de vehículo con validación IA...');

      // 1. ✅ VALIDACIÓN CON AZURE GPT-4o
      print('📸 Validando imágenes con Azure GPT-4o...');
      final validationResult =
          await AzureValidatorService.validateVehicleImages(
        vehicleImage: imagenVehiculo,
        plateImage: imagenPlaca,
        mode: 'estricto', // Puedes hacerlo configurable
      );

      if (!validationResult['valido']) {
        throw Exception('❌ Validación fallida: ${validationResult['razon']}');
      }

      print('✅ Imágenes validadas correctamente por IA');

      // 2. ✅ SUBIR IMÁGENES A S3
      print('☁️ Subiendo imágenes a S3...');

      final vehicleImageKey =
          'vehicles/${DateTime.now().millisecondsSinceEpoch}_vehicle.jpg';
      final plateImageKey =
          'vehicles/${DateTime.now().millisecondsSinceEpoch}_plate.jpg';

      // Subir imagen del vehículo
      final vehicleUploadResult = await S3Service.uploadImage(
        imageFile: imagenVehiculo,
        fileName: vehicleImageKey,
        folder: 'vehicles',
      );

      // Subir imagen de la placa
      final plateUploadResult = await S3Service.uploadImage(
        imageFile: imagenPlaca,
        fileName: plateImageKey,
        folder: 'vehicles',
      );

      final vehicleImageUrl = S3Service.getPublicUrl(vehicleImageKey);
      final plateImageUrl = S3Service.getPublicUrl(plateImageKey);

      print('✅ Imágenes subidas a S3: $vehicleImageUrl, $plateImageUrl');

      // 3. ✅ CREAR VEHÍCULO EN BD
      print('💾 Guardando vehículo en base de datos...');

      final vehicle = VehicleModel(
        id: '', // Se generará automáticamente en la BD
        empresaId: empresaId,
        titulo: titulo,
        marca: marca,
        modelo: modelo,
        anio: anio,
        placa: placa,
        precioPorDia: precioPorDia,
        color: color,
        capacidad: capacidad ?? 5,
        transmision: transmision ?? 'automatica',
        combustible: combustible ?? 'gasolina',
        kilometraje: kilometraje,
        puertas: puertas ?? 4,
        duenoActual: duenoActual,
        soaNumber: soaNumber,
        circulacionVence: circulacionVence,
        soaVence: soaVence,
        multasPendientes: multasPendientes ?? false,
        insuranceProvider: insuranceProvider,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imagen1: vehicleImageUrl,
        imagen2: plateImageUrl,
      );

      final createdVehicle = await remote.createVehicle(vehicle);
      print('✅ Vehículo creado exitosamente: ${createdVehicle.placa}');

      return createdVehicle;
    } catch (e) {
      print('❌ Error en VehicleRepositoryData.createVehicle: $e');
      rethrow;
    }
  }
}
