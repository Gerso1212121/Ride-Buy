import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';

Future<void> showGlobalStatusModal(
  BuildContext context, {
  required String title,
  String? message,
  IconData? icon,
  bool isLoading = false,
  Color? iconColor,
  Duration? autoCloseDuration,
}) {
  // 👇 return para devolver el Future
  return showDialog(
    context: context,
    barrierDismissible: !isLoading,
    builder: (ctx) {
      if (autoCloseDuration != null) {
        Future.delayed(autoCloseDuration, () {
          if (ctx.mounted && Navigator.canPop(ctx)) Navigator.pop(ctx);
        });
      }

      return Center(
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            width: MediaQuery.of(context).size.width * 0.85,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: FlutterFlowTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
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
                      size: 50,
                    ),
                  ),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.lato(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: FlutterFlowTheme.of(context).primaryText,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    message!,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      color: FlutterFlowTheme.of(context).secondaryText,
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                if (!isLoading)
                  ElevatedButton(
                    onPressed: () {
                      if (ctx.mounted && Navigator.canPop(ctx)) {
                        Navigator.pop(ctx);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: FlutterFlowTheme.of(context).primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      minimumSize: const Size(double.infinity, 45),
                    ),
                    child: const Text(
                      'Cerrar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
