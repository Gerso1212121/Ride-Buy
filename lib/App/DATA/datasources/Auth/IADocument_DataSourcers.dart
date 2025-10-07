import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/Auth/IADocumentAnalisis_Model.dart';

class IADocumentDataSourcers {
  final Dio dio;
  final String endpoint;
  final String apiKey;

  IADocumentDataSourcers({
    required this.dio,
    required this.endpoint,
    required this.apiKey,
  });

  Future<IADocumentAnalisisModel> analyzeDocument(File file,
      {String? sourceId, String? provider}) async {
    final fileBytes = await MultipartFile.fromFile(file.path,
        filename: file.path.split('/').last);
    final formData = FormData.fromMap({'file': fileBytes});

    final response = await dio.post(
      endpoint,
      data: formData,
      options: Options(headers: {
        'Ocp-Apim-Subscription-Key': apiKey,
        'Content-Type': 'multipart/form-data',
      }),
    );

    final data = response.data as Map<String, dynamic>;

    return IADocumentAnalisisModel.fromJson({
      'id': data['id'] ?? '',
      'analysisType': data['analysisType'] ?? 'document',
      'sourceType': data['sourceType'] ?? 'upload',
      'sourceId': sourceId ?? '',
      'provider': provider,
      'providerRef': data['providerRef'],
      'confidenceScore': data['confidenceScore'],
      'isApproved': data['isApproved'] ?? false,
      'primaryFinding': data['primaryFinding'],
      'featuresUsed': data['featuresUsed'],
      'analysisDurationMs': data['analysisDurationMs'],
      'costUnits': data['costUnits'],
      'findings': data['findings'] ?? {},
      'recommendations': data['recommendations'],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }
}
