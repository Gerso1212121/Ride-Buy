import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraCapturePage extends StatefulWidget {
  final CameraDescription camera;
  final String perfilId;

  const CameraCapturePage({
    super.key,
    required this.camera,
    required this.perfilId,
  });

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late AnimationController _animationController;
  bool _isTaking = false;

  @override
  void initState() {
    super.initState();

    // Inicializar cámara
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeCamera();

    // 🔵 Animación de pulso en el borde
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _initializeCamera() async {
    try {
      await _controller.initialize();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('❌ Error inicializando cámara: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al iniciar la cámara')),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndNavigate() async {
    if (!_controller.value.isInitialized || _isTaking) return;
    setState(() => _isTaking = true);

    try {
      final XFile file = await _controller.takePicture();
      if (!mounted) return;

      // 📷 Foto del DUI capturada
      final duifrontPath = file.path;

      // 📸 Obtiene la cámara frontal
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );

      // 🚀 Navega a la cámara de selfie pasando el DUI y perfilId
      context.push(
        '/selfie-camera',
        extra: {
          'camera': frontCamera,
          'perfilId': widget.perfilId,
          'duiImagePath': duifrontPath, // 👈 aquí se envía la imagen del DUI
        },
      );
    } catch (e) {
      debugPrint('❌ Error al tomar foto del DUI: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo tomar la foto del documento')),
      );
    } finally {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    const aspectRatio = 85 / 55; // proporción del DUI

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 📸 Vista previa de la cámara
          CameraPreview(_controller),

          // 🌫️ Fondo oscuro con recorte central (tipo escáner)
          _ScannerOverlay(aspectRatio: aspectRatio),

          // 🔵 Marco azul animado
          Center(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  final thickness =
                      3 + (_animationController.value * 2); // efecto de pulso
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(0.8),
                        width: thickness,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  );
                },
              ),
            ),
          ),

          // 🧾 Texto indicativo
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: Column(
              children: const [
                Text(
                  'Coloca la parte frontal de tu DUI dentro del recuadro',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    shadows: [
                      Shadow(
                        color: Colors.black54,
                        offset: Offset(0, 1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // 🔘 Botón de captura
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takePictureAndNavigate,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Center(
                    child: _isTaking
                        ? const SizedBox(
                            height: 25,
                            width: 25,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Icon(Icons.camera_alt,
                            color: Colors.white, size: 35),
                  ),
                ),
              ),
            ),
          ),

          // ❌ Botón cerrar
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => context.pop(),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌫️ Widget del overlay con un hueco transparente en forma de rectángulo
class _ScannerOverlay extends StatelessWidget {
  final double aspectRatio;

  const _ScannerOverlay({required this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final boxWidth = screenWidth * 0.85; // 85% del ancho
        final boxHeight = boxWidth / aspectRatio;

        return Stack(
          children: [
            // Capa oscura semitransparente
            Container(color: Colors.black.withOpacity(0.6)),

            // Recorte del área central (recuadro del documento)
            Center(
              child: ClipPath(
                clipper: _RectClipper(
                  width: boxWidth,
                  height: boxHeight,
                ),
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _RectClipper extends CustomClipper<Path> {
  final double width;
  final double height;

  _RectClipper({required this.width, required this.height});

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final hole = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: width,
      height: height,
    );
    path.addRect(hole);
    return Path.combine(PathOperation.difference, path, Path()..addRect(hole));
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
