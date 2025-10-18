import 'package:flutter/material.dart';

class SecondaryButtonPaycWidgets extends StatelessWidget {
  const SecondaryButtonPaycWidgets({
    Key? key,
    required this.onPressed,
    required this.text,
    this.width = double.infinity,
    this.height = 52,
    this.padding = const EdgeInsets.symmetric(horizontal: 24),
    this.icon,
    this.iconPadding = EdgeInsets.zero,
    this.iconSize = 20,
    this.iconColor = const Color(0xFF6B7280),
    this.backgroundColor = const Color(0xFFF9FAFB),
    this.textColor = const Color(0xFF6B7280),
    this.textSize = 16,
    this.textFontWeight = FontWeight.w500,
    this.elevation = 0,
    this.borderColor = const Color(0xFFE5E7EB),
    this.borderWidth = 1,
    this.borderRadius = 12,
    this.isLoading = false,
    this.loadingColor = const Color(0xFF6B7280),
    this.disabledColor = const Color(0xFFF3F4F6),
    this.disabledTextColor = const Color(0xFF9CA3AF),
    this.disabledBorderColor = const Color(0xFFD1D5DB),
    this.enabled = true,
    this.showShadow = false,
    this.shadowColor = const Color(0x1A000000),
    this.shadowBlurRadius = 4,
    this.shadowOffset = const Offset(0, 2),
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final IconData? icon;
  final EdgeInsetsGeometry iconPadding;
  final double iconSize;
  final Color iconColor;
  final Color backgroundColor;
  final Color textColor;
  final double textSize;
  final FontWeight textFontWeight;
  final double elevation;
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final bool isLoading;
  final Color loadingColor;
  final Color disabledColor;
  final Color disabledTextColor;
  final Color disabledBorderColor;
  final bool enabled;
  final bool showShadow;
  final Color shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: showShadow
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: shadowColor,
                  blurRadius: shadowBlurRadius,
                  offset: shadowOffset,
                ),
              ],
            )
          : null,
      child: TextButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: TextButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          padding: padding,
          elevation: elevation,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: BorderSide(
              color: _getBorderColor(),
              width: borderWidth,
            ),
          ),
        ),
        child: _buildButtonContent(),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (!enabled) return disabledColor;
    return backgroundColor;
  }

  Color _getBorderColor() {
    if (!enabled) return disabledBorderColor;
    return borderColor;
  }

  Color _getTextColor() {
    if (!enabled) return disabledTextColor;
    return textColor;
  }

  Color _getIconColor() {
    if (!enabled) return disabledTextColor;
    return iconColor;
  }

  Widget _buildButtonContent() {
    if (isLoading) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: iconPadding,
            child: Icon(
              icon,
              color: _getIconColor(),
              size: iconSize,
            ),
          ),
          const SizedBox(width: 8),
          _buildText(),
        ],
      );
    }

    return _buildText();
  }

  Widget _buildText() {
    return Text(
      text,
      style: TextStyle(
        color: _getTextColor(),
        fontSize: textSize,
        fontWeight: textFontWeight,
        letterSpacing: 0.0,
      ),
      textAlign: TextAlign.center,
    );
  }
}