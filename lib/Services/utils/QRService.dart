import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:ezride/App/DATA/models/rentas_model.dart';

class QRService {
  // ✅ MÉTODO MEJORADO: Generar QR desde el modelo completo
  static Widget generateRentaQRFromModel({
    required RentaModel renta,
    double size = 200,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final qrData = renta.toQRData();
    
    return QrImageView(
      data: jsonEncode(qrData),
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      padding: EdgeInsets.all(10),
      errorStateBuilder: (cxt, err) {
        return Container(
          width: size,
          height: size,
          color: Colors.grey[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.red, size: 40),
              SizedBox(height: 8),
              Text(
                'Error generando QR',
                textAlign: TextAlign.center, // ✅ CORREGIDO
                style: TextStyle(fontSize: 12, color: Colors.red),
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ MÉTODO PARA VALIDAR QR CON EL MODELO
  static bool validateQRWithModel(String scannedData, RentaModel renta) {
    try {
      final qrData = validateQRData(scannedData);
      return renta.validarDatosQR(qrData!);
    } catch (e) {
      return false;
    }
  }

  // ✅ MÉTODO PARA EXTRAER INFORMACIÓN LEGIBLE DEL QR
  static String formatQRInfoForDisplay(Map<String, dynamic> qrData) {
    return '''
🔐 CÓDIGO DE CONFIRMACIÓN
────────────────────
👤 CLIENTE: ${qrData['clienteNombre']}
📞 TELÉFONO: ${qrData['clienteTelefono']}
🚗 VEHÍCULO: ${qrData['vehiculoInfo']}
🏢 EMPRESA: ${qrData['empresaNombre']}
📅 PERÍODO: ${_formatDateFromISO(qrData['fechaInicio'])} - ${_formatDateFromISO(qrData['fechaFin'])}
💰 TOTAL: \$${qrData['totalRenta']}
📋 DÍAS: ${qrData['diasRenta']}
🔒 CÓDIGO: ${qrData['verificationCode']}
🕐 GENERADO: ${_formatTimestamp(qrData['timestamp'])}
''';
  }

  // ✅ VALIDAR ESTRUCTURA DEL QR (método existente mejorado)
  static Map<String, dynamic>? validateQRData(String scannedData) {
    try {
      final data = jsonDecode(scannedData);
      
      // Validar estructura básica
      if (data['type'] != 'renta_confirmation') {
        throw Exception('Tipo de QR inválido');
      }
      
      if (data['rentaId'] == null || data['verificationCode'] == null) {
        throw Exception('Datos de renta incompletos');
      }

      // Validar timestamp (máximo 24 horas de antigüedad)
      final timestamp = data['timestamp'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      if (now - timestamp > 24 * 60 * 60 * 1000) { // 24 horas
        throw Exception('QR expirado');
      }
      
      return data;
    } catch (e) {
      throw Exception('QR inválido: ${e.toString()}');
    }
  }

  // ✅ MÉTODO PARA GENERAR QR CON PARÁMETROS INDIVIDUALES
  static Widget generateRentaQR({
    required String rentaId,
    required String verificationCode,
    required String empresaId,
    required String clienteId,
    double size = 200,
    Color? backgroundColor,
    Color? foregroundColor,
  }) {
    final qrData = {
      'type': 'renta_confirmation',
      'rentaId': rentaId,
      'verificationCode': verificationCode,
      'empresaId': empresaId,
      'clienteId': clienteId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    return QrImageView(
      data: jsonEncode(qrData),
      version: QrVersions.auto,
      size: size,
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black,
      padding: EdgeInsets.all(10),
    );
  }

  // ✅ MÉTODOS AUXILIARES
  static String _formatDateFromISO(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  static String _formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  // ✅ MÉTODO PARA OBTENER RESUMEN RÁPIDO
  static Map<String, String> getQuickSummary(Map<String, dynamic> qrData) {
    return {
      'Cliente': qrData['clienteNombre'] ?? 'No disponible',
      'Vehículo': qrData['vehiculoInfo'] ?? 'No disponible',
      'Empresa': qrData['empresaNombre'] ?? 'No disponible',
      'Código': qrData['verificationCode'] ?? 'No disponible',
    };
  }
  // ✅ MÉTODO PARA GENERAR QR DE DEVOLUCIÓN
static Widget generateRentaDevolucionQRFromModel({
  required RentaModel renta,
  double size = 200,
  Color? backgroundColor,
  Color? foregroundColor,
}) {
  final qrData = renta.toQRDataDevolucion();
  
  return QrImageView(
    data: jsonEncode(qrData),
    version: QrVersions.auto,
    size: size,
    backgroundColor: backgroundColor ?? Colors.white,
    foregroundColor: foregroundColor ?? Colors.black,
    padding: EdgeInsets.all(10),
    errorStateBuilder: (cxt, err) {
      return Container(
        width: size,
        height: size,
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 40),
            SizedBox(height: 8),
            Text(
              'Error generando QR',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: Colors.red),
            ),
          ],
        ),
      );
    },
  );
}

// ✅ VALIDAR QR DE DEVOLUCIÓN
static Map<String, dynamic>? validateQRDataDevolucion(String scannedData) {
  try {
    final data = jsonDecode(scannedData);
    
    // Validar estructura básica
    if (data['type'] != 'devolucion_vehiculo') {
      throw Exception('Tipo de QR inválido para devolución');
    }
    
    if (data['rentaId'] == null || data['verificationCode'] == null) {
      throw Exception('Datos de devolución incompletos');
    }

    // Validar timestamp (máximo 24 horas de antigüedad)
    final timestamp = data['timestamp'] as int;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    if (ahora - timestamp > 24 * 60 * 60 * 1000) { // 24 horas
      throw Exception('El código QR de devolución ha expirado');
    }
    
    return data;
  } catch (e) {
    throw Exception('QR de devolución inválido: ${e.toString()}');
  }
}

// ✅ FORMATEAR INFORMACIÓN DE DEVOLUCIÓN
static String formatQRDevolucionInfo(Map<String, dynamic> qrData) {
  return '''
🔐 CÓDIGO DE DEVOLUCIÓN
────────────────────
👤 CLIENTE: ${qrData['clienteNombre']}
📞 TELÉFONO: ${qrData['clienteTelefono']}
🚗 VEHÍCULO: ${qrData['vehiculoInfo']}
🏢 EMPRESA: ${qrData['empresaNombre']}
📅 PERÍODO RENTA: ${qrData['periodo']}
💰 TOTAL: \$${qrData['total']}
🔒 CÓDIGO: ${qrData['verificationCode']}
🕐 FECHA DEVOLUCIÓN: ${_formatTimestamp(qrData['timestamp'])}
''';
}
}