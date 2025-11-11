import 'package:ezride/App/DATA/datasources/Auth/vehicle_remote_datasource.dart';
import 'package:flutter/material.dart';
import 'package:ezride/App/DATA/repositories/vehicle_repository_data.dart';
import 'package:ezride/App/DOMAIN/usecases/create_vehicle_usecase.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Services/api/s3_service.dart'; // ✅ TU SERVICIO
import 'package:go_router/go_router.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class VehicleTestRealWidget extends StatefulWidget {
  const VehicleTestRealWidget({super.key});

  @override
  State<VehicleTestRealWidget> createState() => _VehicleTestRealWidgetState();
}

class _VehicleTestRealWidgetState extends State<VehicleTestRealWidget> {
  bool _testing = false;
  String _log = '';
  File? _testVehicleImage;
  File? _testPlateImage;

  void _addLog(String message) {
    setState(() {
      _log += '$message\n';
    });
    print(message);
  }

  Future<void> _selectTestImage(bool isVehicle) async {
    try {
      final image = await S3Service.pickImage(ImageSource.gallery);
      if (image != null && mounted) {
        setState(() {
          if (isVehicle) {
            _testVehicleImage = image;
          } else {
            _testPlateImage = image;
          }
        });
        _addLog('✅ Imagen ${isVehicle ? 'vehículo' : 'placa'} seleccionada');
      }
    } catch (e) {
      _addLog('❌ Error seleccionando imagen: $e');
    }
  }

  Future<void> _testCompleteFlow() async {
    if (_testVehicleImage == null || _testPlateImage == null) {
      _addLog('❌ Selecciona ambas imágenes primero');
      return;
    }

    final empresa = SessionManager.currentEmpresa;
    if (empresa == null) {
      _addLog('❌ No hay empresa registrada en sesión');
      return;
    }

    setState(() => _testing = true);

    try {
      _addLog('🚀 INICIANDO PRUEBA COMPLETA CON TU S3Service');

      final repo = VehicleRepositoryData(VehicleRemoteDataSource());
      final useCase = CreateVehicleUseCase(repo);

      final vehicle = await useCase.execute(
        empresaId: empresa.id,
        titulo: 'Toyota Corolla 2023 - TEST',
        marca: 'Toyota',
        modelo: 'Corolla',
        anio: 2023,
        placa: 'TEST${DateTime.now().millisecondsSinceEpoch % 10000}',
        precioPorDia: 45.00,
        imagenVehiculo: _testVehicleImage!,
        imagenPlaca: _testPlateImage!,
        color: 'Blanco',
        capacidad: 5,
        transmision: 'automatica',
        combustible: 'gasolina',
      );

      _addLog('🎉 PRUEBA EXITOSA!');
      _addLog('   🚗 Placa: ${vehicle.placa}');
      _addLog('   💰 Precio: \$${vehicle.precioPorDia}');
      _addLog('   🖼️ Imágenes subidas: ✓');
    } catch (e) {
      _addLog('❌ ERROR: $e');
    } finally {
      setState(() => _testing = false);
    }
  }

  Future<void> _testS3UploadOnly() async {
    if (_testVehicleImage == null) {
      _addLog('❌ Selecciona una imagen primero');
      return;
    }

    setState(() => _testing = true);

    try {
      _addLog('☁️ TESTEO S3 CON TU SERVICIO ACTUAL');

      final result = await S3Service.uploadImage(
        imageFile: _testVehicleImage!,
        fileName: 'test_vehicle_${DateTime.now().millisecondsSinceEpoch}.jpg',
        folder: 'test_vehiculos',
        quality: 85,
      );

      _addLog('✅ UPLOAD S3 EXITOSO');
      _addLog('   🔑 Key: ${result['key']}');

      final publicUrl = S3Service.getPublicUrl(result['key']);
      _addLog('   🔗 URL: $publicUrl');
    } catch (e) {
      _addLog('❌ ERROR S3: $e');
    } finally {
      setState(() => _testing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prueba Vehículos - Con Tu S3Service'),
        backgroundColor: Colors.blue[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selectores de imágenes
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text('SELECCIONA IMÁGENES DE PRUEBA'),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectTestImage(true),
                            icon: const Icon(Icons.car_rental),
                            label: Text(_testVehicleImage != null
                                ? 'Cambiar Vehículo'
                                : 'Vehículo'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () => _selectTestImage(false),
                            icon: const Icon(Icons.confirmation_number),
                            label: Text(_testPlateImage != null
                                ? 'Cambiar Placa'
                                : 'Placa'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Botones de prueba
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testing ? null : _testS3UploadOnly,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Probar S3'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _testing ? null : _testCompleteFlow,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Prueba Completa'),
                    style:
                        ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Logs
            Expanded(
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('LOGS'),
                      const SizedBox(height: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SingleChildScrollView(
                            child: Text(
                              _log.isEmpty
                                  ? 'Los logs aparecerán aquí...'
                                  : _log,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
