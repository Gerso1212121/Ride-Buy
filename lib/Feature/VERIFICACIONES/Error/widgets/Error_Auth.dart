import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';

class PantallaErrorVerificacionWidget extends StatelessWidget {
  final VoidCallback onReintentarPressed;
  final String title;
  final String description;
  final String reintentarText;

  const PantallaErrorVerificacionWidget({
    super.key,
    required this.onReintentarPressed,
    this.title = 'No pudimos validar tu identidad',
    this.description =
        'Ocurrió un problema validando tu documentación.\nPor favor intenta nuevamente.',
    this.reintentarText = 'Reintentar',
  });

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: theme.secondaryBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ❌ Icono
              Container(
                height: 120,
                width: 120,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.error_rounded,
                  color: Colors.red,
                  size: 65,
                ),
              ),

              const SizedBox(height: 24),

              // 📝 Título
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: theme.primaryText,
                ),
              ),
              const SizedBox(height: 8),

              // 📄 Texto
              Text(
                description,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 15,
                  color: theme.secondaryText,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 36),

              // 🔁 Botón Único: Reintentar
              FFButtonWidget(
                onPressed: onReintentarPressed,
                text: reintentarText,
                icon: const Icon(Icons.restart_alt_rounded, size: 20),
                options: FFButtonOptions(
                  width: double.infinity,
                  height: 56,
                  color: theme.primary,
                  textStyle: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                  elevation: 3,
                  borderRadius: BorderRadius.circular(14),
                ),
              ),

              const SizedBox(height: 36),

              // Texto pequeño
              Text(
                'Puedes volver a intentar en cualquier momento.',
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: theme.secondaryText,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
