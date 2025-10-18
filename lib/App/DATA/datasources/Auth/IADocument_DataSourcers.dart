import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/Auth/IADocumentAnalisis_Model.dart';

class IADocumentDataSourcers {
  final Dio dio = Dio();
  final String endpointForm = dotenv.env['AZURE_DOCUMENT_ENDPOINT']!;
  final String apiKeyForm = dotenv.env['AZURE_DOCUMENT_KEY']!;
  final String endpointFace = dotenv.env['AZURE_FACE_ENDPOINT']!;
  final String apiKeyFace = dotenv.env['AZURE_FACE_API_KEY']!;

  Future<IADocumentAnalisisModel> analyzeDocument(
    File file, {
    String? sourceId,
    String? provider,
  }) async {
    final analyzeUrl =
        '$endpointForm/formrecognizer/documentModels/prebuilt-document:analyze?api-version=2023-07-31';

    final postResponse = await dio.post(
      analyzeUrl,
      data: file.openRead(),
      options: Options(
        headers: {
          'Ocp-Apim-Subscription-Key': apiKeyForm,
          'Content-Type': _detectMimeType(file),
        },
      ),
    );

    if (postResponse.statusCode != 202) {
      throw Exception(
          'Error iniciando análisis. Código: ${postResponse.statusCode}');
    }

    final operationLocation = postResponse.headers['operation-location']?.first;
    if (operationLocation == null)
      throw Exception('No se recibió operation-location');

    Response result;
    do {
      await Future.delayed(const Duration(seconds: 2));
      result = await dio.get(
        operationLocation,
        options: Options(
          headers: {'Ocp-Apim-Subscription-Key': apiKeyForm},
        ),
      );
    } while (result.data['status'] == 'running' ||
        result.data['status'] == 'notStarted');

    if (result.data['status'] != 'succeeded')
      throw Exception('Análisis fallido');

    final data = result.data['analyzeResult'] ?? {};
    return IADocumentAnalisisModel.fromJson(data);
  }

  Future<Map<String, dynamic>> verifyFace({
    required File selfie,
    required File duiFront,
  }) async {
    final url = '$endpointFace/face/v1.0/verify';

    final formData = FormData.fromMap({
      'selfie':
          await MultipartFile.fromFile(selfie.path, filename: 'selfie.jpg'),
      'duiFront':
          await MultipartFile.fromFile(duiFront.path, filename: 'duiFront.jpg'),
    });

    final response = await dio.post(
      url,
      data: formData,
      options: Options(
        headers: {
          'Ocp-Apim-Subscription-Key': apiKeyFace,
          'Content-Type': 'multipart/form-data',
        },
      ),
    );

    return response.data;
  }

  String _detectMimeType(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return 'application/pdf';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }
}
