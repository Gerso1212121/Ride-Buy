import 'package:flutter/material.dart';

class Info_CarDetailwidgets extends StatelessWidget {
  const Info_CarDetailwidgets({
    Key? key,
    required this.price,
    required this.period,
    this.label = 'Precio por día',
    this.priceColor = const Color(0xFF105DFB),
    this.labelColor = const Color(0xFF5A5C60),
    this.periodColor = const Color(0xFF5A5C60),
    this.favoriteColor = const Color(0xFF105DFB),
    this.favoriteBackgroundColor = const Color(0x4C105DFB),
    this.labelSize = 14,
    this.priceSize = 32,
    this.periodSize = 16,
    this.favoriteIconSize = 24,
    this.favoriteButtonSize = 48,
    this.isFavorite = false,
    this.onFavoritePressed,
    this.showFavoriteButton = true,
    this.crossAxisAlignment = CrossAxisAlignment.end,
    this.labelFontWeight = FontWeight.normal,
    this.priceFontWeight = FontWeight.bold,
    this.periodFontWeight = FontWeight.normal,
  }) : super(key: key);

  final String price;
  final String period;
  final String label;
  final Color priceColor;
  final Color labelColor;
  final Color periodColor;
  final Color favoriteColor;
  final Color favoriteBackgroundColor;
  final double labelSize;
  final double priceSize;
  final double periodSize;
  final double favoriteIconSize;
  final double favoriteButtonSize;
  final bool isFavorite;
  final VoidCallback? onFavoritePressed;
  final bool showFavoriteButton;
  final CrossAxisAlignment crossAxisAlignment;
  final FontWeight labelFontWeight;
  final FontWeight priceFontWeight;
  final FontWeight periodFontWeight;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: crossAxisAlignment,
      children: [
        // Columna de precio
        Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Label (Precio por día)
            Text(
              label,
              style: TextStyle(
                color: labelColor,
                fontSize: labelSize,
                fontWeight: labelFontWeight,
                letterSpacing: 0.0,
              ),
            ),
            
            // Precio con RichText
            _buildPriceRichText(),
          ],
        ),
        
        // Botón de favorito (opcional)
        if (showFavoriteButton) 
          _buildFavoriteButton(),
      ],
    );
  }

  Widget _buildPriceRichText() {
    return RichText(
      text: TextSpan(
        children: [
          // Precio principal
          TextSpan(
            text: price,
            style: TextStyle(
              color: priceColor,
              fontWeight: priceFontWeight,
              fontSize: priceSize,
              letterSpacing: 0.0,
            ),
          ),
          // Periodo (/día, /hora, etc.)
          TextSpan(
            text: '/$period',
            style: TextStyle(
              color: periodColor,
              fontSize: periodSize,
              fontWeight: periodFontWeight,
              letterSpacing: 0.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return GestureDetector(
      onTap: onFavoritePressed,
      child: Container(
        width: favoriteButtonSize,
        height: favoriteButtonSize,
        decoration: BoxDecoration(
          color: favoriteBackgroundColor,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: favoriteColor,
          size: favoriteIconSize,
        ),
      ),
    );
  }
}