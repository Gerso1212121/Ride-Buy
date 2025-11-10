import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AzureValidatorService {
  static final String _baseUrl = dotenv.get('AZURE_VALIDATOR_URL');

  static Future<Map<String, dynamic>> validateVehicleImages({
    required File vehicleImage,
    required File plateImage,
    required String mode, // 'estricto' o 'flexible'
  }) async {
    try {
      // Convertir imágenes a base64
      final vehicleBase64 = await _fileToBase64(vehicleImage);
      final plateBase64 = await _fileToBase64(plateImage);

      print('🔄 Enviando imágenes para validación con Azure GPT-4o...');
      print('📁 Modo: $mode');
      print('📸 Tamaño vehículo: ${vehicleBase64.length}');
      print('📸 Tamaño placa: ${plateBase64.length}');

      final response = await http.post(
        Uri.parse('$_baseUrl/api/validar-vehiculo'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'vehicle_image': vehicleBase64,
          'plate_image': plateBase64,
          'mode': mode,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('✅ Validación exitosa: ${result['valido']}');
        return result;
      } else {
        final error = jsonDecode(response.body);
        throw Exception('Error en validación: ${error['message']}');
      }
    } catch (e) {
      print('❌ Error en AzureValidatorService: $e');
      rethrow;
    }
  }

  static Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    return base64Encode(bytes);
  }
}
