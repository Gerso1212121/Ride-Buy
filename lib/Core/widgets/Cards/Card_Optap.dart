import 'package:flutter/material.dart';

class GenericCardGlobalwidgets extends StatelessWidget {
  const GenericCardGlobalwidgets({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.width = 100,
    this.height = 100,
    this.iconSize = 24,
    this.iconContainerSize = 48,
    this.iconColor = Colors.white,
    this.iconBackgroundColor = const Color(0xFF2563EB),
    this.backgroundColor = const Color.fromARGB(255, 255, 255, 255),
    this.borderColor = const Color(0xFFE2E8F0),
    this.borderRadius = 16,
    this.iconBorderRadius = 12,
    this.titleColor = const Color(0xFF1E293B),
    this.subtitleColor = const Color(0xFF64748B),
    this.titleFontSize = 14,
    this.subtitleFontSize = 12,
    this.titleFontWeight = FontWeight.w600,
    this.subtitleFontWeight = FontWeight.normal,
    this.verticalSpacing = 4,
    this.horizontalPadding = 8,
    this.verticalPadding = 12,
    this.onTap,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final IconData icon;
  final double width;
  final double height;
  final double iconSize;
  final double iconContainerSize;
  final Color iconColor;
  final Color iconBackgroundColor;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double iconBorderRadius;
  final Color titleColor;
  final Color subtitleColor;
  final double titleFontSize;
  final double subtitleFontSize;
  final FontWeight titleFontWeight;
  final FontWeight subtitleFontWeight;
  final double verticalSpacing;
  final double horizontalPadding;
  final double verticalPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: 1,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: horizontalPadding,
            vertical: verticalPadding,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon container
              Container(
                width: iconContainerSize,
                height: iconContainerSize,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(iconBorderRadius),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: iconSize,
                ),
              ),
              
              SizedBox(height: verticalSpacing),
              
              // Title
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: titleColor,
                  fontSize: titleFontSize,
                  fontWeight: titleFontWeight,
                  letterSpacing: 0.0,
                ),
              ),
              
              SizedBox(height: verticalSpacing / 2),
              
              // Subtitle
              Text(
                subtitle,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: subtitleColor,
                  fontSize: subtitleFontSize,
                  fontWeight: subtitleFontWeight,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}