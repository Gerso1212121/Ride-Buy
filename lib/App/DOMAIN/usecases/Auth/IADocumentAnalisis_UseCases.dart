import 'dart:io';
import 'package:ezride/App/DOMAIN/Entities/Auth/aws_rekognition_result.dart';
import '../../repositories/Auth/IADocument_RepositoryDomain.dart';
import '../../Entities/Auth/IADocumentAnalisis_Entities.dart';

class IADocumentAnalisisUseCases {
  final IADocumentRepositoryDomain repository;

  IADocumentAnalisisUseCases(this.repository);

  // 🔹 Analizar documento
  Future<IAAnalisisResultEntities> call(
    File file, {
    String? sourceId,
    String? provider,
  }) {
    return repository.analyzeDocument(
      file,
      sourceId: sourceId,
      provider: provider,
    );
  }

  // 🔹 Obtener URLs presigned de AWS Lambda
  Future<List<Map<String, String>>> getPresignedUrls(
    String userId,
    List<String> filenames,
  ) async {
    return await repository.getPresignedUrls(userId, filenames);
  }

  // 🔹 Subir archivo a S3
  Future<void> uploadToS3(String url, File file) async {
    await repository.uploadToS3(url, file);
  }

  // 🔹 Verificar identidad en Rekognition
  Future<AwsRekognitionResult> verifyIdentity({
    required String perfilId,
    required String selfieKey,
    required String documentKey,
    double similarityThreshold = 80.0,
  }) async {
    return await repository.verifyIdentity(
      perfilId: perfilId,
      selfieKey: selfieKey,
      documentKey: documentKey,
      similarityThreshold: similarityThreshold,
    );
  }
}
