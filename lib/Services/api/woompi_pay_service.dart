// Services/api/woompi_pay_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class WompiPaymentService {
  static final String _baseUrl = 'https://rideandbuypay.onrender.com';
  
  // ✅ CORREGIDO: Cambiar PaymentResult por WompiPaymentResult
  static Future<WompiPaymentResult> generatePaymentLink({
    required double amount,
    required String description,
    required String clientId,
    required String rentaId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://rideandbuypay.onrender.com/api/wompi/generar-enlace-renta'),
        headers: {
          'Content-Type': 'application/json',
          'User-Agent': 'EzRide/1.0.0 (Flutter)', // ✅ IDENTIFICAR APP
        },
        body: json.encode({
          'referencia': rentaId,
          'montoCents': amount,
          'descripcion': description,
          'clienteId': clientId,
          'fromApp': true, // ✅ EXPLÍCITAMENTE DECIR QUE ES APP
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WompiPaymentResult(
          success: true,
          paymentUrl: data['urlEnlace'],
          reference: data['referencia'],
        );
      } else {
        final error = json.decode(response.body);
        return WompiPaymentResult(
          success: false,
          error: error['error'] ?? 'Error desconocido',
        );
      }
    } catch (e) {
      return WompiPaymentResult(
        success: false,
        error: 'Error de conexión: $e',
      );
    }
  }


  // ✅ CORREGIDO: Actualizar el endpoint de verificación de estado
  static Future<WompiPaymentStatus> checkPaymentStatus(String referencia) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/wompi/estado/$referencia'), // ✅ Ruta corregida
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['ok'] == true) {
          return WompiPaymentStatus.fromString(data['estado'] ?? 'pendiente');
        }
      }
      return WompiPaymentStatus.pendiente;
    } catch (e) {
      print('❌ Error verificando pago: $e');
      return WompiPaymentStatus.pendiente;
    }
  }

  static Future<bool> launchPayment(String paymentUrl) async {
    try {
      final launched = await launchUrl(
        Uri.parse(paymentUrl),
        mode: LaunchMode.externalApplication,
      );
      
      return launched;
    } catch (e) {
      print('❌ Error abriendo enlace: $e');
      return false;
    }
  }
}

// ✅ CLASE CORREGIDA: WompiPaymentResult (no PaymentResult)
class WompiPaymentResult {
  final bool success;
  final String? paymentUrl;
  final String? reference;
  final String? rentaId;
  final String? error;

  WompiPaymentResult({
    required this.success,
    this.paymentUrl,
    this.reference,
    this.rentaId,
    this.error,
  });
}

enum WompiPaymentStatus {
  pendiente,
  aprobado,
  rechazado,
  fallido;

  static WompiPaymentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'aprobado':
      case 'procesado':
        return WompiPaymentStatus.aprobado;
      case 'rechazado':
        return WompiPaymentStatus.rechazado;
      case 'fallido':
        return WompiPaymentStatus.fallido;
      default:
        return WompiPaymentStatus.pendiente;
    }
  }
}