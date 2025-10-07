import 'package:flutter/material.dart';

class CustomButtonWithStates extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData? icon;
  final double iconSize;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color iconColor;
  final Color backgroundColor;
  final Color hoverColor;
  final Color splashColor;
  final Color textColor;
  final double elevation;
  final double hoverElevation;
  final double borderRadius;
  final bool expanded;
  final FontWeight fontWeight;
  final TextOverflow textOverflow; // ✅ NUEVO PARÁMETRO

  const CustomButtonWithStates({
    Key? key,
    required this.onPressed,
    required this.text,
    this.icon,
    this.iconSize = 18,
    this.height = 40,
    this.padding = const EdgeInsets.symmetric(horizontal: 12), // ✅ Reducido padding
    this.iconColor = Colors.white,
    this.backgroundColor = Colors.blue,
    this.hoverColor = Colors.blueAccent,
    this.splashColor = const Color.fromARGB(255, 25, 118, 210),
    this.textColor = Colors.white,
    this.elevation = 0,
    this.hoverElevation = 2,
    this.borderRadius = 25,
    this.expanded = true,
    this.fontWeight = FontWeight.w600,
    this.textOverflow = TextOverflow.ellipsis, // ✅ VALOR POR DEFECTO
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    Widget button = MouseRegion(
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        child: ElevatedButton(
          onPressed: onPressed,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.pressed)) {
                  return splashColor;
                } else if (states.contains(MaterialState.hovered)) {
                  return hoverColor;
                }
                return backgroundColor == Colors.blue 
                    ? theme.colorScheme.primary 
                    : backgroundColor;
              },
            ),
            elevation: MaterialStateProperty.resolveWith<double>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return hoverElevation;
                }
                return elevation;
              },
            ),
            padding: MaterialStateProperty.all(padding),
            minimumSize: MaterialStateProperty.all(Size(0, height)),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: iconSize,
                  color: iconColor,
                ),
                const SizedBox(width: 6), // ✅ Espacio reducido
              ],
              Flexible( // ✅ ENVOLVER EL TEXTO EN FLEXIBLE
                child: Text(
                  text,
                  overflow: textOverflow, // ✅ APLICAR OVERFLOW
                  maxLines: 1, // ✅ UNA SOLA LÍNEA
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: fontWeight,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return expanded ? Expanded(child: button) : button;
  }
}