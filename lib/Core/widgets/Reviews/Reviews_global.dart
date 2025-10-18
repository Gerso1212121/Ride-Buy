import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int reviewCount;
  final double starSize;
  final Color starColor;
  final double starSpacing;
  final double textSpacing;
  final TextStyle? ratingTextStyle;
  final TextStyle? reviewsTextStyle;
  final MainAxisAlignment mainAxisAlignment;

  const RatingWidget({
    Key? key,
    required this.rating,
    required this.reviewCount,
    this.starSize = 20,
    this.starColor = const Color(0xFFFFD700),
    this.starSpacing = 2,
    this.textSpacing = 8,
    this.ratingTextStyle,
    this.reviewsTextStyle,
    this.mainAxisAlignment = MainAxisAlignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: mainAxisAlignment,
      children: [
        // Estrellas
        Row(
          mainAxisSize: MainAxisSize.max,
          children: _buildStars(rating, starSize, starColor).divide(SizedBox(width: starSpacing)),
        ),
        
        // Puntuación numérica
        Text(
          rating.toStringAsFixed(1),
          style: ratingTextStyle ?? theme.bodyMedium.override(
            font: GoogleFonts.lato(
              fontWeight: FontWeight.w600,
              fontStyle: theme.bodyMedium.fontStyle,
            ),
            letterSpacing: 0.0,
            fontWeight: FontWeight.w600,
            fontStyle: theme.bodyMedium.fontStyle,
          ),
        ),
        
        // Número de reseñas
        Text(
          '($reviewCount reseñas)',
          style: reviewsTextStyle ?? theme.bodyMedium.override(
            font: GoogleFonts.lato(
              fontWeight: theme.bodyMedium.fontWeight,
              fontStyle: theme.bodyMedium.fontStyle,
            ),
            color: theme.secondaryText,
            letterSpacing: 0.0,
            fontWeight: theme.bodyMedium.fontWeight,
            fontStyle: theme.bodyMedium.fontStyle,
          ),
        ),
      ].divide(SizedBox(width: textSpacing)),
    );
  }

  List<Widget> _buildStars(double rating, double size, Color color) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    // Estrellas llenas
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(
        Icons.star_rounded,
        color: color,
        size: size,
      ));
    }

    // Media estrella si es necesario
    if (hasHalfStar) {
      stars.add(Icon(
        Icons.star_half_rounded,
        color: color,
        size: size,
      ));
    }

    // Estrellas vacías para completar 5
    int emptyStars = 5 - stars.length;
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(
        Icons.star_outline_rounded,
        color: color,
        size: size,
      ));
    }

    // Limitar a máximo 5 estrellas
    return stars.length > 5 ? stars.sublist(0, 5) : stars;
  }
}