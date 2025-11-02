import 'package:ezride/App/DOMAIN/Entities/Auth/aws_rekognition_result.dart';

import '../../../DOMAIN/Entities/Auth/IADocumentAnalisis_Entities.dart';
import '../../../DOMAIN/repositories/Auth/IADocument_RepositoryDomain.dart';
import '../../datasources/Auth/IADocument_DataSourcers.dart';
import 'dart:io';

class IADocumentAnalisisRepositoryData implements IADocumentRepositoryDomain {
  final IADocumentDataSource datasource;

  IADocumentAnalisisRepositoryData(this.datasource);

  @override
  Future<IAAnalisisResultEntities> analyzeDocument(File file,
      {String? sourceId, String? provider}) {
    return datasource.analyzeDocument(file);
  }

  // Obtener las presigne URLs de Lambda
  Future<List<Map<String, String>>> getPresignedUrls(
      String userId, List<String> filenames) async {
    return await datasource.getPresignedUrls(
      userId: userId,
      filenames: filenames,
    );
  }

  // 🔹 Nuevo: subir archivo a S3
  Future<void> uploadToS3(String url, File file) {
    return datasource.uploadToS3(url, file);
  }

  // 🔹 Nuevo: verificar identidad
  Future<AwsRekognitionResult> verifyIdentity({
    required String perfilId,
    required String selfieKey,
    required String documentKey,
    double similarityThreshold = 80,
  }) {
    return datasource.verifyIdentity(
      perfilId: perfilId,
      selfieKey: selfieKey,
      documentKey: documentKey,
      similarityThreshold: similarityThreshold,
    );
  }
}
