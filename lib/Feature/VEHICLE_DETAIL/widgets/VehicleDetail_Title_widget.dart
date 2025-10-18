import 'package:flutter/material.dart';

class TitleCarDetailwidgets extends StatelessWidget {
  const TitleCarDetailwidgets({
    Key? key,
    required this.title,
    required this.tag,
    required this.year,
    this.titleColor = const Color(0xFF12151C),
    this.tagColor = const Color(0xFFEE8B60),
    this.tagTextColor = const Color(0xFFE0E3E7),
    this.yearColor = const Color(0xFF5A5C60),
    this.titleSize = 32,
    this.tagSize = 12,
    this.yearSize = 14,
    this.titleFontWeight = FontWeight.bold,
    this.tagFontWeight = FontWeight.w600,
    this.yearFontWeight = FontWeight.normal,
    this.tagPadding = const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    this.tagBorderRadius = 14,
    this.verticalSpacing = 8,
    this.horizontalSpacing = 8,
    this.crossAxisAlignment = CrossAxisAlignment.start,
  }) : super(key: key);

  final String title;
  final String tag;
  final String year;
  final Color titleColor;
  final Color tagColor;
  final Color tagTextColor;
  final Color yearColor;
  final double titleSize;
  final double tagSize;
  final double yearSize;
  final FontWeight titleFontWeight;
  final FontWeight tagFontWeight;
  final FontWeight yearFontWeight;
  final EdgeInsetsGeometry tagPadding;
  final double tagBorderRadius;
  final double verticalSpacing;
  final double horizontalSpacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        // Título principal del vehículo
        Text(
          title,
          style: TextStyle(
            color: titleColor,
            fontSize: titleSize,
            fontWeight: titleFontWeight,
            letterSpacing: 0.0,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        SizedBox(height: verticalSpacing),
        
        // Fila con tag y año
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Tag de categoría (SUV Premium, Luxury, etc.)
            Container(
              height: 28,
              decoration: BoxDecoration(
                color: tagColor,
                borderRadius: BorderRadius.circular(tagBorderRadius),
              ),
              child: Padding(
                padding: tagPadding,
                child: Text(
                  tag,
                  style: TextStyle(
                    color: tagTextColor,
                    fontSize: tagSize,
                    fontWeight: tagFontWeight,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ),
            
            SizedBox(width: horizontalSpacing),
            
            // Año del vehículo
            Text(
              '• $year',
              style: TextStyle(
                color: yearColor,
                fontSize: yearSize,
                fontWeight: yearFontWeight,
                letterSpacing: 0.0,
              ),
            ),
          ],
        ),
      ],
    );
  }
}