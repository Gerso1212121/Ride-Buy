import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AccionesGrid extends StatelessWidget {
  final int solicitudesPendientes;
  final int carrosRentados;
  final int carrosDisponibles;
  final VoidCallback? onAgregarCarro;
  final VoidCallback? onVerSolicitudes;
  final VoidCallback? onVerRentados;
  final VoidCallback? onVerInventario;

  const AccionesGrid({
    super.key,
    required this.solicitudesPendientes,
    required this.carrosRentados,
    required this.carrosDisponibles,
    this.onAgregarCarro,
    this.onVerSolicitudes,
    this.onVerRentados,
    this.onVerInventario,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(14),
      child: GridView(
        padding: EdgeInsets.zero,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.7,
        ),
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        children: [
          _buildTarjetaAccion(
            context: context,
            icono: Icons.assignment_rounded,
            titulo: 'Solicitudes',
            subtitulo: '$solicitudesPendientes pendientes',
            colorIcono: Color(0xFF2797FF),
            colorSubtitulo: Color(0xFFEE4444),
            onTap: onVerSolicitudes,
          ),
          _buildTarjetaAccion(
            context: context,
            icono: Icons.directions_car_rounded,
            titulo: 'Carros Rentados',
            subtitulo: '$carrosRentados activos',
            colorIcono: Color(0xFF27AE52),
            colorSubtitulo: Color(0xFF27AE52),
            onTap: onVerRentados,
          ),
          _buildTarjetaAccion(
            context: context,
            icono: Icons.garage_rounded,
            titulo: 'En Inventario',
            subtitulo: '$carrosDisponibles disponibles',
            colorIcono: Color(0xFFFC964D),
            colorSubtitulo: Color(0xFFFC964D),
            onTap: onVerInventario,
          ),
          _buildTarjetaAccionAgregar(
            context: context,
            onTap: onAgregarCarro,
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaAccion({
    required BuildContext context,
    required IconData icono,
    required String titulo,
    required String subtitulo,
    required Color colorIcono,
    required Color colorSubtitulo,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFFE0E3E7),
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icono,
                color: colorIcono,
                size: 28,
              ),
              Text(
                titulo,
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                      ),
                      color: Color(0xFF161C24),
                      fontSize: 14,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subtitulo,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.manrope(
                        fontWeight: FontWeight.w500,
                      ),
                      color: colorSubtitulo,
                      fontSize: 12,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ].divide(SizedBox(height: 8)),
          ),
        ),
      ),
    );
  }

  Widget _buildTarjetaAccionAgregar({
    required BuildContext context,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Color(0x4C2797FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Color(0xFF2797FF),
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_rounded,
                color: Color(0xFF2797FF),
                size: 28,
              ),
              Text(
                'Agregar Carro',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                      ),
                      color: Color(0xFF2797FF),
                      fontSize: 14,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'Nuevo vehículo',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.manrope(
                        fontWeight: FontWeight.w500,
                      ),
                      color: Color(0xFF2797FF),
                      fontSize: 12,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ].divide(SizedBox(height: 8)),
          ),
        ),
      ),
    );
  }
}