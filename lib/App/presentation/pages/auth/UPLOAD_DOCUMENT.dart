import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

// 🧩 Capas de datos y dominio
import 'package:ezride/App/DATA/datasources/Auth/IADocument_DataSourcers.dart';
import 'package:ezride/App/DATA/repositories/Auth/IADocumentAnalisis_RepositoryData.dart';
import 'package:ezride/App/DATA/repositories/Auth/ProfileUser_RepositoryData.dart';
import 'package:ezride/App/DOMAIN/usecases/Auth/IADocumentAnalisis_UseCases.dart';

class UploadDocumentPage extends StatefulWidget {
  final String perfilId;
  final String duiImagePath;
  final String selfiePath;

  const UploadDocumentPage({
    super.key,
    required this.perfilId,
    required this.duiImagePath,
    required this.selfiePath,
  });

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  late IADocumentAnalisisUseCases usecase;
  late ProfileUserRepositoryData profileRepo;

  bool _isProcessing = true;
  int _remainingSeconds = 300; // 5 minutos
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeAndVerify();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
          _progress = 1 - (_remainingSeconds / 300);
        });
        _startTimer();
      }
    });
  }

  String _formatTime(int seconds) {
    final min = (seconds ~/ 60).toString().padLeft(2, '0');
    final sec = (seconds % 60).toString().padLeft(2, '0');
    return "$min:$sec";
  }

  Future<void> _initializeAndVerify() async {
    try {
      await dotenv.load(fileName: ".env");
      final dio = Dio();
      final datasource = IADocumentDataSource(dio: dio);
      final repository = IADocumentAnalisisRepositoryData(datasource);
      usecase = IADocumentAnalisisUseCases(repository);
      profileRepo = ProfileUserRepositoryData(dio: dio);

      final analisisData = await _uploadAndVerify();

      // ✅ Verificamos si el usuario tiene la edad mínima (18 años)
      final dateOfBirthStr = analisisData['dateOfBirth'];
      if (dateOfBirthStr != null && !_isAdult(dateOfBirthStr)) {
        throw Exception("El usuario debe ser mayor de 18 años para continuar.");
      }

      if (!mounted) return;
      setState(() => _isProcessing = false);

      // 🔁 Redirige al formulario con los datos del DUI prellenados
      await Future.delayed(const Duration(seconds: 1));
      context.go(
        '/personal-data',
        extra: {
          'fullName': analisisData['fullName'],
          'duiNumber': analisisData['documentNumber'],
          'dateOfBirth': analisisData['dateOfBirth'],
        },
      );
    } catch (e, stack) {
      debugPrint("❌ Error en verificación: $e\n$stack");
      _goToErrorScreen(e.toString());
    }
  }

  bool _isAdult(String dateOfBirthStr) {
    try {
      final birthDate = DateTime.parse(dateOfBirthStr);
      final now = DateTime.now();
      final age = now.year - birthDate.year;
      final hasHadBirthdayThisYear = (now.month > birthDate.month) ||
          (now.month == birthDate.month && now.day >= birthDate.day);
      final actualAge = hasHadBirthdayThisYear ? age : age - 1;
      return actualAge >= 18;
    } catch (_) {
      return false; // si el formato no es válido
    }
  }

  Future<Map<String, dynamic>> _uploadAndVerify() async {
    final filenames = [
      "document_${DateTime.now().millisecondsSinceEpoch}.jpg",
      "selfie_${DateTime.now().millisecondsSinceEpoch}.jpg"
    ];

    final presigned =
        await usecase.getPresignedUrls(widget.perfilId, filenames);
    final documentKey = presigned[0]['key']!;
    final documentUrl = presigned[0]['url']!;
    final selfieKey = presigned[1]['key']!;
    final selfieUrl = presigned[1]['url']!;

    await usecase.uploadToS3(documentUrl, File(widget.duiImagePath));
    await usecase.uploadToS3(selfieUrl, File(widget.selfiePath));

    final analisis = await usecase.call(
      File(widget.duiImagePath),
      sourceId: widget.perfilId,
      provider: "azure",
    );

    final fullName = analisis.findings["fullName"];
    final documentNumber = analisis.findings["documentNumber"];
    final dateOfBirth = analisis.findings["dateOfBirth"];

    if (fullName == null || documentNumber == null || dateOfBirth == null) {
      throw Exception("Datos del documento incompletos o inválidos.");
    }

    final result = await usecase.verifyIdentity(
      perfilId: widget.perfilId,
      selfieKey: selfieKey,
      documentKey: documentKey,
    );

    if (result.result != "Matched") {
      throw Exception(
          "La comparación facial falló (${result.bestSimilarity.toStringAsFixed(2)}%).");
    }

    return {
      'fullName': fullName,
      'documentNumber': documentNumber,
      'dateOfBirth': dateOfBirth,
    };
  }

  void _goToErrorScreen(String reason) {
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(
        '/error-verificacion',
        extra: {
          'reason': reason,
          'reintento': {
            'perfilId': widget.perfilId,
            'duiImagePath': widget.duiImagePath,
            'selfiePath': widget.selfiePath,
          },
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _isProcessing
            ? _buildVerificationProgress()
            : const Center(
                child: Icon(Icons.check_circle, color: Colors.green, size: 80),
              ),
      ),
    );
  }

  /// 🎨 Pantalla de progreso visual
  Widget _buildVerificationProgress() {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🔒 Ícono de seguridad
                Container(
                  width: 120,
                  height: 120,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Color(0xFF105DFB), Color(0xFF8AC7FF)],
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                    ),
                  ),
                  child: const Icon(Icons.lock_rounded,
                      size: 60, color: Colors.white),
                ),
                const SizedBox(height: 24),

                Text(
                  'Verificando tu identidad',
                  style: GoogleFonts.lato(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estamos procesando tu información de forma segura.\n'
                  'Por favor, no cierres la aplicación.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 40),

                // Indicador circular + tiempo restante
                Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x1A000000),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularPercentIndicator(
                        radius: 50.0,
                        lineWidth: 8.0,
                        percent: _progress,
                        animation: true,
                        progressColor: const Color(0xFF105DFB),
                        backgroundColor: const Color(0xFFE0E3E7),
                        circularStrokeCap: CircularStrokeCap.round,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _formatTime(_remainingSeconds),
                        style: GoogleFonts.lato(
                          fontSize: 22,
                          color: const Color(0xFF105DFB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tiempo estimado',
                        style: GoogleFonts.lato(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // ℹ️ Mensaje informativo
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0x4C105DFB),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF105DFB)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_rounded,
                          color: Color(0xFF105DFB), size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No cierres la aplicación durante el proceso. '
                          'Esto podría interrumpir la validación de tu identidad.',
                          style: GoogleFonts.lato(
                            color: Colors.black87,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  'Verificación en progreso...',
                  style: GoogleFonts.lato(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Mantén la aplicación abierta',
                  style: GoogleFonts.lato(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
