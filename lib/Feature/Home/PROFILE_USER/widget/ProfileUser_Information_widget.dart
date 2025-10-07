import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class PersonalInfoSection extends StatelessWidget {
  const PersonalInfoSection({
    Key? key,
    required this.personalInfoItems,
    this.title = 'Información Personal',
    this.titleStyle,
    this.backgroundColor,
    this.borderColor,  // ← CAMBIADO A OPCIONAL
    this.borderRadius = 12,
    this.borderWidth = 1,
    this.iconColor,
    this.labelStyle,
    this.valueStyle,
    this.spacing = 16,
    this.itemSpacing = 16,
    this.dividerColor, // ← CAMBIADO A OPCIONAL
    this.dividerThickness = 1,
    this.dividerIndent = 56,
    this.dividerEndIndent = 16,
    this.padding = const EdgeInsets.all(16),
    this.itemPadding = const EdgeInsets.all(16),
  }) : super(key: key);

  final List<PersonalInfoItem> personalInfoItems;
  final String title;
  final TextStyle? titleStyle;
  final Color? backgroundColor;
  final Color? borderColor;      // ← AHORA ES OPCIONAL
  final double borderRadius;
  final double borderWidth;
  final Color? iconColor;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final double spacing;
  final double itemSpacing;
  final Color? dividerColor;     // ← AHORA ES OPCIONAL
  final double dividerThickness;
  final double dividerIndent;
  final double dividerEndIndent;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry itemPadding;

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título
        Text(
          title,
          style: titleStyle ?? theme.titleMedium?.copyWith(
            fontFamily: 'Figtree',
            fontWeight: FontWeight.w600,
            color: theme.primaryText,
            letterSpacing: 0.0,
          ),
        ),

        // Contenedor de información
        Container(
          decoration: BoxDecoration(
            color: backgroundColor ?? theme.secondaryBackground,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? theme.alternate,  // ← USA EL PARÁMETRO OPCIONAL
              width: borderWidth,
            ),
          ),
          child: Padding(
            padding: padding,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: _buildInfoItems(context),
            ),
          ),
        ),
      ].divide(SizedBox(height: spacing)),
    );
  }

  List<Widget> _buildInfoItems(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final List<Widget> items = [];

    for (int i = 0; i < personalInfoItems.length; i++) {
      // Agregar el ítem
      items.add(
        Padding(
          padding: itemPadding,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Ícono
              Icon(
                personalInfoItems[i].icon,
                color: iconColor ?? theme.primary,
                size: 24,
              ),

              // Espacio
              SizedBox(width: itemSpacing),

              // Información
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Etiqueta
                    Text(
                      personalInfoItems[i].label,
                      style: labelStyle ?? theme.labelMedium?.copyWith(
                        fontFamily: 'Figtree',
                        color: theme.secondaryText,
                        fontSize: 12,
                        letterSpacing: 0.0,
                        fontWeight: theme.labelMedium?.fontWeight,
                        fontStyle: theme.labelMedium?.fontStyle,
                      ),
                    ),

                    // Valor
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                      child: Text(
                        personalInfoItems[i].value,
                        style: valueStyle ?? theme.bodyMedium?.copyWith(
                          fontFamily: 'Figtree',
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.0,
                          fontStyle: theme.bodyMedium?.fontStyle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

      // Agregar divisor si no es el último ítem
      if (i < personalInfoItems.length - 1) {
        items.add(
          Divider(
            thickness: dividerThickness,
            indent: dividerIndent,
            endIndent: dividerEndIndent,
            color: dividerColor ?? theme.alternate,  // ← USA EL PARÁMETRO OPCIONAL
          ),
        );
      }
    }

    return items;
  }
}

class PersonalInfoItem {
  const PersonalInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}