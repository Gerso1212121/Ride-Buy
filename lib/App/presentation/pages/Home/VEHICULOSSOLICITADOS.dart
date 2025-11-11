import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/App/DATA/models/RentaClienteModel.dart';
import 'package:ezride/Core/enums/enums.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Core/widgets/Modals/GlobalModalAction.widget.dart';
import 'package:ezride/Core/widgets/Modals/QRModal_Service.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:ezride/Services/utils/QRService.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ezride/App/DATA/models/rentas_model.dart';

class SolicitudesPendientesScreen extends StatefulWidget {
  const SolicitudesPendientesScreen({super.key});

  @override
  State<SolicitudesPendientesScreen> createState() =>
      _SolicitudesPendientesScreenState();
}

class _SolicitudesPendientesScreenState
    extends State<SolicitudesPendientesScreen> {
  final List<RentaClienteModel> _solicitudesPendientes = [];
  bool _isLoading = true;
  EmpresasModel? _empresaData;

  // Colores personalizados para la paleta verde/azul
  static const Color primaryGreen = Color(0xFF00B894);
  static const Color primaryBlue = Color(0xFF0984E3);
  static const Color secondaryBlue = Color(0xFF74B9FF);
  static const Color lightBlue = Color(0xFFDFF6FF);
  static const Color darkGreen = Color(0xFF00A085);
  static const Color accentTeal = Color(0xFF00CEC9);

  @override
  void initState() {
    super.initState();
    _empresaData = SessionManager.currentEmpresa;
    _cargarSolicitudesPendientes();
  }

  Future<void> _cargarSolicitudesPendientes() async {
    if (_empresaData == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      const sql = '''
  SELECT 
    r.id as renta_id,
    r.vehiculo_id,
    r.cliente_id,
    r.fecha_inicio_renta as fecha_inicio,
    r.fecha_entrega_vehiculo as fecha_fin,
    r.fecha_reserva,
    r.total,
    r.status,
    
    -- Datos del vehículo
    v.marca,
    v.modelo,
    v.placa,
    v.color,
    v.anio,
    v.imagen1 as imagen_vehiculo,
    v.precio_por_dia,
    
    -- Datos del cliente
    p.display_name as nombre_cliente,
    p.email as email_cliente,
    p.phone as telefono_cliente,
    p.dui_number as dui_cliente
    
  FROM public.rentas r
  INNER JOIN public.vehiculos v ON r.vehiculo_id = v.id
  INNER JOIN public.profiles p ON r.cliente_id = p.id
  WHERE r.empresa_id = @empresa_id
  AND r.status = 'pendiente'
  ORDER BY r.fecha_reserva DESC
''';

      final result = await RenderDbClient.query(sql, parameters: {
        'empresa_id': _empresaData!.id,
      });

      setState(() {
        _solicitudesPendientes.clear();
        for (final row in result) {
          try {
            _solicitudesPendientes.add(RentaClienteModel.fromJson(row));
          } catch (e) {
            print('❌ Error parseando solicitud: $e');
          }
        }
      });
    } catch (e, stackTrace) {
      print('❌ Error cargando solicitudes pendientes: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ NUEVO MÉTODO: Mostrar diálogo con QR
void _mostrarCodigoQR(RentaClienteModel solicitud) {
  QRModalService.showQRConfirmationModal(
    context: context, // Pasar el context de tu widget
    solicitud: solicitud,
    empresaData: _empresaData!,
    onConfirmManual: () => _confirmarSolicitud(solicitud.rentaId),
  );
}

  // ✅ MÉTODO AUXILIAR: Generar código de verificación
  String _generarCodigoVerificacion(String rentaId) {
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    final random = timestamp % 10000;
    return 'VC${rentaId.substring(0, 4).toUpperCase()}$random';
  }

void _mostrarCodigoQRMejorado(RentaClienteModel solicitud) {
  QRModalService.showQRConfirmationModalMejorado(
    context: context, // Pasar el context de tu widget
    solicitud: solicitud,
    empresaData: _empresaData!,
    onConfirmManual: () => _confirmarSolicitud(solicitud.rentaId),
  );
}



// ✅ NUEVO MÉTODO: Diálogo QR mejorado
Widget _buildDialogQRMejorado(RentaModel rentaModel, RentaClienteModel solicitud) {
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
                  'Código: ${rentaModel.verificationCode}',
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
        onPressed: () => Navigator.pop(context),
        child: Text('Cerrar', style: GoogleFonts.lato()),
      ),
      ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          _confirmarSolicitud(solicitud.rentaId);
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

// ✅ NUEVO MÉTODO: Información mejorada del QR
Widget _buildInfoDetallesQRMejorado(RentaModel rentaModel, RentaClienteModel solicitud) {
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
  Widget _buildInfoDetallesQR(RentaClienteModel solicitud) {
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

  Widget _buildInfoItemQR(String label, String value) {
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

  // ✅ ACTUALIZAR el botón en _buildTarjetaSolicitud para incluir QR
  Widget _buildQRActionButton(RentaClienteModel solicitud) {
    return Expanded(
      child: _buildCustomButton(
        text: 'Generar QR',
        onPressed: () => _mostrarCodigoQR(solicitud),
        backgroundColor: primaryBlue,
        textColor: Colors.white,
        icon: Icons.qr_code_2,
      ),
    );
  }

  Future<void> _confirmarSolicitud(String rentaId) async {
    try {
      const sql = '''
      UPDATE public.rentas 
      SET status = 'confirmada'
      WHERE id = @renta_id
      RETURNING *
    ''';

      final result = await RenderDbClient.query(sql, parameters: {
        'renta_id': rentaId,
      });

      if (result.isNotEmpty) {
        _mostrarSnackbar('✅ Solicitud confirmada exitosamente', primaryGreen);
        _cargarSolicitudesPendientes();
      }
    } catch (e) {
      _mostrarSnackbar('❌ Error al confirmar solicitud: $e', Colors.red);
    }
  }

  Future<void> _cancelarSolicitud(String rentaId) async {
    try {
      const sql = '''
      UPDATE public.rentas 
      SET status = 'cancelada'
      WHERE id = @renta_id
      RETURNING *
    ''';

      final result = await RenderDbClient.query(sql, parameters: {
        'renta_id': rentaId,
      });

      if (result.isNotEmpty) {
        _mostrarSnackbar('✅ Solicitud cancelada exitosamente', Colors.orange);
        _cargarSolicitudesPendientes();
      }
    } catch (e) {
      _mostrarSnackbar('❌ Error al cancelar solicitud: $e', Colors.red);
    }
  }

  void _mostrarSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        colorScheme: ColorScheme.light(
          primary: primaryGreen,
          onPrimary: Colors.white,
          secondary: primaryBlue,
          surface: Colors.white,
          onSurface: Color(0xFF2D3436),
          surfaceVariant: lightBlue,
          onSurfaceVariant: Color(0xFF636E72),
          outline: Color(0xFFDFE6E9),
          background: Color(0xFFF8F9FA),
        ),
        useMaterial3: true,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F9FA),
        appBar: _buildAppBar(),
        body: _isLoading
            ? _buildLoadingState()
            : _solicitudesPendientes.isEmpty
                ? _buildEmptyState()
                : _buildListaSolicitudes(),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Solicitudes Pendientes',
        style: GoogleFonts.lato(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          fontSize: 20,
        ),
      ),
      backgroundColor: primaryBlue,
      foregroundColor: Colors.white,
      elevation: 2,
      shadowColor: primaryBlue.withOpacity(0.3),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: Colors.white),
          onPressed: _cargarSolicitudesPendientes,
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: CircularProgressIndicator(
              color: primaryBlue,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando solicitudes...',
            style: GoogleFonts.lato(
              color: Color(0xFF636E72),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Text(
                '📋',
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay solicitudes pendientes',
              style: GoogleFonts.lato(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2D3436),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Todas las solicitudes han sido procesadas',
              style: GoogleFonts.lato(
                color: Color(0xFF636E72),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildCustomButton(
              text: 'Actualizar Lista',
              onPressed: _cargarSolicitudesPendientes,
              backgroundColor: primaryBlue,
              textColor: Colors.white,
              icon: Icons.refresh,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListaSolicitudes() {
    return RefreshIndicator(
      onRefresh: _cargarSolicitudesPendientes,
      backgroundColor: Colors.white,
      color: primaryBlue,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _solicitudesPendientes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final solicitud = _solicitudesPendientes[index];
          return _buildTarjetaSolicitud(solicitud);
        },
      ),
    );
  }

  Widget _buildTarjetaSolicitud(RentaClienteModel solicitud) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con información de la solicitud
            Row(
              children: [
                // Badge de estado
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.pending_actions,
                          size: 14, color: Colors.orange),
                      const SizedBox(width: 4),
                      Text(
                        'PENDIENTE',
                        style: GoogleFonts.lato(
                          color: Colors.orange,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Text(
                  'Solicitado: ${_formatDate(solicitud.fechaReserva)}',
                  style: GoogleFonts.lato(
                    color: Color(0xFF636E72),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Información del vehículo
            Row(
              children: [
                // Imagen del vehículo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: lightBlue,
                    image: solicitud.imagenVehiculo.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(solicitud.imagenVehiculo),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: solicitud.imagenVehiculo.isEmpty
                      ? Icon(Icons.directions_car, color: primaryBlue, size: 36)
                      : null,
                ),
                const SizedBox(width: 16),

                // Información del vehículo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${solicitud.marca} ${solicitud.modelo}',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2D3436),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Placa: ${solicitud.placa}',
                        style: GoogleFonts.lato(
                          color: Color(0xFF636E72),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${solicitud.anio} • ${solicitud.color}',
                        style: GoogleFonts.lato(
                          color: Color(0xFF636E72),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            Divider(color: Color(0xFFDFE6E9)),
            const SizedBox(height: 12),

            // Información del cliente
            _buildInfoRow(
              icon: Icons.person_outline,
              text: solicitud.nombreCliente,
              onTap: () => _mostrarDetallesCliente(solicitud),
            ),

            const SizedBox(height: 8),

            // Fechas solicitadas
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              text:
                  '${_formatDate(solicitud.fechaInicio)} - ${_formatDate(solicitud.fechaFin)}',
            ),

            const SizedBox(height: 8),

            // Información de contacto
            Row(
              children: [
                Icon(Icons.phone_outlined, size: 16, color: primaryBlue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    solicitud.telefonoCliente.isNotEmpty
                        ? solicitud.telefonoCliente
                        : 'Teléfono no proporcionado',
                    style: GoogleFonts.lato(
                      color: Color(0xFF636E72),
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Total de la renta
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.attach_money_outlined,
                      size: 16, color: primaryGreen),
                ),
                const SizedBox(width: 8),
                Text(
                  'Total: \$${solicitud.total.toStringAsFixed(2)}',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w700,
                    color: primaryGreen,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Text(
                  '${_calcularDias(solicitud.fechaInicio, solicitud.fechaFin)} días',
                  style: GoogleFonts.lato(
                    color: Color(0xFFB2BEC3),
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            // Botones de acción
            const SizedBox(height: 16),
            Divider(color: Color(0xFFDFE6E9)),
            const SizedBox(height: 16),
            Row(
              children: [
                _buildQRActionButton(solicitud), // ← Nuevo botón QR
                SizedBox(width: 12),
                Expanded(
                  child: _buildCustomButton(
                    text: 'Rechazar',
                    onPressed: () => _showConfirmCancelDialog(solicitud),
                    backgroundColor: Colors.white,
                    textColor: Colors.red,
                    borderColor: Colors.red,
                    icon: Icons.cancel_outlined,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCustomButton(
                    text: 'Confirmar',
                    onPressed: () => _confirmarSolicitud(solicitud.rentaId),
                    backgroundColor: primaryGreen,
                    textColor: Colors.white,
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Icon(icon, size: 18, color: primaryBlue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: GoogleFonts.lato(
                  color: onTap != null ? primaryBlue : Color(0xFF2D3436),
                  fontSize: 14,
                  fontWeight:
                      onTap != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            if (onTap != null)
              Icon(Icons.chevron_right, size: 18, color: primaryBlue),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButton({
    required String text,
    required VoidCallback onPressed,
    Color? backgroundColor,
    Color? textColor,
    Color? borderColor,
    IconData? icon,
    double height = 48.0,
  }) {
    return SizedBox(
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: borderColor != null
                ? BorderSide(color: borderColor, width: 1.5)
                : BorderSide.none,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 6),
            ],
            Text(
              text,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _mostrarDetallesCliente(RentaClienteModel solicitud) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildDetallesCliente(solicitud),
    );
  }

  Widget _buildDetallesCliente(RentaClienteModel solicitud) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFFDFE6E9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Información del Cliente', Icons.person_outline),
          const SizedBox(height: 16),
          _buildDetailItem('Nombre', solicitud.nombreCliente),
          _buildDetailItem('Email', solicitud.emailCliente),
          _buildDetailItem(
              'Teléfono',
              solicitud.telefonoCliente.isNotEmpty
                  ? solicitud.telefonoCliente
                  : 'No proporcionado'),
          _buildDetailItem(
              'DUI',
              solicitud.duiCliente.isNotEmpty
                  ? solicitud.duiCliente
                  : 'No proporcionado'),
          const SizedBox(height: 24),
          _buildSectionTitle(
              'Detalles de la Solicitud', Icons.car_rental_outlined),
          const SizedBox(height: 16),
          _buildDetailItem(
              'Vehículo', '${solicitud.marca} ${solicitud.modelo}'),
          _buildDetailItem('Placa', solicitud.placa),
          _buildDetailItem(
              'Fecha Solicitud', _formatDateTime(solicitud.fechaReserva)),
          _buildDetailItem('Periodo Solicitado',
              '${_formatDate(solicitud.fechaInicio)} - ${_formatDate(solicitud.fechaFin)}'),
          _buildDetailItem('Días Solicitados',
              '${_calcularDias(solicitud.fechaInicio, solicitud.fechaFin)} días'),
          _buildDetailItem('Total', '\$${solicitud.total.toStringAsFixed(2)}'),
          _buildDetailItem('Estado', 'Pendiente de confirmación'),
          const SizedBox(height: 32),
          _buildCustomButton(
            text: 'Cerrar Detalles',
            onPressed: () => Navigator.pop(context),
            backgroundColor: Color(0xFFF8F9FA),
            textColor: Color(0xFF636E72),
            borderColor: Color(0xFFDFE6E9),
            icon: Icons.close,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: primaryBlue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: primaryBlue, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF2D3436),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: GoogleFonts.lato(
                fontWeight: FontWeight.w600,
                color: Color(0xFF636E72),
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: GoogleFonts.lato(
                color: Color(0xFF2D3436),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showConfirmCancelDialog(RentaClienteModel solicitud) {
    showGlobalStatusModalAction(
      context,
      title: 'Rechazar Solicitud',
      message: '¿Estás seguro de que deseas rechazar la solicitud de ${solicitud.nombreCliente} para el ${solicitud.marca} ${solicitud.modelo}?',
      icon: Icons.warning_amber,
      iconColor: Colors.red,
      confirmText: 'Rechazar',
      cancelText: 'Cancelar',
      onConfirm: () {
        _cancelarSolicitud(solicitud.rentaId);
      },
      onCancel: () {
        // No se necesita hacer nada, el modal se cierra automáticamente
      },
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  int _calcularDias(DateTime inicio, DateTime fin) {
    return fin.difference(inicio).inDays;
  }
}