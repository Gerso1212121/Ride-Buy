import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final double elevation;
  final double width;
  final double height;
  final Widget? icon;
  final bool isSocial;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.elevation = 3.0,
    this.width = 230.0,
    this.height = 52.0,
    this.icon,
    this.isSocial = false,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
        child: FFButtonWidget(
          onPressed: onPressed,
          text: text,
          icon: icon,
          options: FFButtonOptions(
            width: width,
            height: height,
            padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            iconPadding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
            color: backgroundColor ?? FlutterFlowTheme.of(context).primary,
            textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                  font: GoogleFonts.lato(
                    fontWeight:
                        FlutterFlowTheme.of(context).titleSmall.fontWeight,
                    fontStyle:
                        FlutterFlowTheme.of(context).titleSmall.fontStyle,
                  ),
                  color: textColor ?? Colors.white,
                  letterSpacing: 0.0,
                  fontWeight: isSocial ? FontWeight.bold : null,
                ),
            elevation: elevation,
            borderSide: BorderSide(
              color: borderColor ?? Colors.transparent,
              width: isSocial ? 2.0 : 1.0,
            ),
            borderRadius: BorderRadius.circular(40.0),
            hoverColor: FlutterFlowTheme.of(context).primaryBackground,
          ),
        ),
      ),
    );
  }
}
