import 'package:flutter/material.dart';

class VehicleCard extends StatelessWidget {
  const VehicleCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.reviewCount,
    required this.price,
    this.width = double.infinity,
    this.height = 120,
    this.padding = const EdgeInsets.only(bottom: 16),
    this.backgroundColor = Colors.white,
    this.shadowColor = const Color(0x1A1E293B),
    this.shadowBlurRadius = 8,
    this.shadowOffset = const Offset(0, 2),
    this.borderRadius = 16,
    this.contentPadding = const EdgeInsets.all(16),
    this.imageWidth = 100,
    this.imageHeight = 80,
    this.imageBorderRadius = 12,
    this.spacing = 16,
    this.verticalSpacing = 4,
    this.titleColor = const Color(0xFF1E293B),
    this.subtitleColor = const Color(0xFF64748B),
    this.ratingColor = const Color(0xFF1E293B),
    this.reviewCountColor = const Color(0xFF64748B),
    this.priceColor = const Color(0xFF3B82F6),
    this.starColor = const Color(0xFFFBBF24),
    this.titleSize = 16,
    this.subtitleSize = 12,
    this.ratingSize = 12,
    this.priceSize = 16,
    this.titleFontWeight = FontWeight.w600,
    this.subtitleFontWeight = FontWeight.normal,
    this.ratingFontWeight = FontWeight.w500,
    this.reviewCountFontWeight = FontWeight.normal,
    this.priceFontWeight = FontWeight.bold,
    this.starSize = 16,
    this.onTap,
  }) : super(key: key);

  final String imageUrl;
  final String title;
  final String subtitle;
  final double rating;
  final int reviewCount;
  final String price;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final Color shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;
  final double imageWidth;
  final double imageHeight;
  final double imageBorderRadius;
  final double spacing;
  final double verticalSpacing;
  final Color titleColor;
  final Color subtitleColor;
  final Color ratingColor;
  final Color reviewCountColor;
  final Color priceColor;
  final Color starColor;
  final double titleSize;
  final double subtitleSize;
  final double ratingSize;
  final double priceSize;
  final FontWeight titleFontWeight;
  final FontWeight subtitleFontWeight;
  final FontWeight ratingFontWeight;
  final FontWeight reviewCountFontWeight;
  final FontWeight priceFontWeight;
  final double starSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: backgroundColor,
            boxShadow: [
              BoxShadow(
                blurRadius: shadowBlurRadius,
                color: shadowColor,
                offset: shadowOffset,
              ),
            ],
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          child: Padding(
            padding: contentPadding,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Vehicle Image con loading builder
                ClipRRect(
                  borderRadius: BorderRadius.circular(imageBorderRadius),
                  child: Image.network(
                    imageUrl,
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      
                      return Container(
                        width: imageWidth,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(imageBorderRadius),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: imageWidth,
                        height: imageHeight,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(imageBorderRadius),
                        ),
                        child: Icon(
                          Icons.directions_car,
                          color: Colors.grey[600],
                        ),
                      );
                    },
                  ),
                ),
                
                SizedBox(width: spacing),
                
                // Content
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: verticalSpacing),
                      
                      // Subtitle
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: subtitleColor,
                          fontSize: subtitleSize,
                          fontWeight: subtitleFontWeight,
                          letterSpacing: 0.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      SizedBox(height: verticalSpacing),
                      
                      // Rating and Price Row
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Rating
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Icon(
                                Icons.star,
                                color: starColor,
                                size: starSize,
                              ),
                              SizedBox(width: 4),
                              Text(
                                rating.toStringAsFixed(1),
                                style: TextStyle(
                                  color: ratingColor,
                                  fontSize: ratingSize,
                                  fontWeight: ratingFontWeight,
                                  letterSpacing: 0.0,
                                ),
                              ),
                              SizedBox(width: 4),
                              Text(
                                '($reviewCount)',
                                style: TextStyle(
                                  color: reviewCountColor,
                                  fontSize: ratingSize,
                                  fontWeight: reviewCountFontWeight,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                          
                          // Price
                          Text(
                            price,
                            style: TextStyle(
                              color: priceColor,
                              fontSize: priceSize,
                              fontWeight: priceFontWeight,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}