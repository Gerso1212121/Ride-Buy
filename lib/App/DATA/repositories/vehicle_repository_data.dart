import 'package:ezride/App/DATA/datasources/Auth/vehicle_remote_datasource.dart';
import 'package:ezride/App/DOMAIN/repositories/vehicle_repository_domain.dart';
import 'package:ezride/App/DATA/models/Vehiculo_model.dart';
import 'package:ezride/Services/api/azure_validator_service.dart';
import 'package:ezride/Services/api/s3_service.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class VehicleRepositoryData implements VehicleRepositoryDomain {
  final VehicleRemoteDataSource remote;

  VehicleRepositoryData(this.remote);

  @override
  Future<List<VehicleModel>> searchVehicles({
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
  Future<List<VehicleModel>> getRecommendedVehicles() {
    return remote.getRecommendedVehicles();
  }

  @override
  Future<List<VehicleModel>> getVehiclesByEmpresa(String empresaId) {
    return remote.getVehiclesByEmpresa(empresaId);
  }

  // En tu VehicleRepositoryData
// En tu VehicleRepositoryData
  Future<bool> hasActiveRent(String vehicleId) async {
    try {
      print('🔍 Verificando rentas activas para vehículo: $vehicleId');

      final result = await RenderDbClient.query('''
      SELECT EXISTS (
        SELECT 1 FROM public.rentas 
        WHERE vehiculo_id = @vehicle_id 
        AND status IN ('confirmada', 'en_curso')
        AND fecha_entrega_vehiculo >= CURRENT_DATE
      )
    ''', parameters: {
        'vehicle_id': vehicleId, // ✅ Parámetro correcto
      });

      final hasActiveRent =
          result.isNotEmpty && (result.first['exists'] == true);
      print('📊 Vehículo $vehicleId - Tiene renta activa: $hasActiveRent');

      // DEBUG DETALLADO
      final rentasDebug = await RenderDbClient.query('''
      SELECT id, status, fecha_inicio_renta, fecha_entrega_vehiculo 
      FROM public.rentas 
      WHERE vehiculo_id = @vehicle_id 
      AND status IN ('confirmada', 'en_curso')
    ''', parameters: {
        'vehicle_id': vehicleId,
      });

      print(
          '🔎 Rentas confirmadas/en_curso encontradas: ${rentasDebug.length}');
      for (final renta in rentasDebug) {
        final ahora = DateTime.now();
        final fin = DateTime.parse(renta['fecha_entrega_vehiculo'].toString());
        final haTerminado = ahora.isAfter(fin);

        print('   - ID: ${renta['id']}');
        print('     Status: ${renta['status']}');
        print('     Fecha fin: ${renta['fecha_entrega_vehiculo']}');
        print('     ¿Ha terminado?: $haTerminado');
      }

      return hasActiveRent;
    } catch (e) {
      print('❌ Error en hasActiveRent para $vehicleId: $e');
      return false;
    }
  }

  @override
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
  }) async {
    try {
      print('🚀 INICIANDO CREACIÓN DE VEHÍCULO');
      print('🏢 Empresa ID: $empresaId');
      print('🚗 Placa: $placa');
      print('💰 Precio: $precioPorDia');
      print('🎯 Tipo: $tipo'); // ✅ DEBUG DEL NUEVO CAMPO

      // ============================================
      // ✅ PASO 1: VALIDACIONES PREVIAS
      // ============================================
      print('\n📋 PASO 1: Validaciones previas...');

      // Validar que las imágenes existen
      if (!await imagenVehiculo.exists()) {
        throw Exception('La imagen del vehículo no existe');
      }

      if (!await imagenPlaca.exists()) {
        throw Exception('La imagen de la placa no existe');
      }

      // ============================================
      // ✅ PASO 2: VALIDACIÓN CON IA
      // ============================================
      print('\n🤖 PASO 2: Validación con Azure GPT-4o...');

      final validationResult =
          await AzureValidatorService.validateVehicleImages(
        vehicleImage: imagenVehiculo,
        plateImage: imagenPlaca,
        mode: 'estricto',
      );

      if (!validationResult['valido']) {
        final razon =
            validationResult['razon'] ?? 'No cumple con los requisitos';
        throw Exception('Validación IA fallida: $razon');
      }

      print('✅ Validación IA exitosa');

      // ============================================
      // ✅ PASO 3: SUBIR IMÁGENES A S3
      // ============================================
      print('\n☁️ PASO 3: Subiendo imágenes a S3...');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final empresaFolder = 'empresa_$empresaId/vehiculos';

      // Subir imagen del vehículo
      final vehicleFileName = 'vehicle_${placa}_$timestamp.jpg';
      print('📸 Subiendo imagen vehículo: $vehicleFileName');

      final vehicleUploadResult = await S3Service.uploadImage(
        imageFile: imagenVehiculo,
        fileName: vehicleFileName,
        folder: empresaFolder,
        quality: 85,
      );

      // Subir imagen de la placa
      final plateFileName = 'plate_${placa}_$timestamp.jpg';
      print('📸 Subiendo imagen placa: $plateFileName');

      final plateUploadResult = await S3Service.uploadImage(
        imageFile: imagenPlaca,
        fileName: plateFileName,
        folder: empresaFolder,
        quality: 90,
      );

      // Obtener URLs públicas
      final vehicleImageUrl =
          S3Service.getPublicUrl(vehicleUploadResult['key']);
      final plateImageUrl = S3Service.getPublicUrl(plateUploadResult['key']);

      print('✅ Imágenes subidas a S3');
      print('   🚗 Vehículo: $vehicleImageUrl');
      print('   🏷️ Placa: $plateImageUrl');

      // ============================================
      // ✅ PASO 4: CREAR VEHÍCULO EN BD
      // ============================================
      print('\n💾 PASO 4: Guardando en base de datos...');

      final vehicle = VehicleModel(
        id: const Uuid().v4(),
        empresaId: empresaId,
        titulo: titulo,
        marca: marca,
        modelo: modelo,
        anio: anio,
        placa: placa,
        precioPorDia: precioPorDia,
        color: color,
        tipo: tipo, // ✅ PASAR EL NUEVO CAMPO
        capacidad: capacidad ?? 5,
        transmision: transmision ?? 'automatica',
        combustible: combustible ?? 'gasolina',
        puertas: puertas ?? 4,
        soaNumber: soaNumber,
        circulacionVence: circulacionVence,
        soaVence: soaVence,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        imagen1: vehicleImageUrl,
        imagen2: plateImageUrl,
      );

      // ✅ DEBUG DETALLADO
      print('🔍 DEBUG VehicleModel antes de enviar a BD:');
      print('   id: ${vehicle.id}');
      print('   empresaId: ${vehicle.empresaId}');
      print('   titulo: ${vehicle.titulo}');
      print('   marca: ${vehicle.marca}');
      print('   modelo: ${vehicle.modelo}');
      print('   placa: ${vehicle.placa}');
      print('   tipo: ${vehicle.tipo}'); // ✅ DEBUG DEL TIPO
      print(
          '   precioPorDia: ${vehicle.precioPorDia} (${vehicle.precioPorDia.runtimeType})');
      print('   color: ${vehicle.color} (${vehicle.color?.runtimeType})');
      print('   imagen1: ${vehicle.imagen1} (${vehicle.imagen1?.runtimeType})');
      print('   imagen2: ${vehicle.imagen2} (${vehicle.imagen2?.runtimeType})');
      print(
          '   createdAt: ${vehicle.createdAt} (${vehicle.createdAt.runtimeType})');
      print(
          '   updatedAt: ${vehicle.updatedAt} (${vehicle.updatedAt.runtimeType})');

      final createdVehicle = await remote.createVehicle(vehicle);

      print('🎉 VEHÍCULO CREADO EXITOSAMENTE');
      return createdVehicle;
    } catch (e) {
      print('❌ ERROR EN CREACIÓN DE VEHÍCULO: $e');
      print('🔍 Stack trace completo:');
      print(e.toString());
      rethrow;
    }
  }
}
