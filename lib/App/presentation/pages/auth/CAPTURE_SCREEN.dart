import 'dart:io';
import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importa tus capas
import 'package:ezride/App/DATA/datasources/Auth/IADocument_DataSourcers.dart';
import 'package:ezride/App/DATA/repositories/Auth/IADocumentAnalisis_RepositoryData.dart';
import 'package:ezride/App/DOMAIN/usecases/Auth/IADocumentAnalisis_UseCases.dart';

class CaptureScreen extends StatefulWidget {
  final String perfilId;
  const CaptureScreen({super.key, required this.perfilId});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _isCapturing = false;
  bool _isUploading = false;

  // Secuencia de pasos automáticos
  final List<String> _steps = ['dui_front', 'dui_back', 'selfie'];
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  /// Inicializa la cámara
  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _controller!.initialize();
    if (mounted) setState(() => _isInitialized = true);
  }

  /// Captura y envía a Azure (vía backend)
  Future<void> _captureAndUpload() async {
    if (_controller == null || _isCapturing || _isUploading) return;

    setState(() => _isCapturing = true);

    try {
      // 1️⃣ Tomar la foto
      final picture = await _controller!.takePicture();
      final file = File(picture.path);

      // 2️⃣ Generar hash SHA-256 (identificador único)
      final bytes = await file.readAsBytes();
      final hash = sha256.convert(bytes).toString();

      setState(() => _isUploading = true);
      final backendUrl = "http://192.168.101.9:3000";

// 3️⃣ Inicializar DataSource
      final datasource = IADocumentDataSource(
        dio: Dio(),
        backendUrl: backendUrl, // 🔹 Emulador Android apunta a tu PC
      );

      // 4️⃣ Crear repository y use case
      final repository = IADocumentAnalisisRepositoryData(datasource);
      final usecase = IADocumentAnalisisUseCases(repository);

      // 5️⃣ Enviar a Azure a través del backend
      final result =
          await usecase.call(file, sourceId: hash, provider: 'camera');

      // 6️⃣ Guardar metadatos (simulado)
      await saveDocumentMetadata(
        perfilId: widget.perfilId,
        filePath: file.path,
        tipoPerfil: _steps[_currentStep],
        aiAnalysisId: result.id ?? "no_id",
        ocrData: result.findings ?? {},
      );

      // 7️⃣ Mostrar mensaje de éxito
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${_steps[_currentStep]} capturado y subido correctamente ✅'),
            duration: const Duration(seconds: 2),
          ),
        );
      }

      // 8️⃣ Avanzar al siguiente paso
      _currentStep++;
      if (_currentStep < _steps.length) {
        await _controller!.dispose();
        await _initCamera();
      } else {
        // Finalizar → Redirigir
        if (mounted) GoRouter.of(context).go('/auth-complete');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al capturar/subir documento: $e')),
        );
      }
    } finally {
      setState(() {
        _isCapturing = false;
        _isUploading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  /// Interfaz visual
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentType = _steps[_currentStep];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller!),

          // Marco visual para guiar captura
          Align(
            alignment: Alignment.center,
            child: Container(
              width: 280,
              height: currentType == 'selfie' ? 280 : 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.greenAccent, width: 3),
                color: Colors.black.withOpacity(0.25),
              ),
            ),
          ),

          // Botón de captura
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: _isUploading
                  ? const CircularProgressIndicator(color: Colors.greenAccent)
                  : FloatingActionButton(
                      backgroundColor: Colors.greenAccent,
                      onPressed: _captureAndUpload,
                      child: const Icon(Icons.camera_alt,
                          size: 32, color: Colors.black),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Función simulada de guardado de metadatos (puedes reemplazarla por tu API real)
Future<void> saveDocumentMetadata({
  required String perfilId,
  required String filePath,
  required String tipoPerfil,
  required String aiAnalysisId,
  required Map<String, dynamic> ocrData,
}) async {
  debugPrint("""
📄 Guardando metadatos:
Perfil: $perfilId
Archivo: $filePath
Tipo: $tipoPerfil
AI ID: $aiAnalysisId
OCR: $ocrData
""");

  await Future.delayed(const Duration(milliseconds: 500));
}
