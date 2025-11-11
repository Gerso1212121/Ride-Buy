import 'dart:async';
import 'package:ezride/Core/widgets/Modals/QRScannerModal.dart';
import 'package:ezride/Services/utils/QRService.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:postgres/postgres.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  bool _isProcessing = false;
  bool _isFlashOn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Escanear Código QR',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black87,
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

    _procesarQRCode(barcode.rawValue!);
  }

  Future<void> _procesarQRCode(String qrData) async {
    // ✅ CORREGIDO: Verificar mounted antes de setState
    if (!mounted) return;
    
    setState(() {
      _isProcessing = true;
    });

    try {
      // 1. Validar estructura del QR
      final qrDataValidado = QRService.validateQRData(qrData);
      
      if (qrDataValidado == null) {
        throw Exception('Código QR inválido');
      }

      // 2. Obtener información completa de la renta
      final rentaInfo = await _obtenerInfoRentaCompleta(qrDataValidado['rentaId']);
      
      if (rentaInfo == null) {
        throw Exception('Renta no encontrada');
      }

      // 3. Verificar que el cliente sea el correcto
      final currentUser = SessionManager.currentProfile;
      if (currentUser?.id != rentaInfo['cliente_id']) {
        throw Exception('No tienes permisos para confirmar esta renta');
      }

      // 4. Verificar que la renta esté en estado pendiente
      if (rentaInfo['status'] != 'pendiente') {
        throw Exception('Esta renta ya fue ${_getEstadoTexto(rentaInfo['status'])}');
      }

      // 5. Actualizar estado de la renta y vehículo
      await _actualizarEstadoRentaYVehiculo(qrDataValidado['rentaId'], rentaInfo['vehiculo_id']);

      // ✅ CORREGIDO: Verificar mounted antes de mostrar modal
      if (!mounted) return;
      
      // 6. Mostrar éxito usando el modal especializado
      await QRScannerModal.showQRResultModal(
        context: context,
        success: true,
        message: '¡Renta confirmada exitosamente!',
        rentInfo: rentaInfo,
        onConfirm: () {
          if (mounted) {
            Navigator.pop(context); // Cerrar scanner
          }
        },
      );

    } catch (e) {
      // ✅ CORREGIDO: Verificar mounted antes de mostrar error
      if (!mounted) return;
      
      await QRScannerModal.showQRResultModal(
        context: context,
        success: false,
        message: 'Error: ${e.toString()}',
        onRetry: () {
          // Reactivar cámara solo si el widget está montado
          if (mounted) {
            cameraController.start();
          }
        },
      );
    } finally {
      // ✅ CORREGIDO: Verificar mounted antes de setState
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _actualizarEstadoRentaYVehiculo(String rentaId, String vehiculoId) async {
    try {
      await RenderDbClient.runTransaction((session) async {
        // 1. Actualizar renta a 'confirmada'
        const sqlRenta = '''
          UPDATE public.rentas 
          SET status = 'confirmada',
              updated_at = NOW()
          WHERE id = @renta_id
        ''';

        await session.execute(
          Sql.named(sqlRenta),
          parameters: {'renta_id': rentaId},
        );

        // 2. Actualizar vehículo a 'en_renta'
        const sqlVehiculo = '''
          UPDATE public.vehiculos 
          SET estado = 'en_renta',
              updated_at = NOW()
          WHERE id = @vehiculo_id
        ''';

        await session.execute(
          Sql.named(sqlVehiculo),
          parameters: {'vehiculo_id': vehiculoId},
        );
      });

      print('✅ Estados actualizados: Renta $rentaId confirmada, Vehículo $vehiculoId en renta');
    } catch (e) {
      print('❌ Error actualizando estados: $e');
      throw Exception('Error al actualizar los estados');
    }
  }

  String _getEstadoTexto(String status) {
    switch (status) {
      case 'pendiente': return 'pendiente';
      case 'confirmada': return 'confirmada';
      case 'en_curso': return 'en curso';
      case 'finalizada': return 'finalizada';
      case 'cancelada': return 'cancelada';
      default: return status;
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
          stops: const [0.5, 1.0],
        ),
      ),
      child: Center(
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
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
            'Escanea el código QR de confirmación',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (_isProcessing)
            Column(
              children: [
                const CircularProgressIndicator(color: Colors.white),
                const SizedBox(height: 8),
                Text(
                  'Procesando...',
                  style: GoogleFonts.lato(color: Colors.white),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }
}