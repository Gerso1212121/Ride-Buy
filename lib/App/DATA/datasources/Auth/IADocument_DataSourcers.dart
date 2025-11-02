import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/aws_rekognition_result.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../models/Auth/IADocumentAnalisis_Model.dart';

class IADocumentDataSource {
  final Dio dio;
  late final String presignUrl;
  late final String verifyUrl;
  final String backendUrl =
      dotenv.env['BACKEND_URL'] ?? "http://192.168.101.9:3000";

  IADocumentDataSource({required this.dio}) {
    // 🔹 Cargar variables desde el .env
    presignUrl = dotenv.env['AWS_PRESIGN'] ?? '';
    verifyUrl = dotenv.env['AWS_VERIFY'] ?? '';

    if (presignUrl.isEmpty || verifyUrl.isEmpty) {
      throw Exception(
          '⚠️ Faltan variables AWS_PRESIGN o AWS_VERIFY en el archivo .env');
    }
  }

  // ---------------------------------------------
  // 📄 Analizar documento con backend Node (OCR + IA)
  // ---------------------------------------------
  Future<IADocumentAnalisisModel> analyzeDocument(File file) async {
    final analyzeUrl = "$backendUrl/analyze-id";
    print("📤 Enviando documento al backend: $analyzeUrl");

    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        file.path,
        filename: file.path.split('/').last,
      ),
    });

    final response = await dio.post(
      analyzeUrl,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
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

  // ---------------------------------------------
  // 🔐 Obtener URLs presigned desde Lambda
  // ---------------------------------------------

  Future<List<Map<String, String>>> getPresignedUrls({
    required String userId,
    required List<String> filenames,
  }) async {
    print("🔗 Solicitando presigned URLs desde: $presignUrl");

    final response = await dio.post(
      presignUrl,
      data: {"user_id": userId, "filenames": filenames},
      options: Options(
        headers: {"Content-Type": "application/json"},
        responseType: ResponseType.json,
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    print("📥 Response status: ${response.statusCode}");
    print("📥 Response tipo: ${response.data.runtimeType}");
    print("📥 Response data: ${response.data}");

    if (response.statusCode == 200) {
      dynamic body = response.data;

      // 👇 Si la respuesta viene como String (caso actual)
      if (body is String) {
        print("🧩 Decodificando JSON string...");
        body = jsonDecode(body);
      }

      // Ahora debe ser un Map con "presigned"
      if (body is Map && body.containsKey("presigned")) {
        final List<dynamic> list = body["presigned"];
        final data = list
            .map((e) => {
                  "key": e["key"].toString(),
                  "url": e["url"].toString(),
                })
            .toList();

        print("✅ URLs presigned obtenidas correctamente (${data.length}).");
        return data;
      } else {
        throw Exception(
            "❌ Formato inesperado del backend: ${body.runtimeType}");
      }
    } else {
      throw Exception(
          "❌ Error al obtener URLs presigned (${response.statusCode}): ${response.data}");
    }
  }

  // ---------------------------------------------
  // ☁️ Subir archivo a S3 usando la URL presigned
  // ---------------------------------------------
  Future<void> uploadToS3(String presignedUrl, File file) async {
    print("⬆️ Subiendo archivo a S3 con URL presigned...");
    final length = await file.length();
    final stream = file.openRead();

    final response = await dio.put(
      presignedUrl,
      data: stream,
      options: Options(
        headers: {
          "Content-Type": "image/jpeg",
          "Content-Length": length,
        },
        validateStatus: (status) => status != null && status < 500,
      ),
    );

    if (response.statusCode == 200) {
      print("✅ Archivo subido correctamente a S3.");
    } else {
      print("❌ Error al subir a S3: ${response.statusCode}");
      print("📄 Respuesta: ${response.data}");
      throw Exception(
          "Error al subir archivo a S3 (status ${response.statusCode})");
    }
  }

  // ---------------------------------------------
  // 🧠 Verificar identidad (Selfie vs Documento)
  // ---------------------------------------------

Future<AwsRekognitionResult> verifyIdentity({
  required String perfilId,
  required String selfieKey,
  required String documentKey,
  double similarityThreshold = 80.0,
}) async {
  print("🔍 Verificando identidad con Rekognition: $verifyUrl");

  final response = await dio.post(
    verifyUrl,
    data: {
      "perfil_id": perfilId,
      "source_key": selfieKey,
      "target_key": documentKey,
      "similarity_threshold": similarityThreshold,
    },
    options: Options(
      headers: {"Content-Type": "application/json"},
      responseType: ResponseType.json,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  print("📥 Response status: ${response.statusCode}");
  print("📥 Response data: ${response.data}");

  if (response.statusCode == 200) {
    print("✅ Verificación de identidad completada con éxito.");

    // 👇 Si response.data es String, parsearlo
    final data = response.data is String
        ? jsonDecode(response.data)
        : response.data;

    return AwsRekognitionResult.fromJson(data);
  } else {
    throw Exception(
        "❌ Error al verificar identidad: ${response.data ?? 'Error desconocido'}");
  }
}


}
