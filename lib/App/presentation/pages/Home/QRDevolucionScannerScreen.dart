import 'dart:async';

import 'package:ezride/Core/widgets/Modals/GlobalModalAction.widget.dart';
import 'package:ezride/Services/utils/QRService.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ezride/App/DATA/models/rentas_model.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:postgres/postgres.dart';

class QRDevolucionScannerScreen extends StatefulWidget {
  const QRDevolucionScannerScreen({super.key});

  @override
  State<QRDevolucionScannerScreen> createState() => _QRDevolucionScannerScreenState();
}

class _QRDevolucionScannerScreenState extends State<QRDevolucionScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  bool _isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Escanear QR de Devolución',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(_isFlashOn ? Icons.flash_on : Icons.flash_off),
            onPressed: () {
              setState(() {
                _isFlashOn = !_isFlashOn;
              });
              cameraController.toggleTorch();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Scanner de cámara
          MobileScanner(
            controller: cameraController,
            onDetect: _capturarQR,
          ),

          // Overlay con guías
          _buildScannerOverlay(),

          // Panel inferior
          _buildBottomPanel(),
        ],
      ),
    );
  }

  void _capturarQR(BarcodeCapture capture) {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    _procesarQRDevolucion(barcode.rawValue!);
  }

  Future<void> _procesarQRDevolucion(String qrData) async {
    setState(() {
      _isProcessing = true;
    });

    try {
      print('🔍 Procesando QR Devolución: ${qrData.substring(0, 50)}...');

      // 1. Validar estructura del QR de devolución
      final qrDataValidado = QRService.validateQRDataDevolucion(qrData);
      if (qrDataValidado == null) {
        throw Exception('Código QR de devolución inválido');
      }

      // 2. Obtener información completa de la renta
      final rentaInfo = await _obtenerInfoRentaCompleta(qrDataValidado['rentaId']);
      if (rentaInfo == null) {
        throw Exception('No se encontró información de la renta');
      }

      // 3. Verificar que el empresario sea el correcto
      final currentEmpresa = SessionManager.currentEmpresa;
      if (currentEmpresa?.id != rentaInfo['empresa_id']) {
        throw Exception('No tienes permisos para procesar esta devolución');
      }

      // 4. Verificar que la renta esté en estado 'en_curso' o 'confirmada'
      if (rentaInfo['status'] != 'en_curso' && rentaInfo['status'] != 'confirmada') {
        throw Exception('Esta renta no está en curso, no se puede devolver');
      }

      // 5. Procesar la devolución
      await _procesarDevolucionRenta(qrDataValidado['rentaId'], rentaInfo['vehiculo_id']);

      // 6. Mostrar éxito
      _mostrarResultadoDevolucion(
        exito: true,
        mensaje: '¡Devolución procesada exitosamente!',
        rentaInfo: rentaInfo,
      );

    } catch (e) {
      print('❌ Error procesando QR devolución: $e');
      _mostrarResultadoDevolucion(
        exito: false,
        mensaje: 'Error: ${e.toString()}',
      );
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<Map<String, dynamic>?> _obtenerInfoRentaCompleta(String rentaId) async {
    try {
      const sql = '''
        SELECT 
          r.*,
          v.marca,
          v.modelo,
          v.placa,
          v.estado as estado_vehiculo,
          p.display_name as cliente_nombre,
          p.phone as cliente_telefono,
          e.nombre as empresa_nombre
        FROM public.rentas r
        INNER JOIN public.vehiculos v ON r.vehiculo_id = v.id
        INNER JOIN public.profiles p ON r.cliente_id = p.id
        INNER JOIN public.empresas e ON r.empresa_id = e.id
        WHERE r.id = @renta_id
      ''';

      final result = await RenderDbClient.query(sql, parameters: {
        'renta_id': rentaId,
      });

      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('❌ Error obteniendo info renta: $e');
      return null;
    }
  }

// En QRDevolucionScannerScreen - MEJORAR
Future<void> _procesarDevolucionRenta(String rentaId, String vehiculoId) async {
  try {
    // ✅ USAR TRANSACCIÓN PARA GARANTIZAR CONSISTENCIA
    await RenderDbClient.runTransaction((session) async {
      // 1. Actualizar estado de la renta a 'finalizada'
      const sqlRenta = '''
        UPDATE public.rentas 
        SET status = 'finalizada',
            updated_at = NOW()
        WHERE id = @renta_id
      ''';

      await session.execute(
        Sql.named(sqlRenta),
        parameters: {'renta_id': rentaId},
      );

      // 2. Actualizar estado del vehículo a 'disponible'
      const sqlVehiculo = '''
        UPDATE public.vehiculos 
        SET estado = 'disponible',
            updated_at = NOW()
        WHERE id = @vehiculo_id
      ''';

      await session.execute(
        Sql.named(sqlVehiculo),
        parameters: {'vehiculo_id': vehiculoId},
      );
    });

    print('✅ Devolución procesada: Renta $rentaId finalizada, Vehículo $vehiculoId disponible');
  } catch (e) {
    print('❌ Error procesando devolución: $e');
    throw Exception('Error al procesar la devolución: $e');
  }
}

  void _mostrarResultadoDevolucion({
    required bool exito,
    required String mensaje,
    Map<String, dynamic>? rentaInfo,
  }) {
    // Construir el mensaje detallado
    String mensajeCompleto = mensaje;
    
    if (exito && rentaInfo != null) {
      mensajeCompleto += '\n\nDetalles de la devolución:\n'
          '• Vehículo: ${rentaInfo['marca']} ${rentaInfo['modelo']}\n'
          '• Placa: ${rentaInfo['placa']}\n'
          '• Cliente: ${rentaInfo['cliente_nombre']}\n'
          '• Estado: Finalizada\n'
          '• Vehículo: Disponible\n'
          '• Empresa: ${rentaInfo['empresa_nombre']}';
    }

    showGlobalStatusModalAction(
      context,
      title: exito ? '¡Devolución Exitosa!' : 'Error en Devolución',
      message: mensajeCompleto,
      icon: exito ? Icons.check_circle : Icons.error,
      iconColor: exito ? Colors.green : Colors.red,
      confirmText: exito ? 'Continuar' : 'Reintentar',
      onConfirm: () {
        if (exito) {
          Navigator.pop(context); // Cerrar scanner después del éxito
        }
      },
    );
  }

  Widget _buildScannerOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Colors.transparent,
            Colors.black.withOpacity(0.6),
          ],
          stops: [0.5, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.blue,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Text(
            'Escanea el código QR de devolución',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 16),
          if (_isProcessing)
            Column(
              children: [
                CircularProgressIndicator(color: Colors.white),
                SizedBox(height: 8),
                Text(
                  'Procesando devolución...',
                  style: GoogleFonts.lato(color: Colors.white),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // ✅ MÉTODO PARA MANEJO UNIFICADO DE ERRORES
void _manejarErrorQR(dynamic error) {
  String mensaje = 'Error desconocido';
  
  if (error is TimeoutException) {
    mensaje = 'Tiempo de espera agotado. Intenta nuevamente.';
  } else if (error is FormatException) {
    mensaje = 'Código QR inválido o dañado.';
  } else if (error.toString().contains('permisos')) {
    mensaje = 'No tienes permisos para esta acción.';
  } else if (error.toString().contains('expirado')) {
    mensaje = 'El código QR ha expirado.';
  } else if (error.toString().contains('estado')) {
    mensaje = error.toString();
  } else {
    mensaje = 'Error: ${error.toString()}';
  }
  
  _mostrarDialogoError(mensaje);
}

// ✅ MÉTODO AUXILIAR PARA MOSTRAR ERROR
void _mostrarDialogoError(String mensaje) {
  showGlobalStatusModalAction(
    context,
    title: 'Error',
    message: mensaje,
    icon: Icons.error,
    iconColor: Colors.red,
    confirmText: 'Aceptar',
  );
}

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}