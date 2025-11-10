import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
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
// 🔁 Redirige al formulario con los datos del DUI prellenados
      await Future.delayed(const Duration(seconds: 1));
      context.go(
        '/personal-data',
        extra: {
          'fullName': analisisData['fullName'],
          'duiNumber': analisisData['documentNumber'],
          'dateOfBirth': analisisData['dateOfBirth'],
          'perfilId': widget.perfilId, // ✅ AGREGAR ESTA LÍNEA
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
      backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 500),
          child: _isProcessing
              ? _buildVerificationProgress(context)
              : _buildSuccess(context),
        ),
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle,
              color: FlutterFlowTheme.of(context).primary, size: 90),
          const SizedBox(height: 12),
          Text(
            "¡Listo!",
            style: GoogleFonts.lato(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: FlutterFlowTheme.of(context).primaryText,
            ),
          )
        ],
      ),
    );
  }

  // ✅ Ahora el diseño estilo LOGINFORM
  Widget _buildVerificationProgress(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      physics: const BouncingScrollPhysics(),
      child: Center(
        child: Column(
          children: [
            // ✅ Tarjeta estilo Auth
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).primaryBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 16,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [
                  // ✅ New circular gradient icon
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          FlutterFlowTheme.of(context).primary,
                          FlutterFlowTheme.of(context).secondary
                        ],
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                      ),
                    ),
                    child: const Icon(
                      Icons.verified_user_rounded,
                      size: 54,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Verificando tu identidad...',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      color: FlutterFlowTheme.of(context).primaryText,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Estamos procesando tu información de forma segura.\nPor favor no cierres la aplicación.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: FlutterFlowTheme.of(context).secondaryText,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // ✅ Indicador circular
                  Column(
                    children: [
                      Text(
                        _formatTime(_remainingSeconds),
                        style: GoogleFonts.lato(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: _progress,
                        minHeight: 6,
                        backgroundColor: FlutterFlowTheme.of(context)
                            .alternate
                            .withOpacity(.2),
                        valueColor: AlwaysStoppedAnimation(
                          FlutterFlowTheme.of(context).primary,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Text(
                    "Tiempo estimado",
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // ✅ Caja de advertencia estilo Auth
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context)
                          .primary
                          .withOpacity(0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).primary,
                        width: 1.3,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: FlutterFlowTheme.of(context).primary,
                          size: 26,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            "No cierres la app durante la verificación.\nEsto puede interrumpir el proceso.",
                            style: GoogleFonts.lato(
                              fontSize: 13,
                              color: FlutterFlowTheme.of(context).primaryText,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Text(
              "Verificación en progreso...",
              style: GoogleFonts.lato(
                fontSize: 14,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
            Text(
              "Mantén la aplicación abierta",
              style: GoogleFonts.lato(
                fontSize: 12,
                color: FlutterFlowTheme.of(context).secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
