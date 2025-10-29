import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileActionsSection extends StatelessWidget {
  final String sectionTitle;
  final List<ProfileActionItem> actions;
  final bool showDividers;
  final Color? containerBorderColor;
  final double containerBorderWidth;
  final Color? dividerColor;        // ← COLOR DEL DIVIDER
  final double dividerThickness;    // ← GROSOR DEL DIVIDER
  final double dividerIndent;       // ← ESPACIO IZQUIERDO
  final double dividerEndIndent;    // ← ESPACIO DERECHO

  const ProfileActionsSection({
    super.key,
    required this.sectionTitle,
    required this.actions,
    this.showDividers = true,
    this.containerBorderColor,
    this.containerBorderWidth = 1,
    this.dividerColor,              // ← PARÁMETRO OPCIONAL
    this.dividerThickness = 1,      // ← VALOR POR DEFECTO
    this.dividerIndent = 56,        // ← VALOR POR DEFECTO
    this.dividerEndIndent = 16,     // ← VALOR POR DEFECTO
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          sectionTitle,
          style: FlutterFlowTheme.of(context).titleMedium.override(
                font: GoogleFonts.figtree(
                  fontWeight: FontWeight.w600,
                  fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryText,
                letterSpacing: 0.0,
              ),
        ),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: containerBorderColor ?? 
                    FlutterFlowTheme.of(context).alternate,
              width: containerBorderWidth,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: _buildActionItems(context),
            ),
          ),
        ),
      ].divide(const SizedBox(height: 16)),
    );
  }

  List<Widget> _buildActionItems(BuildContext context) {
    final List<Widget> items = [];

    for (int i = 0; i < actions.length; i++) {
      // Agregar el ítem de acción
      items.add(
        _buildActionItem(context, actions[i]),
      );

      // Agregar divisor si no es el último ítem y showDividers es true
      if (showDividers && i < actions.length - 1) {
        items.add(
          Divider(
            thickness: dividerThickness,        // ← USA EL PARÁMETRO
            indent: dividerIndent,              // ← USA EL PARÁMETRO
            endIndent: dividerEndIndent,        // ← USA EL PARÁMETRO
            color: dividerColor ??              // ← USA EL PARÁMETRO
                   FlutterFlowTheme.of(context).alternate,
          ),
        );
      }
    }

    return items;
  }

  Widget _buildActionItem(BuildContext context, ProfileActionItem action) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Icon(
                    action.icon,
                    color: action.iconColor,
                    size: 24,
                  ),
                  Text(
                    action.title,
                    style: FlutterFlowTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.figtree(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .fontStyle,
                          ),
                          color: action.textColor ?? 
                                FlutterFlowTheme.of(context).primaryText,
                          letterSpacing: 0.0,
                        ),
                  ),
                ].divide(const SizedBox(width: 16)),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 20,
            ),
          ].divide(const SizedBox(width: 16)),
        ),
      ),
    );
  }
}

//CLASE
class ProfileActionItem {
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color? textColor;
  final VoidCallback onTap;

  ProfileActionItem({
    required this.title,
    required this.icon,
    required this.iconColor,
    this.textColor,
    required this.onTap,
  });
}