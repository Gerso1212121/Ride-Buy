import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label;
  final List<String> autofillHints;
  final TextInputType keyboardType;
  final bool isPassword;
  final String? Function(String?) validator;
  final Color? borderColor; // ✅ Nuevo
  final Color? focusedBorderColor; // ✅ Nuevo

  const CustomTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.label,
    this.autofillHints = const [],
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    required this.validator,
    this.borderColor,
    this.focusedBorderColor,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  void _toggleVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  @override
  Widget build(BuildContext context) {
    final borderClr = widget.borderColor ?? FlutterFlowTheme.of(context).alternate;
    final focusedBorderClr = widget.focusedBorderColor ?? FlutterFlowTheme.of(context).primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        autofocus: !widget.isPassword,
        autofillHints: widget.autofillHints,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        cursorColor: FlutterFlowTheme.of(context).primary,
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lato(
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              letterSpacing: 0.0,
            ),
        decoration: InputDecoration(
          labelText: widget.label,
          labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                font: GoogleFonts.lato(
                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                ),
                letterSpacing: 0.0,
              ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: borderClr,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(40.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: focusedBorderClr,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(40.0),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(40.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: FlutterFlowTheme.of(context).error,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(40.0),
          ),
          filled: true,
          fillColor: FlutterFlowTheme.of(context).secondaryBackground,
          contentPadding: const EdgeInsets.all(24.0),
          suffixIcon: widget.isPassword
              ? InkWell(
                  onTap: _toggleVisibility,
                  focusNode: FocusNode(skipTraversal: true),
                  child: Icon(
                    _obscureText
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 24.0,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
