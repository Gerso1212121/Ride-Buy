import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraSelfiePage extends StatefulWidget {
  final String perfilId;
  final String? duiImagePath;

  const CameraSelfiePage({
    super.key,
    required this.perfilId,
    this.duiImagePath,
  });

  @override
  State<CameraSelfiePage> createState() => _CameraSelfiePageState();
}

class _CameraSelfiePageState extends State<CameraSelfiePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _controller;
  late AnimationController _animationController;
  bool _isTaking = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadFrontCamera();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _loadFrontCamera() async {
    try {
      final cameras = await availableCameras();

      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );

      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off);

      if (mounted) {
        setState(() => _isCameraInitialized = true);
      }
    } catch (e) {
      debugPrint('❌ Error inicializando cámara frontal: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al iniciar la cámara frontal")),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller?.dispose();
      _isCameraInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      _loadFrontCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _takeSelfie() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTaking)
      return;

    setState(() => _isTaking = true);

    try {
      final XFile file = await _controller!.takePicture();

      if (!mounted) return;

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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo tomar la selfie")),
        );
      }
    } finally {
      if (mounted) setState(() => _isTaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isCameraInitialized || _controller == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async => false, // ✅ BLOQUEA BOTÓN FÍSICO DEL CEL
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          alignment: Alignment.center,
          children: [
            CameraPreview(_controller!),
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
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
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
                        : const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 35,
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
                onPressed: () => context.go('/auth'), // ✅ SALIDA CONTROLADA
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OvalOverlay extends StatelessWidget {
  final Color borderColor;
  final double borderWidth;

  const _OvalOverlay({
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      final width = constraints.maxWidth * 0.75;
      final height = width * 1.2;

      return Stack(
        children: [
          /// Fondo negro transparente
          Container(color: Colors.black.withOpacity(0.6)),

          /// Hueco de la cámara
          Center(
            child: ClipPath(
              clipper: _OvalClipper(width: width, height: height),
              child: Container(color: Colors.transparent),
            ),
          ),

          /// Borde del óvalo animado
          Center(
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
              ),
            ),
          ),

          /// ✅ ICONO GUÍA DE SELFIE (40% de opacidad)
          Center(
            child: SizedBox(
              width: width * 0.55,
              height: height * 0.55,
              child: Opacity(
                opacity: 0.4,
                child: Icon(
                  Icons.account_circle_rounded,
                  size: width * 0.50,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

class _OvalClipper extends CustomClipper<Path> {
  final double width;
  final double height;

  _OvalClipper({required this.width, required this.height});

  @override
  Path getClip(Size size) {
    final path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final oval = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: width,
        height: height,
      ));

    return Path.combine(PathOperation.difference, path, oval);
  }

  @override
  bool shouldReclip(_) => false;
}
