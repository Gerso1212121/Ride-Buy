import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GananciasCard extends StatelessWidget {
  final double gananciasTotales;
  final double gananciasMes;
  final bool tendenciaPositiva;

  const GananciasCard({
    super.key,
    required this.gananciasTotales,
    required this.gananciasMes,
    this.tendenciaPositiva = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color(0xFF1ABC64),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '\$${gananciasTotales.toStringAsFixed(0)}',
                    style: FlutterFlowTheme.of(context).headlineMedium.override(
                          font: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                          ),
                          color: Colors.white,
                          fontSize: 32,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    'Ganancias Totales',
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FontWeight.w500,
                          ),
                          color: Colors.white,
                          fontSize: 14,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    'Este mes: +\$${gananciasMes.toStringAsFixed(0)}',
                    style: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FontWeight.w500,
                          ),
                          color: Color(0xB3FFFFFF),
                          fontSize: 12,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ].divide(SizedBox(height: 4)),
              ),
              Icon(
                tendenciaPositiva 
                    ? Icons.trending_up_rounded 
                    : Icons.trending_down_rounded,
                color: Colors.white,
                size: 32,
              ),
            ],
          ),
        ),
      ),
    );
  }
}