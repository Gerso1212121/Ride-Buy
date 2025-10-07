import 'package:ezride/flutter_flow/flutter_flow_icon_button.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String hintText;
  final Color sendButtonColor;
  final Color attachButtonColor;
  final Color inputFillColor;
  final Color borderColor;
  final Color focusedBorderColor;
  final double borderRadius;
  final double buttonSize;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry inputPadding;
  final bool autofocus;
  final int maxLines;
  final Function(String)? onSubmitted;
  final Function()? onAttachPressed;
  final Function()? onSendPressed;
  final String? Function(String?)? validator;

  const MessageInput({
    Key? key,
    this.controller,
    this.focusNode,
    this.hintText = 'Escribe un mensaje...',
    this.sendButtonColor = const Color.fromARGB(255, 70, 107, 229),
    this.attachButtonColor = Colors.grey,
    this.inputFillColor = Colors.white,
    this.borderColor = Colors.grey,
    this.focusedBorderColor = const Color(0xFF4F46E5),
    this.borderRadius = 20,
    this.buttonSize = 40,
    this.padding = const EdgeInsets.all(16),
    this.inputPadding = const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
    this.autofocus = false,
    this.maxLines = 3,
    this.onSubmitted,
    this.onAttachPressed,
    this.onSendPressed,
    this.validator,
  }) : super(key: key);

  @override
  State<MessageInput> createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  late TextEditingController _controller;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    // Solo dispose los controllers que creamos nosotros
    if (widget.controller == null) {
      _controller.dispose();
    }
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendPressed?.call();
      widget.onSubmitted?.call(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            // Botón adjuntar
            FlutterFlowIconButton(
              borderRadius: widget.borderRadius,
              buttonSize: widget.buttonSize,
              fillColor: FlutterFlowTheme.of(context).primaryBackground,
              icon: Icon(
                Icons.attach_file,
                color: FlutterFlowTheme.of(context).secondaryText,
                size: 20,
              ),
              onPressed: widget.onAttachPressed ??
                  () {
                    print('Botón adjuntar presionado');
                  },
            ),

            // Campo de texto
            Expanded(
              child: TextFormField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                textInputAction: TextInputAction.send,
                obscureText: false,
                onFieldSubmitted: (value) {
                  _handleSend();
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.inter(
                          fontWeight: FlutterFlowTheme.of(context)
                              .bodyMedium
                              .fontWeight,
                          fontStyle:
                              FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).secondaryText,
                        fontSize: 14,
                        letterSpacing: 0.0,
                      ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.borderColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.focusedBorderColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(widget.borderRadius),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).primaryBackground,
                  contentPadding: widget.inputPadding,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.lato(
                        fontWeight:
                            FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle:
                            FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      fontSize: 14,
                      letterSpacing: 0.0,
                    ),
                maxLines: widget.maxLines,
                keyboardType: TextInputType.multiline,
                validator: widget.validator,
              ),
            ),

            // Botón enviar
            FlutterFlowIconButton(
              borderRadius: widget.borderRadius,
              buttonSize: widget.buttonSize,
              fillColor: widget.sendButtonColor,
              icon: Icon(
                Icons.send,
                color: Colors.white,
                size: 20,
              ),
              onPressed: _handleSend,
            ),
          ].divide(const SizedBox(width: 12)),
        ),
      ),
    );
  }
}
