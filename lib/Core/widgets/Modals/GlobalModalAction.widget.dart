import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showGlobalStatusModalAction(
  BuildContext context, {
  required String title,
  String? message,
  IconData? icon,
  bool isLoading = false,
  Color? iconColor,
  Duration? autoCloseDuration,

  // ✅ Nuevo: callbacks para los botones
  VoidCallback? onConfirm,
  VoidCallback? onCancel,

  // ✅ Nuevo: texto personalizable para el botón principal
  String confirmText = "Aceptar",
  String cancelText = "Cancelar",
}) {
  return showDialog(
    context: context,
    barrierDismissible: !isLoading,
    barrierColor: Colors.black54,
    builder: (ctx) {
      // autocerrar si se especifica duración
      if (autoCloseDuration != null) {
        Future.delayed(autoCloseDuration, () {
          if (ctx.mounted && Navigator.canPop(ctx)) Navigator.pop(ctx);
        });
      }

      return Center(
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width * 0.85,
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Loading or Icon
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: CircularProgressIndicator(
                      color: FlutterFlowTheme.of(context).primary,
                      strokeWidth: 4,
                    ),
                  )
                else if (icon != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Icon(
                      icon,
                      color: iconColor ?? FlutterFlowTheme.of(context).primary,
                      size: 52,
                    ),
                  ),

                // Title
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),

                // Message
                if (message != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ✅ Buttons logic
                if (!isLoading)
                  Column(
                    children: [
                      // Confirm Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          onConfirm?.call();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: FlutterFlowTheme.of(context).primary,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          confirmText,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Cancel Button (only if provided)
                      if (onCancel != null)
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            onCancel.call();
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            side: BorderSide(
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                          child: Text(
                            cancelText,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: FlutterFlowTheme.of(context).primary,
                            ),
                          ),
                        ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
