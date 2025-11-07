import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BotonCerrarSesion extends StatelessWidget {
  final VoidCallback? onCerrarSesion;

  const BotonCerrarSesion({
    super.key,
    this.onCerrarSesion,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(20, 0, 20, 0),
      child: FFButtonWidget(
        onPressed: onCerrarSesion,
        text: 'Cerrar Sesión',
        options: FFButtonOptions(
          width: double.infinity,
          height: 50,
          padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          iconPadding: EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
          color: Color(0xFFFFEBEE),
          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.manrope(
                  fontWeight: FontWeight.w500,
                ),
                color: Color(0xFFEE4444),
                fontSize: 14,
                letterSpacing: 0.0,
                fontWeight: FontWeight.w500,
              ),
          elevation: 0,
          borderSide: BorderSide(
            color: Color(0xFFEE4444),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}