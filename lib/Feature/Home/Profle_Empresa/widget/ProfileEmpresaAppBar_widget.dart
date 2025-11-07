import 'package:ezride/flutter_flow/flutter_flow_icon_button.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmpresaAppBar extends StatelessWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize = Size.fromHeight(kToolbarHeight);

  EmpresaAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFF0F5F9),
      automaticallyImplyLeading: false,
      title: Text(
        'Panel Empresarial',
        style: FlutterFlowTheme.of(context).headlineMedium.override(
              font: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
              ),
              color: Color(0xFF161C24),
              fontSize: 32,
              letterSpacing: 0.0,
              fontWeight: FontWeight.bold,
            ),
      ),
      actions: [
        Padding(
          padding: EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              FlutterFlowIconButton(
                borderRadius: 12,
                buttonSize: 40,
                fillColor: Color(0x4C2797FF),
                icon: Icon(
                  Icons.notifications_rounded,
                  color: Color(0xFF2797FF),
                  size: 20,
                ),
                onPressed: () {
                  print('IconButton pressed ...');
                },
              ),
              FlutterFlowIconButton(
                borderRadius: 12,
                buttonSize: 40,
                fillColor: Color(0x4C2797FF),
                icon: Icon(
                  Icons.settings_rounded,
                  color: Color(0xFF2797FF),
                  size: 20,
                ),
                onPressed: () {
                  print('IconButton pressed ...');
                },
              ),
            ].divide(SizedBox(width: 8)),
          ),
        ),
      ],
      centerTitle: false,
      elevation: 0,
    );
  }
}