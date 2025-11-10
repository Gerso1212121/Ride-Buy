import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CameraCapturePage extends StatefulWidget {
  final String perfilId;

  const CameraCapturePage({
    super.key,
    required this.perfilId,
  });

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  CameraController? _controller;
  late AnimationController _animationController;
  bool _isTaking = false;
  bool _isCameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _loadCamera();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  Future<void> _loadCamera() async {
    try {
      final cameras = await availableCameras();

      final backCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.back,
      );

      _controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _controller!.initialize();
      await _controller!.setFlashMode(FlashMode.off);

      if (mounted) setState(() => _isCameraInitialized = true);
    } catch (e) {
      debugPrint("❌ Error cargando cámara: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al iniciar la cámara")),
        );
      }
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null) return;

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller!.dispose();
      _isCameraInitialized = false;
    } else if (state == AppLifecycleState.resumed) {
      _loadCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationController.dispose();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _takePictureAndNavigate() async {
    if (_controller == null || !_controller!.value.isInitialized || _isTaking) {
      return;
    }

    setState(() => _isTaking = true);

    try {
      final file = await _controller!.takePicture();

      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (cam) => cam.lensDirection == CameraLensDirection.front,
      );

      if (!mounted) return;

      context.push(
        '/selfie-camera',
        extra: {
          'perfilId': widget.perfilId,
          'duiImagePath': file.path,
        },
      );
    } catch (e) {
      debugPrint("❌ Error al capturar documento: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo tomar la foto")),
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

    const aspectRatio = 85 / 55;

    return WillPopScope(
      onWillPop: () async {
        if (_isTaking) return false;
        try {
          await _controller?.dispose();
        } catch (_) {}
        return true;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            CameraPreview(_controller!),

            // Overlay con agujero
            _ScannerOverlay(aspectRatio: aspectRatio),

            // ⭐ Marco animado
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

            // ⭐ Ícono guía DEL DOCUMENTO DEBAJO DEL RECUADRO
            Positioned(
              top: MediaQuery.of(context).size.height * 0.53,
              left: 0,
              right: 0,
              child: Column(
                children: const [
                  Icon(
                    Icons.badge_rounded, // Ícono tipo DUI
                    size: 80,
                    color: Colors.white70,
                  ),
                  SizedBox(height: 10),
                  Text(
                    "Asegúrate de alinear tu DUI\ncomo se muestra arriba",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Texto inferior
            const Positioned(
              bottom: 150,
              left: 0,
              right: 0,
              child: Text(
                'Coloca la parte frontal de tu DUI dentro del recuadro',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Botón de captura
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
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

            // Botón salir
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
      ),
    );
  }
}

class _ScannerOverlay extends StatelessWidget {
  final double aspectRatio;

  const _ScannerOverlay({required this.aspectRatio});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final screenWidth = constraints.maxWidth;
        final boxWidth = screenWidth * 0.85;
        final boxHeight = boxWidth / aspectRatio;

        return Stack(
          children: [
            Container(color: Colors.black.withOpacity(0.6)),
            Center(
              child: ClipPath(
                clipper: _RectClipper(width: boxWidth, height: boxHeight),
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

    return Path.combine(
      PathOperation.difference,
      path,
      Path()..addRect(hole),
    );
  }

  @override
  bool shouldReclip(_) => false;
}
