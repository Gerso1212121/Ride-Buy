import 'package:flutter/material.dart';

class BottomBarCardetailwidgets extends StatelessWidget {
  const BottomBarCardetailwidgets({
    Key? key,
    required this.price,
    required this.period,
    required this.onRentPressed,
    this.label = 'Total estimado',
    this.buttonText = 'Rentar Ahora',
    this.height = 90,
    this.backgroundColor = const Color(0xFFF6F6F6),
    this.shadowColor = const Color(0x1A000000),
    this.shadowBlurRadius = 10,
    this.shadowOffset = const Offset(0.0, -2),
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.labelColor = const Color(0xFF5A5C60),
    this.priceColor = const Color(0xFF105DFB),
    this.periodColor = const Color(0xFF5A5C60),
    this.buttonColor = const Color(0xFF105DFB),
    this.buttonTextColor = const Color(0xFFE0E3E7),
    this.labelSize = 12,
    this.priceSize = 24,
    this.periodSize = 14,
    this.buttonTextSize = 18,
    this.labelFontWeight = FontWeight.normal,
    this.priceFontWeight = FontWeight.bold,
    this.periodFontWeight = FontWeight.normal,
    this.buttonFontWeight = FontWeight.w600,
    this.buttonHeight = 50,
    this.buttonPadding = const EdgeInsets.symmetric(horizontal: 32),
    this.buttonBorderRadius = 25,
    this.buttonElevation = 2,
    this.showShadow = true,
  }) : super(key: key);

  final String price;
  final String period;
  final VoidCallback onRentPressed;
  final String label;
  final String buttonText;
  final double height;
  final Color backgroundColor;
  final Color shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;
  final EdgeInsetsGeometry padding;
  final Color labelColor;
  final Color priceColor;
  final Color periodColor;
  final Color buttonColor;
  final Color buttonTextColor;
  final double labelSize;
  final double priceSize;
  final double periodSize;
  final double buttonTextSize;
  final FontWeight labelFontWeight;
  final FontWeight priceFontWeight;
  final FontWeight periodFontWeight;
  final FontWeight buttonFontWeight;
  final double buttonHeight;
  final EdgeInsetsGeometry buttonPadding;
  final double buttonBorderRadius;
  final double buttonElevation;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional.bottomCenter,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    blurRadius: shadowBlurRadius,
                    color: shadowColor,
                    offset: shadowOffset,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: padding,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Columna de precio
              Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Label (Total estimado)
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
              
              // Botón de renta
              _buildRentButton(),
            ],
          ),
        ),
      ),
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
          // Periodo
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

  Widget _buildRentButton() {
    return Container(
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onRentPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: buttonPadding,
          elevation: buttonElevation,
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
    );
  }
}