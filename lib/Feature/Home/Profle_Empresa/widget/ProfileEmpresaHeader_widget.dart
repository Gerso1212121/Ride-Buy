import 'package:ezride/flutter_flow/flutter_flow_icon_button.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilHeader extends StatelessWidget {
  final String nombreEmpresa;
  final String descripcion;
  final String imagenUrl;
  final double calificacion;
  final int totalResenas;
  final String ubicacion;

  const PerfilHeader({
    super.key,
    required this.nombreEmpresa,
    required this.descripcion,
    required this.imagenUrl,
    required this.calificacion,
    required this.totalResenas,
    required this.ubicacion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
        border: Border.all(
          color: Color(0xFFE0E3E7),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      width: 80,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0x4C2797FF),
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: Image.network(imagenUrl).image,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombreEmpresa,
                          style: FlutterFlowTheme.of(context).titleLarge.override(
                                font: GoogleFonts.outfit(
                                  fontWeight: FontWeight.bold,
                                ),
                                color: Color(0xFF161C24),
                                fontSize: 22,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          descripcion,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w500,
                                ),
                                color: Color(0xFF636F81),
                                fontSize: 14,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w500,
                              ),
                        ),
                        _buildCalificacion(calificacion, totalResenas, context),
                      ].divide(SizedBox(height: 4)),
                    ),
                  ].divide(SizedBox(width: 12)),
                ),
                FlutterFlowIconButton(
                  borderRadius: 12,
                  buttonSize: 40,
                  fillColor: Color(0x4C2797FF),
                  icon: Icon(
                    Icons.edit,
                    color: Color(0xFF2797FF),
                    size: 20,
                  ),
                  onPressed: () {
                    print('IconButton pressed ...');
                  },
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Icon(
                  Icons.location_on,
                  color: Color(0xFF2797FF),
                  size: 16,
                ),
                Expanded(
                  child: Text(
                    ubicacion,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.manrope(
                            fontWeight: FontWeight.w500,
                          ),
                          color: Color(0xFF636F81),
                          fontSize: 14,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
              ].divide(SizedBox(width: 8)),
            ),
          ].divide(SizedBox(height: 12)),
        ),
      ),
    );
  }

  Widget _buildCalificacion(double calificacion, int totalResenas, BuildContext context) {
    final estrellasLlenas = calificacion.floor();
    final tieneMediaEstrella = (calificacion - estrellasLlenas) >= 0.5;
    
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        for (int i = 0; i < 5; i++)
          Icon(
            Icons.star_rounded,
            color: i < estrellasLlenas 
                ? Color(0xFFFC964D) 
                : (i == estrellasLlenas && tieneMediaEstrella 
                    ? Color(0xFFFC964D) 
                    : Color(0xFFE0E3E7)),
            size: 16,
          ),
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(4, 0, 4, 0),
          child: Text(
            '${calificacion.toStringAsFixed(1)} ($totalResenas reseñas)',
            style: FlutterFlowTheme.of(context).bodySmall.override(
                  font: GoogleFonts.manrope(
                    fontWeight: FontWeight.w500,
                  ),
                  color: Color(0xFF636F81),
                  fontSize: 12,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w500,
                ),
          ),
        ),
      ].divide(SizedBox(width: 4)),
    );
  }
}