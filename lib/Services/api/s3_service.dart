// lib/Services/s3_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class S3Service {
  // Getter que obtiene la URL desde dotenv cuando se necesite
  static String get _url => dotenv.get('AWS_UPLOAD_IMAGE');

  // Uri generado dinámicamente
  static Uri get _apiUrl => Uri.parse(_url);

  // ✅ URL BASE PÚBLICA - Ya no necesitas llamar a Lambda para ver imágenes
  static const String _publicBaseUrl = "https://ezride-images.s3.us-west-1.amazonaws.com";

  // Método para comprimir imagen
  static Future<File?> compressImage(File file, {int quality = 80}) async {
    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      file.absolute.path + '_compressed.jpg',
      quality: quality,
    );
    return result != null ? File(result.path) : null;
  }

  // Convertir imagen a base64
  static Future<String> convertImageToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }

  // Subir imagen a S3 (MANTENER ESTE MÉTODO PARA SUBIDAS)
  static Future<Map<String, dynamic>> uploadImage({
    required File imageFile,
    required String fileName,
    required String folder,
    int quality = 80,
  }) async {
    try {
      print('🔄 Iniciando subida S3...');
      print('📁 Archivo: $fileName');
      print('📂 Carpeta: $folder');
      print('📏 Tamaño original: ${await imageFile.length()} bytes');

      // Comprimir imagen
      final compressedFile = await compressImage(imageFile, quality: quality);
      final fileToUpload = compressedFile ?? imageFile;

      print('📏 Tamaño comprimido: ${await fileToUpload.length()} bytes');

      // Convertir a base64
      final base64Image = await convertImageToBase64(fileToUpload);
      print('📊 Base64 length: ${base64Image.length}');

      // Llamar a Lambda
      print('🌐 Llamando a Lambda: $_apiUrl');

      final response = await http.post(
        _apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'upload',
          'fileBase64': base64Image,
          'fileName': fileName,
          'folder': folder,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Subida S3 exitosa: $result');
        return result;
      } else {
        throw Exception(
            'Error al subir la imagen: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('❌ Error en uploadImage: $e');
      rethrow;
    }
  }

  // ✅ MÉTODO OPTIMIZADO: Obtener URL pública DIRECTAMENTE (sin llamar a Lambda)
  static String getPublicUrl(String key) {
    if (key.isEmpty) return "";
    
    // ✅ Construir URL pública directamente - MÁS RÁPIDO
    return "$_publicBaseUrl/$key";
  }

  // ✅ MÉTODO COMPATIBILIDAD: Mantener getSignedUrl por si acaso
  static Future<String> getSignedUrl(String key) async {
    // Para imágenes públicas, podemos usar la URL directa
    // Pero mantenemos la llamada a Lambda por compatibilidad
    try {
      final response = await http.post(
        _apiUrl,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'action': 'sign',
          'key': key,
        }),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        return body['publicUrl'] ?? body['signedUrl'];
      } else {
        // ✅ FALLBACK: Si Lambda falla, usar URL pública directa
        print('⚠️ Lambda falló, usando URL pública directa');
        return getPublicUrl(key);
      }
    } catch (e) {
      // ✅ FALLBACK: Si hay error, usar URL pública directa
      print('⚠️ Error en getSignedUrl, usando URL pública directa: $e');
      return getPublicUrl(key);
    }
  }

  // Seleccionar imagen desde galería o cámara
  static Future<File?> pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 85, // Calidad media para ahorro
      maxWidth: 1080,
      maxHeight: 1080,
    );

    return pickedFile != null ? File(pickedFile.path) : null;
  }
}