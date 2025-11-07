import 'dart:ui';

import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EstadisticasRapidas extends StatelessWidget {
  final int totalVehiculos;
  final double porcentajeOcupacion;

  const EstadisticasRapidas({
    super.key,
    required this.totalVehiculos,
    required this.porcentajeOcupacion,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'Estadísticas Rápidas',
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                ),
                color: Colors.black,
                fontSize: 16,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w600,
              ),
        ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              _buildTarjetaEstadistica(
                context: context,
                valor: totalVehiculos.toString(),
                titulo: 'Total Vehículos',
                colorFondo: Color(0xFFFFF3E0),
                colorTexto: Color(0xFFFFB74D),
                colorTitulo: Color(0xFFFF8F00),
              ),
              _buildTarjetaEstadistica(
                context: context,
                valor: '${porcentajeOcupacion.toStringAsFixed(0)}%',
                titulo: 'Ocupación',
                colorFondo: Color(0xFFE8F5E8),
                colorTexto: Color(0xFF66BB6A),
                colorTitulo: Color(0xFF388E3C),
              ),
            ].divide(SizedBox(width: 12)),
          ),
        ),
      ].divide(SizedBox(height: 12)),
    );
  }

  Widget _buildTarjetaEstadistica({
    required BuildContext context,
    required String valor,
    required String titulo,
    required Color colorFondo,
    required Color colorTexto,
    required Color colorTitulo,
  }) {
    return Expanded(
      child: Container(
        width: 100,
        decoration: BoxDecoration(
          color: colorFondo,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Text(
                valor,
                style: FlutterFlowTheme.of(context).headlineSmall.override(
                      font: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                      ),
                      color: colorTexto,
                      fontSize: 24,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                titulo,
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.manrope(
                        fontWeight: FontWeight.w500,
                      ),
                      color: colorTitulo,
                      fontSize: 12,
                      letterSpacing: 0.0,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ].divide(SizedBox(height: 4)),
          ),
        ),
      ),
    );
  }
}