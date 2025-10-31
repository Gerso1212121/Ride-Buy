import 'dart:io';
import 'package:dio/dio.dart';
import '../../models/Auth/IADocumentAnalisis_Model.dart';

class IADocumentDataSource {
  final Dio dio;
  final String backendUrl; // URL de tu servidor Express, ej: http://localhost:3000
  IADocumentDataSource({
    required this.dio,
    required this.backendUrl,
  });

  Future<IADocumentAnalisisModel> analyzeDocument(File file) async {
    final analyzeUrl = "$backendUrl/analyze-id";

    print("📤 Enviando documento al backend: $analyzeUrl");

    // Crear FormData para enviar archivo como multipart/form-data
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    // Realizar POST a tu endpoint Node
    final response = await dio.post(
      analyzeUrl,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    print("📥 Response status: ${response.statusCode}");
    print("📥 Response data: ${response.data}");

    if (response.statusCode == 200 && response.data["success"] == true) {
      print("✅ Documento analizado correctamente.");
      return IADocumentAnalisisModel.fromJson(response.data);
    } else {
      throw Exception(
        "❌ Error del servidor: ${response.data["error"] ?? "Error desconocido"}",
      );
    }
  }
}
