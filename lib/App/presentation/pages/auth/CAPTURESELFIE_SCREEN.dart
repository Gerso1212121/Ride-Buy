import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraSelfiePage extends StatefulWidget {
  final CameraDescription camera;
  final String perfilId;
  final String? duiImagePath; // 👈 foto del DUI

  const CameraSelfiePage({
    super.key,
    required this.camera,
    required this.perfilId,
    this.duiImagePath,
  });

  @override
  State<CameraSelfiePage> createState() => _CameraSelfiePageState();
}

class _CameraSelfiePageState extends State<CameraSelfiePage>
    with SingleTickerProviderStateMixin {
  late CameraController _controller;
  late AnimationController _animationController;
  bool _isTaking = false;

  @override
  void initState() {
    super.initState();

    // 🔧 Inicializamos la cámara frontal
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeCamera();

    // 🔵 Animación de pulso en el borde azul
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

void _initializeCamera() async {
  try {
    if (!_controller.value.isInitialized) { // Verifica si la cámara ya está inicializada
      await _controller.initialize();
      await _controller.setFlashMode(FlashMode.off); // Desactiva el flash si no lo necesitas
      if (mounted) {
        setState(() {});
      }
    }
  } catch (e) {
    debugPrint('❌ Error inicializando cámara: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al iniciar la cámara')),
    );
  }
}


  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _takeSelfie() async {
    if (!_controller.value.isInitialized || _isTaking) return;
    setState(() => _isTaking = true);

    try {
      final XFile file = await _controller.takePicture();
      
      if (!mounted) return;

      // ✅ Navegar a la pantalla de subida con ambos paths
      context.push(
        '/upload-document',
        extra: {
          'selfiePath': file.path,
          'duiImagePath': widget.duiImagePath,
          'perfilId': widget.perfilId,
        },
      );
    } catch (e) {
      debugPrint('❌ Error al tomar selfie: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo tomar la selfie')),
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 📸 Vista previa de la cámara
          CameraPreview(_controller),

          // 🌫️ Overlay con óvalo transparente y borde animado
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, _) {
              final opacity = 0.6 + (_animationController.value * 0.4);
              final thickness = 3 + (_animationController.value * 2);

              return _OvalOverlay(
                borderColor: Colors.blueAccent.withOpacity(opacity),
                borderWidth: thickness,
              );
            },
          ),

          // 🧍‍♀️ Texto guía
          const Positioned(
            top: 100,
            left: 20,
            right: 20,
            child: Text(
              'Alinea tu rostro dentro del óvalo azul',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    offset: Offset(0, 1),
                    blurRadius: 4,
                  ),
                ],
              ),
            ),
          ),

          // 🔘 Botón para tomar selfie
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _takeSelfie,
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
              onPressed: () => context.go("/auth"),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🌫️ Overlay con un óvalo central transparente y borde azul
class _OvalOverlay extends StatelessWidget {
  final Color borderColor;
  final double borderWidth;

  const _OvalOverlay({
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth * 0.75;
      final height = width * 1.2;

      return Stack(
        children: [
          // Fondo oscuro
          Container(color: Colors.black.withOpacity(0.6)),

          // Recorte del área ovalada
          Center(
            child: ClipPath(
              clipper: _OvalClipper(width: width, height: height),
              child: Container(color: Colors.transparent),
            ),
          ),

          // Borde azul animado
          Center(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: borderWidth),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// ✂️ Clipper que recorta el óvalo
class _OvalClipper extends CustomClipper<Path> {
  final double width;
  final double height;

  _OvalClipper({required this.width, required this.height});

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final ovalPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: width,
        height: height,
      ));
    return Path.combine(PathOperation.difference, path, ovalPath);
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
