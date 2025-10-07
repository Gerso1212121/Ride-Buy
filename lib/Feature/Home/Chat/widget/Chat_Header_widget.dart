import 'package:ezride/flutter_flow/flutter_flow_icon_button.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ChatHeaderCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final Color backgroundColor;
  final Color titleColor;
  final Color subtitleColor;
  final double borderRadius;
  final double height;
  final EdgeInsetsGeometry padding;
  final double imageSize;
  final VoidCallback? onMorePressed;
  final VoidCallback? onBackPressed;
  final bool showMoreButton;
  final bool showBackButton;

  const ChatHeaderCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    this.backgroundColor = const Color.fromARGB(255, 70, 107, 229),
    this.titleColor = Colors.white,
    this.subtitleColor = const Color(0xFFE0E7FF),
    this.borderRadius = 20,
    this.height = 100,
    this.padding = const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 12),
    this.imageSize = 40,
    this.onMorePressed,
    this.onBackPressed,
    this.showMoreButton = true,
    this.showBackButton = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Fila superior: Botón de retroceso (si está activado)
            if (showBackButton)
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  FlutterFlowIconButton(
                    borderRadius: 18,
                    buttonSize: 36,
                    fillColor: Colors.white.withOpacity(0.2),
                    icon: Icon(
                      Icons.arrow_back_rounded,
                      color: titleColor,
                      size: 20,
                    ),
                    onPressed: onBackPressed ?? () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),

            // Espacio flexible para empujar el contenido hacia abajo
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end, // Alinea al fondo
                children: [
                  // Información del chat (avatar + texto)
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Avatar del chat
                      Container(
                        width: imageSize,
                        height: imageSize,
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade300,
                              child: Icon(
                                Icons.person,
                                color: Colors.grey.shade600,
                                size: imageSize * 0.6,
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Información de texto
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .fontStyle,
                                  ),
                                  color: titleColor,
                                  fontSize: 16,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            subtitle,
                            style: FlutterFlowTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodySmall
                                        .fontStyle,
                                  ),
                                  color: subtitleColor,
                                  fontSize: 12,
                                  letterSpacing: 0.0,
                                ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Botones de acción (más opciones) - en la parte inferior derecha
                  if (showMoreButton)
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FlutterFlowIconButton(
                          borderRadius: 18,
                          buttonSize: 36,
                          fillColor: Colors.white.withOpacity(0.2),
                          icon: Icon(
                            Icons.more_vert,
                            color: titleColor,
                            size: 20,
                          ),
                          onPressed: onMorePressed ?? () {
                            print('IconButton pressed ...');
                          },
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}