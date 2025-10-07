import 'package:flutter/material.dart';

class SectionHeaderHomeWidgets extends StatelessWidget {
  const SectionHeaderHomeWidgets({
    Key? key,
    required this.title,
    this.actionText = 'View fall',
    this.onActionPressed,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.titleColor = const Color(0xFF1E293B),
    this.actionColor = const Color(0xFF3B82F6),
    this.titleSize = 20,
    this.actionSize = 14,
    this.titleFontWeight = FontWeight.bold,
    this.actionFontWeight = FontWeight.w500,
    this.spacing = MainAxisAlignment.spaceBetween,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  final String title;
  final String actionText;
  final VoidCallback? onActionPressed;
  final EdgeInsetsGeometry padding;
  final Color titleColor;
  final Color actionColor;
  final double titleSize;
  final double actionSize;
  final FontWeight titleFontWeight;
  final FontWeight actionFontWeight;
  final MainAxisAlignment spacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: spacing,
        crossAxisAlignment: crossAxisAlignment,
        children: [
          // Title
          Text(
            title,
            style: TextStyle(
              color: titleColor,
              fontSize: titleSize,
              fontWeight: titleFontWeight,
              letterSpacing: 0.0,
            ),
          ),
          
          // Action
          if (actionText.isNotEmpty)
            GestureDetector(
              onTap: onActionPressed,
              child: Text(
                actionText,
                style: TextStyle(
                  color: actionColor,
                  fontSize: actionSize,
                  fontWeight: actionFontWeight,
                  letterSpacing: 0.0,
                ),
              ),
            ),
        ],
      ),
    );
  }
}