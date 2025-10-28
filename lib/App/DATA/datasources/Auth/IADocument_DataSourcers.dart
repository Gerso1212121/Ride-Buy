import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/Auth/IADocumentAnalisis_Model.dart';
import 'package:cross_file/cross_file.dart';

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

  final dataSource = IADocumentDataSourcers(
    dio: Dio(),
    endpoint: dotenv.env['AZURE_DOC_ENDPOINT']!,
    apiKey: dotenv.env['AZURE_DOC_KEY']!,
  );

  Future<void> uploadDocument(XFile file) async {
    final result = await dataSource.analyzeDocument(File(file.path));
    final hash = sha256.convert(await File(file.path).readAsBytes()).toString();

    await RenderDbClient.insertDocument(
      ocrData: result.toJson(),
      hash: hash,
      createdAt: DateTime.now(),
      sourceType: 'document_front', // o document_back
      provider: 'AzureDocumentIntelligence',
    );
  }
}
