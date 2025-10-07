import 'package:flutter/material.dart';

class SearchTextField extends StatelessWidget {
  const SearchTextField({
    Key? key,
    required this.controller,
    this.focusNode,
    this.hintText = 'Search for cars, locations...',
    this.hintColor = const Color(0xFF94A3B8),
    this.hintStyle,
    this.textStyle,
    this.prefixIcon = Icons.search_rounded,
    this.prefixIconColor = const Color(0xFF3B82F6),
    this.prefixIconSize = 20,
    this.padding = const EdgeInsets.all(4),
    this.backgroundColor = Colors.transparent,
    this.borderRadius = 0,
    this.showBorder = false,
    this.borderColor = Colors.grey,
    this.focusedBorderColor = const Color(0xFF3B82F6),
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.validator,
    this.autofocus = false,
    this.obscureText = false,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.textInputAction = TextInputAction.search,
  }) : super(key: key);

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final Color hintColor;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;
  final IconData prefixIcon;
  final Color prefixIconColor;
  final double prefixIconSize;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double borderRadius;
  final bool showBorder;
  final Color borderColor;
  final Color focusedBorderColor;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final bool autofocus;
  final bool obscureText;
  final bool enabled;
  final TextInputType keyboardType;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: showBorder
              ? Border.all(
                  color: borderColor,
                  width: 1,
                )
              : null,
        ),
        child: TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          obscureText: obscureText,
          enabled: enabled,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle ?? _getHintStyle(context),
            filled: backgroundColor != Colors.transparent,
            fillColor: backgroundColor,
            enabledBorder: _getBorder(borderColor),
            focusedBorder: _getBorder(focusedBorderColor),
            errorBorder: _getBorder(Colors.red),
            focusedErrorBorder: _getBorder(Colors.red),
            prefixIcon: Icon(
              prefixIcon,
              color: prefixIconColor,
              size: prefixIconSize,
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
          ),
          style: textStyle ?? _getTextStyle(context),
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          onTap: onTap,
          validator: validator,
        ),
      ),
    );
  }

  InputBorder _getBorder(Color color) {
    if (showBorder) {
      return OutlineInputBorder(
        borderSide: BorderSide(color: color, width: 1),
        borderRadius: BorderRadius.circular(borderRadius),
      );
    } else {
      return InputBorder.none;
    }
  }

  TextStyle _getHintStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: hintColor,
          fontSize: 16,
          letterSpacing: 0.0,
        ) ??
        const TextStyle(
          color: Color(0xFF94A3B8),
          fontSize: 16,
          letterSpacing: 0.0,
        );
  }

  TextStyle _getTextStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium?.copyWith(
          fontSize: 16,
          letterSpacing: 0.0,
        ) ??
        const TextStyle(
          fontSize: 16,
          letterSpacing: 0.0,
        );
  }
}