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
    with SingleTickerProviderStateMixin, WidgetsBindingObserver, RouteAware {
  late CameraController _controller;
  late AnimationController _animationController;
  bool _isTaking = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeCamera();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  // 📸 Inicializa cámara
  Future<void> _initializeCamera() async {
    try {
      await _controller.initialize();
      await _controller.setFlashMode(FlashMode.off);
      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint('❌ Error inicializando cámara: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al iniciar la cámara')),
        );
      }
    }
  }

  // ⚙️ Maneja ciclo de vida
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller.dispose();
      _isCameraInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      _reinitializeCamera();
    }
  }

  // 🔁 Reintenta reiniciar cámara si vuelve al frente
  void _reinitializeCamera() {
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeCamera();
  }

  // 🔙 Detecta cuando el usuario regresa (por Navigator.pop)
  @override
  void didPopNext() {
    debugPrint('🔁 Página volvió al frente, reiniciando cámara...');
    _reinitializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    if (_controller.value.isInitialized) _controller.dispose();
    super.dispose();
  }

  // 📷 Captura del DUI
  Future<void> _takePictureAndNavigate() async {
    if (!_controller.value.isInitialized || _isTaking) return;
    setState(() => _isTaking = true);

    try {
      final XFile file = await _controller.takePicture();
      if (!mounted) return;

      final duifrontPath = file.path;

      // 📸 Obtener cámara frontal
      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );

      // 🚀 Ir a la cámara de selfie
      context.push(
        '/selfie-camera',
        extra: {
          'camera': frontCamera,
          'perfilId': widget.perfilId,
          'duiImagePath': duifrontPath,
        },
      );
    } catch (e) {
      debugPrint('❌ Error al tomar foto del DUI: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('No se pudo tomar la foto del documento')),
        );
      }
    } finally {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  // 🧱 UI igual que antes
  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    const aspectRatio = 85 / 55;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CameraPreview(_controller),
          _ScannerOverlay(aspectRatio: aspectRatio),
          Center(
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, _) {
                  final thickness = 3 + (_animationController.value * 2);
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
          Positioned(
            bottom: 150,
            left: 0,
            right: 0,
            child: const Text(
              'Coloca la parte frontal de tu DUI dentro del recuadro',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
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
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                        : const Icon(Icons.camera_alt,
                            color: Colors.white, size: 35),
                  ),
                ),
              ),
            ),
          ),
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
        final boxWidth = screenWidth * 0.85;
        final boxHeight = boxWidth / aspectRatio;

        return Stack(
          children: [
            // Capa oscura
            Container(color: Colors.black.withOpacity(0.6)),

            // Recorte del área central
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

/// ✂️ Clipper que recorta el rectángulo del DUI
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
    return Path.combine(
      PathOperation.difference,
      path,
      Path()..addRect(hole),
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
