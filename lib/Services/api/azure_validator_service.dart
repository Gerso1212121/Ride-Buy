import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AzureValidatorService {
  static final String _baseUrl = dotenv.get('AZURE_VALIDATOR_URL');

  // ✅ AUMENTAR TIMEOUT Y AGREGAR REINTENTOS
  static Future<Map<String, dynamic>> validateVehicleImages({
    required File vehicleImage,
    required File plateImage,
    required String mode,
    int maxRetries = 2, // ✅ REINTENTOS EN CASO DE FALLO
  }) async {
    int attempt = 0;

    while (attempt <= maxRetries) {
      try {
        print('🔄 [Intento ${attempt + 1}] Iniciando validación IA...');
        print('📸 Vehículo: ${vehicleImage.path}');
        print('📸 Placa: ${plateImage.path}');
        print('🎯 Modo: $mode');

        // ✅ COMPROBAR SI LA API ESTÁ DISPONIBLE PRIMERO
        await _checkApiAvailability();

        // Convertir imágenes a base64
        final vehicleBase64 = await _fileToBase64(vehicleImage);
        final plateBase64 = await _fileToBase64(plateImage);

        // Verificar que las imágenes no estén vacías
        if (vehicleBase64.isEmpty || plateBase64.isEmpty) {
          throw Exception('Una o ambas imágenes están vacías');
        }

        print('📊 Tamaño base64 vehículo: ${vehicleBase64.length}');
        print('📊 Tamaño base64 placa: ${plateBase64.length}');

        // ✅ AUMENTAR TIMEOUT A 60 SEGUNDOS Y AGREGAR HEADERS
        final response = await http
            .post(
              Uri.parse('$_baseUrl/api/validar-vehiculo'),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
                'Connection': 'keep-alive',
              },
              body: jsonEncode({
                'vehicle_image': vehicleBase64,
                'plate_image': plateBase64,
                'mode': mode,
              }),
            )
            .timeout(const Duration(seconds: 60)); // ✅ 60 SEGUNDOS

        print('📡 Status: ${response.statusCode}');
        print('📡 Body: ${response.body}');

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          final valido = result['valido'] ?? false;
          final razon = result['razon'] ?? 'Sin razón especificada';

          print('✅ Validación IA: $valido');
          if (!valido) {
            print('❌ Razón: $razon');
          }

          return result;
        } else {
          // ✅ MANEJAR DIFERENTES CÓDIGOS DE ERROR
          if (response.statusCode >= 500) {
            throw Exception(
                'Error del servidor Azure (${response.statusCode})');
          } else {
            final error = jsonDecode(response.body);
            throw Exception('Error en validación IA: ${error['message']}');
          }
        }
      } catch (e) {
        attempt++;
        print('❌ Intento $attempt fallido: $e');

        if (attempt > maxRetries) {
          print('🚨 Todos los intentos fallaron');
          rethrow;
        }

        // ✅ ESPERAR ANTES DEL REINTENTO
        print('⏳ Esperando 5 segundos antes del reintento...');
        await Future.delayed(const Duration(seconds: 5));
      }
    }

    throw Exception(
        'No se pudo completar la validación después de $maxRetries intentos');
  }

  // ✅ MÉTODO PARA VERIFICAR DISPONIBILIDAD DE LA API
  static Future<void> _checkApiAvailability() async {
    try {
      print('🔍 Verificando disponibilidad de la API Azure...');
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        throw Exception('API no disponible - Status: ${response.statusCode}');
      }
      print('✅ API Azure disponible');
    } catch (e) {
      print('❌ API Azure no disponible: $e');
      throw Exception(
          'El servicio de validación IA no está disponible en este momento. Por favor, intenta más tarde.');
    }
  }

  static Future<String> _fileToBase64(File file,
      {bool includeMimePrefix = false}) async {
    try {
      final bytes = await file.readAsBytes();
      final base64String = base64Encode(bytes);

      if (includeMimePrefix) {
        // Para otros usos que necesiten el prefijo
        final fileExtension = file.path.split('.').last.toLowerCase();
        final mimeType = _getMimeType(fileExtension);
        return 'data:$mimeType;base64,$base64String';
      } else {
        // ✅ PARA OPENAI - SOLO BASE64 PURO
        return base64String;
      }
    } catch (e) {
      print('❌ Error convirtiendo a base64: $e');
      rethrow;
    }
  }

  static String _getMimeType(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  // ✅ MÉTODO ALTERNATIVO: Validación básica sin IA (para emergencias)
  static Future<Map<String, dynamic>> basicImageValidation({
    required File vehicleImage,
    required File plateImage,
  }) async {
    try {
      print('🔍 Realizando validación básica de imágenes...');

      // Validar que las imágenes existen y tienen tamaño
      if (!await vehicleImage.exists() || !await plateImage.exists()) {
        throw Exception('Una o ambas imágenes no existen');
      }

      final vehicleSize = await vehicleImage.length();
      final plateSize = await plateImage.length();

      if (vehicleSize == 0 || plateSize == 0) {
        throw Exception('Una o ambas imágenes están vacías');
      }

      // Validar formatos básicos
      if (!validateImageFormat(vehicleImage) ||
          !validateImageFormat(plateImage)) {
        throw Exception('Formato de imagen no válido. Use JPG, JPEG o PNG');
      }

      // Validar tamaños (máximo 10MB)
      if (!await validateImageSize(vehicleImage) ||
          !await validateImageSize(plateImage)) {
        throw Exception('Las imágenes son demasiado grandes. Máximo 10MB');
      }

      print('✅ Validación básica exitosa');
      return {
        'valido': true,
        'razon': 'Validación básica completada',
        'modo': 'basico'
      };
    } catch (e) {
      print('❌ Validación básica fallida: $e');
      return {'valido': false, 'razon': e.toString(), 'modo': 'basico'};
    }
  }

  static bool validateImageFormat(File image) {
    final path = image.path.toLowerCase();
    return path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.png');
  }

  static Future<bool> validateImageSize(File image,
      {int maxSizeMB = 10}) async {
    final sizeInBytes = await image.length();
    final sizeInMB = sizeInBytes / (1024 * 1024);
    return sizeInMB <= maxSizeMB;
  }
}
