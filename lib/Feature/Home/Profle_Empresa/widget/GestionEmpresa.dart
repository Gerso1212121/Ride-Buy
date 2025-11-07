import 'dart:ui';

import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class GestionEmpresa extends StatelessWidget {
  final String representante;
  final String cargoRepresentante;
  final String usuarioEmail;
  final VoidCallback? onPerfilEmpresa;
  final VoidCallback? onRepresentante;
  final VoidCallback? onUsuario;

  const GestionEmpresa({
    super.key,
    required this.representante,
    required this.cargoRepresentante,
    required this.usuarioEmail,
    this.onPerfilEmpresa,
    this.onRepresentante,
    this.onUsuario,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Text(
          'Gestión de Empresa',
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
        Container(
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
                _buildItemGestion(
                  context: context,
                  icono: Icons.business_rounded,
                  titulo: 'Perfil de Empresa',
                  subtitulo: 'Información y configuración',
                  onTap: onPerfilEmpresa,
                ),
                Divider(
                  thickness: 1,
                  color: Color(0xFFE0E3E7),
                ),
                _buildItemGestion(
                  context: context,
                  icono: Icons.person_rounded,
                  titulo: 'Representante Legal',
                  subtitulo: '$representante - $cargoRepresentante',
                  onTap: onRepresentante,
                ),
                Divider(
                  thickness: 1,
                  color: Color(0xFFE0E3E7),
                ),
                _buildItemGestion(
                  context: context,
                  icono: Icons.account_circle_rounded,
                  titulo: 'Usuario en la App',
                  subtitulo: usuarioEmail,
                  onTap: onUsuario,
                ),
              ],
            ),
          ),
        ),
      ].divide(SizedBox(height: 12)),
    );
  }

  Widget _buildItemGestion({
    required BuildContext context,
    required IconData icono,
    required String titulo,
    required String subtitulo,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              icono,
              color: Color(0xFF2797FF),
              size: 24,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                            ),
                            color: Color(0xFF161C24),
                            fontSize: 16,
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
                            color: Color(0xFF636F81),
                            fontSize: 12,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF636F81),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}