import 'package:flutter/material.dart';

class PromoBanner extends StatelessWidget {
  const PromoBanner({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.imageUrl,
    this.onPressed,
    this.width = double.infinity,
    this.height = 220,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
    this.gradient = const LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF1E40AF)],
      stops: [0, 1],
      begin: AlignmentDirectional(1, 1),
      end: AlignmentDirectional(-1, -1),
    ),
    this.shadowColor = const Color(0x333B82F6),
    this.shadowBlurRadius = 12,
    this.shadowOffset = const Offset(0, 4),
    this.borderRadius = 20,
    this.titleColor = Colors.white,
    this.subtitleColor = const Color(0xFFBFDBFE),
    this.buttonColor = Colors.white,
    this.buttonTextColor = const Color(0xFF1E40AF),
    this.titleSize = 24,
    this.subtitleSize = 14,
    this.buttonTextSize = 14,
    this.titleFontWeight = FontWeight.bold,
    this.subtitleFontWeight = FontWeight.normal,
    this.buttonFontWeight = FontWeight.w600,
    this.contentPadding = const EdgeInsets.all(20),
    this.verticalSpacing = 12,
    this.imageWidth = 139.3,
    this.imageHeight = 220,
    this.imageBorderRadius = 12,
    this.buttonHeight = 40,
    this.buttonPadding = const EdgeInsets.symmetric(horizontal: 25),
    this.buttonBorderRadius = 12,
    this.alignment = AlignmentDirectional.centerStart,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final String buttonText;
  final String imageUrl;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final EdgeInsetsGeometry padding;
  final Gradient gradient;
  final Color shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;
  final double borderRadius;
  final Color titleColor;
  final Color subtitleColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final double titleSize;
  final double subtitleSize;
  final double buttonTextSize;
  final FontWeight titleFontWeight;
  final FontWeight subtitleFontWeight;
  final FontWeight buttonFontWeight;
  final EdgeInsetsGeometry contentPadding;
  final double verticalSpacing;
  final double imageWidth;
  final double imageHeight;
  final double imageBorderRadius;
  final double buttonHeight;
  final EdgeInsetsGeometry buttonPadding;
  final double buttonBorderRadius;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              blurRadius: shadowBlurRadius,
              color: shadowColor,
              offset: shadowOffset,
            ),
          ],
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Align(
          alignment: alignment,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Content section
              Expanded(
                child: Padding(
                  padding: contentPadding,
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
                      ),
                      
                      SizedBox(height: verticalSpacing),
                      
                      // Button
                      SizedBox(
                        height: buttonHeight,
                        child: ElevatedButton(
                          onPressed: onPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: buttonColor,
                            padding: buttonPadding,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(buttonBorderRadius),
                              side: const BorderSide(
                                color: Colors.transparent,
                              ),
                            ),
                          ),
                          child: Text(
                            buttonText,
                            style: TextStyle(
                              color: buttonTextColor,
                              fontSize: buttonTextSize,
                              fontWeight: buttonFontWeight,
                              letterSpacing: 0.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Image section con loading builder
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(imageBorderRadius),
                  bottomRight: Radius.circular(imageBorderRadius),
                ),
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
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(imageBorderRadius),
                          bottomRight: Radius.circular(imageBorderRadius),
                        ),
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
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
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(imageBorderRadius),
                          bottomRight: Radius.circular(imageBorderRadius),
                        ),
                      ),
                      child: Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[600],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}