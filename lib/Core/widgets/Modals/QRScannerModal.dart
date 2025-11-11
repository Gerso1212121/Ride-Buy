import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class QRScannerModal {
  // ✅ Modal para resultado del escaneo QR
  static Future<void> showQRResultModal({
    required BuildContext context,
    required bool success,
    required String message,
    Map<String, dynamic>? rentInfo,
    VoidCallback? onConfirm,
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _QRResultModalContent(
        success: success,
        message: message,
        rentInfo: rentInfo,
        onConfirm: onConfirm,
        onRetry: onRetry,
      ),
    );
  }

  // ✅ Modal de procesamiento (loading)
  static Future<void> showProcessingModal({
    required BuildContext context,
    String message = 'Procesando código QR...',
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ProcessingModalContent(message: message),
    );
  }

  // ✅ Modal de error específico para QR
  static Future<void> showQRErrorModal({
    required BuildContext context,
    required String title,
    required String message,
    VoidCallback? onRetry,
  }) async {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _QRErrorModalContent(
        title: title,
        message: message,
        onRetry: onRetry,
      ),
    );
  }
}

// =============================================
// CONTENIDO DE LOS MODALES
// =============================================

class _QRResultModalContent extends StatelessWidget {
  final bool success;
  final String message;
  final Map<String, dynamic>? rentInfo;
  final VoidCallback? onConfirm;
  final VoidCallback? onRetry;

  const _QRResultModalContent({
    required this.success,
    required this.message,
    this.rentInfo,
    this.onConfirm,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            success ? Icons.check_circle : Icons.error,
            color: success ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Text(
            success ? '¡Confirmación Exitosa!' : 'Error',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(message),
            if (success && rentInfo != null) ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Detalles de la renta:',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              _buildInfoItem('Vehículo', '${rentInfo!['marca']} ${rentInfo!['modelo']}'),
              _buildInfoItem('Placa', rentInfo!['placa']),
              _buildInfoItem('Cliente', rentInfo!['cliente_nombre']),
              _buildInfoItem('Estado', 'Confirmada'),
              _buildInfoItem('Empresa', rentInfo!['empresa_nombre']),
            ],
          ],
        ),
      ),
      actions: [
        if (!success)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry?.call();
            },
            child: const Text('Reintentar'),
          ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            if (success) {
              onConfirm?.call();
            }
          },
          child: Text(success ? 'Continuar' : 'Aceptar'),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}

class _ProcessingModalContent extends StatelessWidget {
  final String message;

  const _ProcessingModalContent({required this.message});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: FlutterFlowTheme.of(context).primary,
              strokeWidth: 4,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: FlutterFlowTheme.of(context).primaryText,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _QRErrorModalContent extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback? onRetry;

  const _QRErrorModalContent({
    required this.title,
    required this.message,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Text(
            title,
            style: GoogleFonts.lato(
              fontWeight: FontWeight.w700,
              color: Colors.red,
            ),
          ),
        ],
      ),
      content: Text(message),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRetry?.call();
            },
            child: const Text('Reintentar'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Aceptar'),
        ),
      ],
    );
  }
}