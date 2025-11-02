import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';

// 🧩 Capas de datos y dominio
import 'package:ezride/App/DATA/datasources/Auth/IADocument_DataSourcers.dart';
import 'package:ezride/App/DATA/repositories/Auth/IADocumentAnalisis_RepositoryData.dart';
import 'package:ezride/App/DOMAIN/usecases/Auth/IADocumentAnalisis_UseCases.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/IADocumentAnalisis_Entities.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/aws_rekognition_result.dart';

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
  bool _isLoading = false;
  String? _status;
  AwsRekognitionResult? _result;
  IAAnalisisResultEntities? _analisisResult;

  late IADocumentAnalisisUseCases usecase;

  @override
  void initState() {
    super.initState();
    _initializeUsecase();
  }

  Future<void> _initializeUsecase() async {
    try {
      print("🔧 Cargando variables .env...");
      await dotenv.load(fileName: ".env");

      print("🧩 Inicializando capas de datos...");
      final datasource = IADocumentDataSource(dio: Dio());
      final repository = IADocumentAnalisisRepositoryData(datasource);
      usecase = IADocumentAnalisisUseCases(repository);

      print("✅ UseCase inicializado correctamente.");
    } catch (e) {
      print("❌ Error al inicializar el usecase: $e");
    }
  }

  Future<void> _uploadAndVerify() async {
    print("🚀 Iniciando proceso de subida, análisis y verificación...");
    setState(() {
      _isLoading = true;
      _status = "Subiendo archivos a AWS...";
    });

    try {
      // 1️⃣ Obtener URLs presigned
      final filenames = [
        "document_${DateTime.now().millisecondsSinceEpoch}.jpg",
        "selfie_${DateTime.now().millisecondsSinceEpoch}.jpg"
      ];

      final presigned =
          await usecase.getPresignedUrls(widget.perfilId, filenames);

      if (presigned.length < 2) {
        throw Exception("No se recibieron URLs presigned válidas.");
      }

      final documentKey = presigned[0]['key']!;
      final documentUrl = presigned[0]['url']!;
      final selfieKey = presigned[1]['key']!;
      final selfieUrl = presigned[1]['url']!;

      // 2️⃣ Subir imágenes
      setState(() => _status = "Subiendo documento...");
      await usecase.uploadToS3(documentUrl, File(widget.duiImagePath));

      setState(() => _status = "Subiendo selfie...");
      await usecase.uploadToS3(selfieUrl, File(widget.selfiePath));

      // 3️⃣ Analizar el documento (Azure Document Intelligence)
      setState(() => _status = "Analizando documento...");
      print("🧠 Analizando documento con IA...");

      final analisisResult = await usecase.call(
        File(widget.duiImagePath),
        sourceId: widget.perfilId,
        provider: "azure",
      );

      print("📄 Resultado del análisis:");
      print("Tipo de documento: ${analisisResult.findings["docType"]}");
      print("Nombre completo: ${analisisResult.findings["fullName"]}");
      print("Documento #: ${analisisResult.findings["documentNumber"]}");

      setState(() {
        _analisisResult = analisisResult;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Documento analizado correctamente: ${analisisResult.findings["fullName"] ?? "Sin nombre"}"),
          backgroundColor: Colors.blueAccent,
        ),
      );

      // 4️⃣ Verificar identidad
      setState(() => _status = "Verificando identidad...");
      final result = await usecase.verifyIdentity(
        perfilId: widget.perfilId,
        selfieKey: selfieKey,
        documentKey: documentKey,
      );

      setState(() {
        _result = result;
        _isLoading = false;
        _status = result.result == 'matched'
            ? "✅ Identidad verificada correctamente."
            : "❌ No se pudo verificar la identidad.";
      });

      print("🎯 Proceso completado correctamente.");
    } catch (e, stack) {
      print("❌ Error durante el proceso:");
      print("Error: $e");
      print("Stacktrace: $stack");
      setState(() {
        _isLoading = false;
        _status = "❌ Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Subida y Verificación"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 🖼️ Vista previa
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _previewImage(widget.duiImagePath, "Documento"),
                    _previewImage(widget.selfiePath, "Selfie"),
                  ],
                ),
                const SizedBox(height: 30),

                if (_isLoading)
                  Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 16),
                      Text(
                        _status ?? "Procesando...",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  )
                else ...[
                  if (_status != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Text(
                        _status!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: _status!.contains("Error")
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),

                  ElevatedButton.icon(
                    onPressed: _uploadAndVerify,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text("Subir y Verificar Identidad"),
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Colors.blueAccent,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // 🧠 Resultado de análisis
                  if (_analisisResult != null)
                    Card(
                      color: Colors.grey[100],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "📄 Resultado del análisis del documento:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                "🔹 Tipo: ${_analisisResult!.findings["docType"] ?? "Desconocido"}"),
                            Text(
                                "🔹 Nombre completo: ${_analisisResult!.findings["fullName"] ?? "N/A"}"),
                            Text(
                                "🔹 Documento #: ${_analisisResult!.findings["documentNumber"] ?? "N/A"}"),
                            Text(
                                "🔹 Nacionalidad: ${_analisisResult!.findings["nationality"] ?? "N/A"}"),
                            Text(
                                "🔹 Nacimiento: ${_analisisResult!.findings["dateOfBirth"] ?? "N/A"}"),
                            Text(
                                "🔹 Expira: ${_analisisResult!.findings["dateOfExpiration"] ?? "N/A"}"),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  // 📊 Resultado de Rekognition
                  if (_result != null)
                    Card(
                      color: Colors.grey[100],
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "📊 Resultado AWS Rekognition:",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                                "🔹 Similitud más alta: ${_result!.bestSimilarity.toStringAsFixed(2)}%"),
                            Text(
                                "🔹 Rostros no coincidentes: ${_result!.unmatchedFaces}"),
                            Text("🔹 Estado: ${_result!.result}"),
                          ],
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _previewImage(String path, String label) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(path),
            width: 120,
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
