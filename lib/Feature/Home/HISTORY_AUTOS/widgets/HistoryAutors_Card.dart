import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VehiculoCard extends StatelessWidget {
  final String imageUrl;
  final String marcaModelo;
  final String descripcion;
  final String estado;
  final Color colorEstado;
  final String fechaInicio;
  final String fechaFin;
  final String? diasRenta;
  final String tipoCard;
  final VoidCallback? onVerDetalles;
  final VoidCallback? onSoporte;
  final VoidCallback? onVerificar;
  final VoidCallback? onPagar;
  final VoidCallback? onCancelar;
  final VoidCallback? onRepetir;
  final VoidCallback? onResena;

  const VehiculoCard({
    super.key,
    required this.imageUrl,
    required this.marcaModelo,
    required this.descripcion,
    required this.estado,
    required this.colorEstado,
    required this.fechaInicio,
    required this.fechaFin,
    this.diasRenta,
    required this.tipoCard,
    this.onVerDetalles,
    this.onSoporte,
    this.onVerificar,
    this.onPagar,
    this.onCancelar,
    this.onRepetir,
    this.onResena,
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, isSmallScreen),
              const SizedBox(height: 12),
              const Divider(color: Colors.grey, height: 1),
              const SizedBox(height: 12),
              _buildFechasInfo(context),
              const SizedBox(height: 12),
              _buildBotones(context, isSmallScreen),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isSmallScreen) {
    final theme = FlutterFlowTheme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Imagen
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            imageUrl,
            width: isSmallScreen ? 70 : 90,
            height: isSmallScreen ? 55 : 65,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),

        // Información
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                marcaModelo,
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w700,
                  fontSize: isSmallScreen ? 15 : 17,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                descripcion,
                style: GoogleFonts.figtree(
                  fontSize: isSmallScreen ? 13 : 14,
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: colorEstado.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: colorEstado, width: 1),
                ),
                child: Text(
                  estado,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.figtree(
                    fontWeight: FontWeight.w600,
                    color: colorEstado,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFechasInfo(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildColumnaFecha(
          context,
          label: tipoCard == 'solicitud' ? 'Recogida' : 'Inicio',
          valor: fechaInicio,
          colorValor: theme.primaryText,
          isSmall: isSmallScreen,
        ),
        _buildColumnaFecha(
          context,
          label: tipoCard == 'solicitud' ? 'Días de renta' : 'Devolución',
          valor: tipoCard == 'solicitud' ? (diasRenta ?? '') : fechaFin,
          colorValor:
              estado == 'Retrasada' ? Colors.red.shade700 : theme.primaryText,
          isSmall: isSmallScreen,
        ),
      ],
    );
  }

  Widget _buildColumnaFecha(
    BuildContext context, {
    required String label,
    required String valor,
    required Color colorValor,
    required bool isSmall,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.figtree(
            color: FlutterFlowTheme.of(context).secondaryText,
            fontSize: isSmall ? 12 : 13,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          valor,
          style: GoogleFonts.figtree(
            color: colorValor,
            fontWeight: FontWeight.w600,
            fontSize: isSmall ? 13 : 14,
          ),
        ),
      ],
    );
  }

Widget _buildBotones(BuildContext context, bool isSmallScreen) {
  double heightBtn = isSmallScreen ? 34 : 38;
  double fontSize = isSmallScreen ? 13 : 14;

  switch (tipoCard) {
    case 'activa':
      return _botonRow([
        _crearBoton(
          text: 'Ver Detalles',
          onPressed: onVerDetalles,
          color: Colors.white,
          textColor: Colors.blue.shade700,
          borderColor: Colors.blue.shade700,
          height: heightBtn,
          fontSize: fontSize,
        ),
      ]);

    case 'solicitud':
      return _botonRow([
        _crearBoton(
          text: 'Verificar código',
          onPressed: onVerificar,
          color: Color.fromARGB(255, 60, 135, 255), // Fondo bonito y vibrante
          textColor: Colors.white,        // Texto blanco
          height: heightBtn,
          fontSize: fontSize,
        ),
      ]);

    case 'historial':
      return _botonRow([
        _crearBoton(
          text: 'Repetir Renta',
          onPressed: onRepetir,
          color: Color.fromARGB(255, 57, 146, 255),
          textColor: Colors.white,
          height: heightBtn,
          fontSize: fontSize,
        ),
        _crearBoton(
          text: 'Dejar Reseña',
          onPressed: onResena,
          color: Color.fromARGB(255, 255, 255, 255),
          textColor: Color.fromARGB(255, 31, 91, 255),
          borderColor: Color.fromARGB(255, 14, 46, 255),
          height: heightBtn,
          fontSize: fontSize,
        ),
      ]);

    default:
      return const SizedBox.shrink();
  }
}

Widget _crearBoton({
  required String text,
  required VoidCallback? onPressed,
  required Color color,
  required Color textColor,
  Color? borderColor,
  required double height,
  required double fontSize,
}) {
  return FFButtonWidget(
    onPressed: onPressed,
    text: text,
    options: FFButtonOptions(
      height: height,
      color: color,
      textStyle: GoogleFonts.figtree(
        color: textColor,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
      ),
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(
        color: borderColor ?? Colors.transparent,
        width: 1.2,
      ),
      elevation: 2, // Sombra ligera
    ),
  );
}


  Widget _botonRow(List<Widget> botones) => Row(
        children: botones
            .expand((b) => [Expanded(child: b), const SizedBox(width: 8)])
            .toList()
          ..removeLast(),
      );


}
