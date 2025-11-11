// lib/Core/services/qr_modal_service.dart
import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/App/DATA/models/RentaClienteModel.dart';
import 'package:ezride/App/DATA/models/rentas_model.dart';
import 'package:ezride/App/DATA/models/USERRENT_MODEL.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Services/utils/QRService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QRModalService {
  // Colores personalizados para la paleta verde/azul
  static const Color primaryGreen = Color(0xFF00B894);
  static const Color primaryBlue = Color(0xFF0984E3);
  static const Color secondaryBlue = Color(0xFF74B9FF);
  static const Color lightBlue = Color(0xFFDFF6FF);
  static const Color darkGreen = Color(0xFF00A085);
  static const Color accentTeal = Color(0xFF00CEC9);

  // ✅ MÉTODO: Mostrar diálogo con QR de Confirmación
  static void showQRConfirmationModal({
    required BuildContext context,
    required RentaClienteModel solicitud,
    required EmpresasModel empresaData,
    required VoidCallback onConfirmManual,
  }) {
    // Convertir RentaClienteModel a RentaModel temporal para QR
    final rentaModel = RentaModel(
      id: solicitud.rentaId,
      vehiculoId: solicitud.vehiculoId,
      empresaId: empresaData.id,
      clienteId: solicitud.clienteId,
      tipo: RentaTipo.renta,
      fechaReserva: solicitud.fechaReserva,
      fechaInicioRenta: solicitud.fechaInicio,
      fechaEntregaVehiculo: solicitud.fechaFin,
      pickupMethod: PickupMethod.agencia,
      total: solicitud.total,
      status: RentalStatus.pendiente,
      verificationCode: _generarCodigoVerificacion(solicitud.rentaId),
      createdAt: DateTime.now(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.qr_code_2, color: primaryGreen),
            SizedBox(width: 8),
            Text(
              'Código QR de Confirmación',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Escanea este código para confirmar la renta',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: Color(0xFF636E72),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFFDFE6E9)),
              ),
              child: QRService.generateRentaQRFromModel(
                renta: rentaModel,
                size: 200,
              ),
            ),
            SizedBox(height: 16),
            _buildInfoDetallesQR(solicitud),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirmManual();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: Text('Confirmar Manualmente'),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODO: Mostrar diálogo con QR de Confirmación Mejorado
  static void showQRConfirmationModalMejorado({
    required BuildContext context,
    required RentaClienteModel solicitud,
    required EmpresasModel empresaData,
    required VoidCallback onConfirmManual,
  }) {
    try {
      // ✅ GENERAR QR SIN CÓDIGO DE VERIFICACIÓN
      final rentaModel = RentaModel(
        id: solicitud.rentaId,
        vehiculoId: solicitud.vehiculoId,
        empresaId: empresaData.id,
        clienteId: solicitud.clienteId,
        tipo: RentaTipo.renta,
        fechaReserva: solicitud.fechaReserva,
        fechaInicioRenta: solicitud.fechaInicio,
        fechaEntregaVehiculo: solicitud.fechaFin,
        pickupMethod: PickupMethod.agencia,
        total: solicitud.total,
        status: RentalStatus.pendiente,
        // ✅ NO INCLUIR verificationCode - no existe en BD
        verificationCode: null,
        createdAt: DateTime.now(),
        clienteNombre: solicitud.nombreCliente,
        clientePhone: solicitud.telefonoCliente,
        vehiculoMarca: solicitud.marca,
        vehiculoModelo: solicitud.modelo,
        empresaNombre: empresaData.nombre,
      );

      // Mostrar diálogo con QR
      showDialog(
        context: context,
        builder: (context) => _buildDialogQRMejorado(
          context: context, // ✅ CORREGIDO: Pasar el context
          rentaModel: rentaModel,
          solicitud: solicitud,
          onConfirmManual: onConfirmManual,
        ),
      );
    } catch (e) {
      print('❌ Error generando QR: $e');
      _mostrarSnackbar(context, 'Error al generar el código QR: $e', Colors.red);
    }
  }

  // ✅ MÉTODO: Mostrar diálogo con QR de Devolución
  static void showQRDevolucionModal({
    required BuildContext context,
    required UserRentaModel renta,
    required String clienteId,
  }) {
    try {
      // Convertir UserRentaModel a RentaModel temporal para QR
      final rentaModel = RentaModel(
        id: renta.rentaId,
        vehiculoId: renta.vehiculoId,
        empresaId: renta.empresaId,
        clienteId: clienteId,
        tipo: RentaTipo.renta,
        fechaReserva: renta.fechaReserva,
        fechaInicioRenta: renta.fechaInicio,
        fechaEntregaVehiculo: renta.fechaFin,
        pickupMethod: PickupMethod.agencia,
        total: renta.total,
        status: RentalStatus.enCurso,
        verificationCode: renta.verificationCode,
        createdAt: DateTime.now(),
      );

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.qr_code_2, color: Colors.blue),
              SizedBox(width: 8),
              Text('QR de Devolución'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Muestra este QR al empresario para devolver el vehículo',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              QRService.generateRentaDevolucionQRFromModel(
                renta: rentaModel,
                size: 200,
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      'Vehículo: ${renta.marca} ${renta.modelo}',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text('Placa: ${renta.placa}'),
                    SizedBox(height: 4),
                    Text('Estado: Para Devolución'),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      print('❌ Error generando QR de devolución: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar QR de devolución: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ✅ MÉTODO AUXILIAR: Generar código de verificación
  static String _generarCodigoVerificacion(String rentaId) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = timestamp % 10000;
    return 'VC${rentaId.substring(0, 4).toUpperCase()}$random';
  }

  // ✅ MÉTODO: Diálogo QR mejorado - CORREGIDO
  static Widget _buildDialogQRMejorado({
    required BuildContext context, // ✅ CORREGIDO: Agregar context como parámetro
    required RentaModel rentaModel,
    required RentaClienteModel solicitud,
    required VoidCallback onConfirmManual,
  }) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.qr_code_2, color: primaryGreen, size: 28),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Código QR de Confirmación',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436),
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'El cliente debe escanear este código para confirmar la renta',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                color: Color(0xFF636E72),
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            
            // QR Container mejorado
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color(0xFFDFE6E9), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  QRService.generateRentaQRFromModel(
                    renta: rentaModel,
                    size: 200,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Código: ${rentaModel.verificationCode ?? "No generado"}',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600,
                      color: primaryGreen,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            
            // Información detallada
            _buildInfoDetallesQRMejorado(rentaModel, solicitud),
            SizedBox(height: 16),
            
            // Instrucciones
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightBlue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📱 Instrucciones:',
                    style: GoogleFonts.lato(
                      fontWeight: FontWeight.w600,
                      color: primaryBlue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. El cliente debe abrir la app EZ-Ride\n'
                    '2. Ir a "Historial" de rentas\n'
                    '3. Seleccionar "Escanear QR"\n'
                    '4. Apuntar la cámara a este código\n'
                    '5. Confirmar la renta',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: Color(0xFF636E72),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context), // ✅ CORREGIDO: Usar el context del parámetro
          child: Text('Cerrar', style: GoogleFonts.lato()),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context); // ✅ CORREGIDO: Usar el context del parámetro
            onConfirmManual();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryGreen,
            foregroundColor: Colors.white,
          ),
          child: Text('Confirmar Manualmente'),
        ),
      ],
    );
  }

  // ✅ MÉTODO: Información mejorada del QR
  static Widget _buildInfoDetallesQRMejorado(RentaModel rentaModel, RentaClienteModel solicitud) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles de la renta:',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: primaryBlue,
            ),
          ),
          SizedBox(height: 8),
          _buildInfoItemQR('Vehículo', '${solicitud.marca} ${solicitud.modelo}'),
          _buildInfoItemQR('Cliente', solicitud.nombreCliente),
          _buildInfoItemQR('Teléfono', solicitud.telefonoCliente.isNotEmpty ? solicitud.telefonoCliente : 'No disponible'),
          _buildInfoItemQR('Período', 
              '${_formatDate(solicitud.fechaInicio)} - ${_formatDate(solicitud.fechaFin)}'),
          _buildInfoItemQR('Días', '${_calcularDias(solicitud.fechaInicio, solicitud.fechaFin)} días'),
          _buildInfoItemQR('Total', '\$${solicitud.total.toStringAsFixed(2)}'),
          _buildInfoItemQR('Código QR', rentaModel.verificationCode ?? 'No generado'),
        ],
      ),
    );
  }

  // ✅ WIDGET AUXILIAR: Información del QR
  static Widget _buildInfoDetallesQR(RentaClienteModel solicitud) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: lightBlue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detalles de la renta:',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: primaryBlue,
            ),
          ),
          SizedBox(height: 8),
          _buildInfoItemQR('Vehículo', '${solicitud.marca} ${solicitud.modelo}'),
          _buildInfoItemQR('Cliente', solicitud.nombreCliente),
          _buildInfoItemQR('Período', 
              '${_formatDate(solicitud.fechaInicio)} - ${_formatDate(solicitud.fechaFin)}'),
          _buildInfoItemQR('Total', '\$${solicitud.total.toStringAsFixed(2)}'),
        ],
      ),
    );
  }

  static Widget _buildInfoItemQR(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              color: Color(0xFF636E72),
              fontSize: 12,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: Color(0xFF2D3436),
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODOS AUXILIARES
  static String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static int _calcularDias(DateTime inicio, DateTime fin) {
    return fin.difference(inicio).inDays;
  }

  static void _mostrarSnackbar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}