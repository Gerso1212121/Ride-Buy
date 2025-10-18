import 'package:flutter/material.dart';

class InfoCard extends StatelessWidget {
  const InfoCard({
    Key? key,
    required this.features,
    this.title = 'Información del vehículo',
    this.backgroundColor = Colors.white,
    this.titleColor = Colors.black,
    this.iconColor = const Color(0xFF105DFB),
    this.textColor = const Color(0xFF5A5C60),
    this.borderRadius = 12,
    this.padding = const EdgeInsets.all(16),
    this.titleSize = 18,
    this.textSize = 12,
    this.iconSize = 28,
    this.titleFontWeight = FontWeight.w600,
    this.textFontWeight = FontWeight.normal,
    this.verticalSpacing = 12,
    this.featureSpacing = 0,
    this.crossAxisAlignment = CrossAxisAlignment.center,
  }) : super(key: key);

  final List<VehicleFeature> features;
  final String title;
  final Color backgroundColor;
  final Color titleColor;
  final Color iconColor;
  final Color textColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final double titleSize;
  final double textSize;
  final double iconSize;
  final FontWeight titleFontWeight;
  final FontWeight textFontWeight; 
  final double verticalSpacing;
  final double featureSpacing;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Título de la sección
            Text(
              title,
              style: TextStyle(
                color: titleColor,
                fontSize: titleSize,
                fontWeight: titleFontWeight,
                letterSpacing: 0.0,
              ),
            ),
            
            SizedBox(height: verticalSpacing),
            
            // Fila de características
            Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildFeatures(),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFeatures() {
    return features.map((feature) {
      return Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: featureSpacing),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: crossAxisAlignment,
            children: [
              // Ícono
              Icon(
                feature.icon,
                color: feature.iconColor ?? iconColor,
                size: feature.iconSize ?? iconSize,
              ),
              
              // Espaciado
              const SizedBox(height: 4),
              
              // Texto
              Text(
                feature.text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: feature.textColor ?? textColor,
                  fontSize: feature.textSize ?? textSize,
                  fontWeight: feature.textFontWeight ?? textFontWeight,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class VehicleFeature {
  final IconData icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final double? iconSize;
  final double? textSize;
  final FontWeight? textFontWeight;

  const VehicleFeature({
    required this.icon,
    required this.text,
    this.iconColor,
    this.textColor,
    this.iconSize,
    this.textSize,
    this.textFontWeight,
  });
}