import 'package:flutter/material.dart';

class PrimaryButtonPaycWidgets extends StatelessWidget {
  const PrimaryButtonPaycWidgets({
    Key? key,
    required this.onPressed,
    required this.text,
    this.width = double.infinity,
    this.height = 52,
    this.backgroundColor = const Color(0xFF10B981),
    this.textColor = Colors.white,
    this.borderRadius = 12,
    this.isLoading = false,
    this.enabled = true,
  }) : super(key: key);

  final VoidCallback onPressed;
  final String text;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color textColor;
  final double borderRadius;
  final bool isLoading;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: enabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            side: const BorderSide(
              color: Colors.transparent,
              width: 0,
            ),
          ),
          disabledBackgroundColor: const Color(0xFF9CA3AF),
        ),
        child: isLoading
            ? const _LoadingIndicator()
            : _ButtonText(text: text, textColor: textColor),
      ),
    );
  }
}

class _LoadingIndicator extends StatelessWidget {
  const _LoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 20,
      height: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }
}

class _ButtonText extends StatelessWidget {
  const _ButtonText({
    required this.text,
    required this.textColor,
  });

  final String text;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
      ),
      textAlign: TextAlign.center,
    );
  }
}