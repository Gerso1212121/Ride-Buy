import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReviewCard extends StatelessWidget {
  final String userName;
  final String userImageUrl;
  final double rating;
  final String comment;
  final String timeAgo;
  final EdgeInsets padding;
  final EdgeInsets contentPadding;
  final double avatarSize;
  final double starSize;
  final double starSpacing;
  final double rowSpacing;
  final double textSpacing;
  final Color starColor;

  const ReviewCard({
    Key? key,
    required this.userName,
    required this.userImageUrl,
    required this.rating,
    required this.comment,
    required this.timeAgo,
    this.padding = const EdgeInsets.all(10),
    this.contentPadding = const EdgeInsets.all(16),
    this.avatarSize = 40,
    this.starSize = 14,
    this.starSpacing = 2,
    this.rowSpacing = 12,
    this.textSpacing = 8,
    this.starColor = const Color(0xFFFFD700),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    
    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con avatar y info del usuario
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // Avatar del usuario
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    clipBehavior: Clip.antiAlias,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: Image.network(
                      userImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.person,
                        size: avatarSize * 0.6,
                        color: theme.secondaryText,
                      ),
                    ),
                  ),
                  
                  // Información del usuario y rating
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre del usuario
                        Text(
                          userName,
                          style: theme.bodyMedium.override(
                            font: GoogleFonts.lato(
                              fontWeight: FontWeight.w600,
                              fontStyle: theme.bodyMedium.fontStyle,
                            ),
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        
                        // Rating con estrellas
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0, 2, 0, 0),
                          child: _buildStars(rating, starSize, starColor, starSpacing),
                        ),
                      ],
                    ),
                  ),
                ].divide(SizedBox(width: rowSpacing)),
              ),
              
              // Comentario
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                child: Text(
                  comment,
                  style: theme.bodySmall.override(
                    font: GoogleFonts.lato(
                      fontWeight: theme.bodySmall.fontWeight,
                      fontStyle: theme.bodySmall.fontStyle,
                    ),
                    color: theme.primaryText,
                    letterSpacing: 0.0,
                    lineHeight: 1.4,
                  ),
                ),
              ),
              
              // Tiempo transcurrido
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 0),
                child: Text(
                  timeAgo,
                  style: theme.bodySmall.override(
                    font: GoogleFonts.lato(
                      fontWeight: theme.bodySmall.fontWeight,
                      fontStyle: theme.bodySmall.fontStyle,
                    ),
                    color: theme.secondaryText,
                    letterSpacing: 0.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStars(double rating, double size, Color color, double spacing) {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.5;
    
    List<Widget> stars = [];
    
    // Estrellas llenas
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(
        Icons.star_rounded,
        color: color,
        size: size,
      ));
    }
    
    // Media estrella
    if (hasHalfStar) {
      stars.add(Icon(
        Icons.star_half_rounded,
        color: color,
        size: size,
      ));
    }
    
    // Estrellas vacías
    final emptyStars = 5 - stars.length;
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(
        Icons.star_outline_rounded,
        color: color,
        size: size,
      ));
    }
    
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: stars.divide(SizedBox(width: spacing)),
    );
  }
}