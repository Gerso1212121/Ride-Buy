import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleFavCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String description;
  final String price;
  final VoidCallback onFavoritePressed;
  final VoidCallback onDetailsPressed;
  final bool isFavorite;
  final double imageWidth;
  final double imageHeight;
  final EdgeInsets padding;

  const VehicleFavCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.onFavoritePressed,
    required this.onDetailsPressed,
    this.isFavorite = false,
    this.imageWidth = 120,
    this.imageHeight = 90,
    this.padding = const EdgeInsets.all(12),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant,
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0.0, 2),
            ),
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Imagen del vehículo
              _buildVehicleImage(context),
              const SizedBox(width: 12),
              // Contenido informativo
              _buildVehicleInfo(context, theme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleImage(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: CachedNetworkImage(
        fadeInDuration: const Duration(milliseconds: 0),
        fadeOutDuration: const Duration(milliseconds: 0),
        imageUrl: imageUrl,
        width: imageWidth,
        height: imageHeight,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: imageWidth,
          height: imageHeight,
          color: Colors.grey[300],
          child: const Icon(Icons.car_rental, color: Colors.grey),
        ),
        errorWidget: (context, url, error) => Container(
          width: imageWidth,
          height: imageHeight,
          color: Colors.grey[300],
          child: const Icon(Icons.error_outline, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Fila de título y botón de favorito
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: GoogleFonts.figtree().fontFamily,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _buildFavoriteButton(context, colorScheme),
            ],
          ),
          const SizedBox(height: 6),
          // Subtítulo
          Text(
            subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: GoogleFonts.figtree().fontFamily,
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 6),
          // Descripción
          Text(
            description,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontFamily: GoogleFonts.figtree().fontFamily,
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
              letterSpacing: 0.0,
            ),
          ),
          const SizedBox(height: 6),
          // Fila de precio y botón
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                price,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: GoogleFonts.figtree().fontFamily,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.primary,
                  letterSpacing: 0.0,
                ),
              ),
              const SizedBox(width: 8),
              _buildDetailsButton(context, colorScheme),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isFavorite ? colorScheme.error : colorScheme.error.withOpacity(0.1),
      ),
      child: IconButton(
        icon: Icon(
          Icons.favorite,
          color: isFavorite ? colorScheme.onError : colorScheme.error,
          size: 18,
        ),
        onPressed: onFavoritePressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  Widget _buildDetailsButton(BuildContext context, ColorScheme colorScheme) {
    final theme =   Theme.of(context);
    return ElevatedButton(
      onPressed: onDetailsPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        textStyle: theme.textTheme.labelMedium?.copyWith(
          fontFamily: GoogleFonts.figtree().fontFamily,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
        ),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: const Size(0, 32),
      ),
      child: const Text('Ver Detalles'),
    );
  }
}