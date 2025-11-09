import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilHeader extends StatelessWidget {
  final String nombreEmpresa;
  final String descripcion;
  final String imagenUrl;
  final String ubicacion;
  final String? ncr; // Agregué el NCR como parámetro opcional

  const PerfilHeader({
    super.key,
    required this.nombreEmpresa,
    required this.descripcion,
    required this.imagenUrl,
    required this.ubicacion,
    this.ncr, // NCR opcional
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Color(0xFFF1F5F9),
          width: 1,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagen más grande y centrada
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(20),
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: Image.network(
                    imagenUrl,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildPlaceholderIcon(),
                  ).image,
                ),
                border: Border.all(
                  color: Color(0xFFE0E7FF),
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x1A2563EB),
                    blurRadius: 15,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 20),
            
            // Información de la empresa centrada
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  nombreEmpresa,
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                        ),
                        color: Color(0xFF1E293B),
                        fontSize: 24,
                        letterSpacing: 0.0,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 8),
                
                Text(
                  descripcion,
                  style: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.manrope(
                          fontWeight: FontWeight.w500,
                        ),
                        color: Color(0xFF64748B),
                        fontSize: 16,
                        letterSpacing: 0.0,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                // Mostrar NCR si está disponible
                if (ncr != null && ncr!.isNotEmpty) ...[
                  SizedBox(height: 6),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Color(0xFFF0F9FF),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Color(0xFFBAE6FD),
                      ),
                    ),
                    child: Text(
                      'NCR: $ncr',
                      style: FlutterFlowTheme.of(context).bodySmall.override(
                            font: GoogleFonts.manrope(
                              fontWeight: FontWeight.w600,
                            ),
                            color: Color(0xFF0C4A6E),
                            fontSize: 12,
                            letterSpacing: 0.0,
                          ),
                    ),
                  ),
                ],
              ],
            ),
            
            SizedBox(height: 20),
            
            // Ubicación
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Color(0xFFF1F5F9),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(0xFFDBEAFE),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF2563EB),
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ubicación',
                          style: FlutterFlowTheme.of(context).bodySmall.override(
                                font: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w600,
                                ),
                                color: Color(0xFF475569),
                                fontSize: 12,
                                letterSpacing: 0.0,
                              ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          ubicacion,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.manrope(
                                  fontWeight: FontWeight.w500,
                                ),
                                color: Color(0xFF1E293B),
                                fontSize: 14,
                                letterSpacing: 0.0,
                              ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Icon(
          Icons.business_rounded,
          color: Color(0xFF2563EB),
          size: 48,
        ),
      ),
    );
  }
}