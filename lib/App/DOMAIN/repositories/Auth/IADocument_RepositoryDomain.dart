import 'dart:io';
import 'package:ezride/App/DOMAIN/Entities/Auth/aws_rekognition_result.dart';
import '../../Entities/Auth/IADocumentAnalisis_Entities.dart';

/// 🧠 Interfaz del dominio para análisis y verificación de documentos
abstract class IADocumentRepositoryDomain {
  // ---------------------------------------------
  // 📄 Analizar documento (OCR + IA backend)
  // ---------------------------------------------
  Future<IAAnalisisResultEntities> analyzeDocument(
    File file, {
    String? sourceId,
    String? provider,
  });

  // ---------------------------------------------
  // 🔐 Obtener URLs presigned desde AWS Lambda
  // ---------------------------------------------
  Future<List<Map<String, String>>> getPresignedUrls(
    String userId,
    List<String> filenames,
  );

  // ---------------------------------------------
  // ☁️ Subir archivo a S3 usando URL presigned
  // ---------------------------------------------
  Future<void> uploadToS3(String presignedUrl, File file);

  // ---------------------------------------------
  // 🧠 Verificar identidad (Selfie vs Documento)
  // ---------------------------------------------
  Future<AwsRekognitionResult> verifyIdentity({
    required String perfilId,
    required String selfieKey,
    required String documentKey,
    double similarityThreshold,
  });
}
