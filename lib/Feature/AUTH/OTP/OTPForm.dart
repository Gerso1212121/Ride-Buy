import 'package:ezride/Feature/AUTH/Auht_Model/Auth_Model.dart';
import 'package:ezride/Feature/AUTH/widget/Auth_CustomButton_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_animations.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class OTPForm extends StatefulWidget {
  final AuthModel model;
  final Map<String, AnimationInfo> animationsMap;
  final BuildContext parentContext;
  final Function(String otp) onVerifyPressed; // ← cambia aquí
  final VoidCallback onResendCodePressed;
  final VoidCallback onBackToLoginPressed;

  const OTPForm({
    super.key,
    required this.model,
    required this.animationsMap,
    required this.parentContext,
    required this.onVerifyPressed,
    required this.onResendCodePressed,
    required this.onBackToLoginPressed,
  });

  @override
  State<OTPForm> createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  final TextEditingController _otpController = TextEditingController();
  final FocusNode _otpFocusNode = FocusNode();

  @override
  void dispose() {
    _otpController.dispose();
    _otpFocusNode.dispose();
    super.dispose();
  }

  bool get _isOTPValid => _otpController.text.length == 6;

  void _clearOTP() {
    _otpController.clear();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: widget.model.otpFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context, 'Verifica tu identidad'),
              _buildSubtitle(context),
              const SizedBox(height: 24.0),

              // OTP Input Fields
              _buildOTPInputs(context),

              const SizedBox(height: 32.0),

              // Botón de verificación
              CustomButton(
                text: 'Verificar Código',
                onPressed: () {
                  if (_isOTPValid) {
                    widget.onVerifyPressed(_otpController.text); // ✅ envía OTP real
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Por favor ingresa el código completo de 6 dígitos'),
                        backgroundColor: FlutterFlowTheme.of(context).error,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 16.0),
              _buildAdditionalLinks(context),
            ],
          ).animateOnPageLoad(
            widget.animationsMap['columnOnPageLoadAnimation2'] ??
                AnimationInfo(
                  trigger: AnimationTrigger.onPageLoad,
                  effectsBuilder: () => [FadeEffect(duration: 300.ms)],
                ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 12, 0, 8),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).headlineSmall.override(
              font: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontStyle: FlutterFlowTheme.of(context).headlineSmall.fontStyle,
              ),
            ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 16),
      child: Text(
        'Hemos enviado un código de verificación de 6 dígitos a tu correo electrónico.',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lato(
                fontWeight: FontWeight.normal,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).secondaryText,
            ),
      ),
    );
  }

Widget _buildOTPInputs(BuildContext context) {
  return GestureDetector(
    onTap: () => FocusScope.of(context).requestFocus(_otpFocusNode),
    child: Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(6, (index) {
            final code = _otpController.text;
            final char = index < code.length ? code[index] : '';
            final activeIndex = code.length; // posición del siguiente dígito
            final isActive = index == activeIndex && code.length < 6;
            final isFilled = index < code.length;

            final borderColor = isActive || isFilled
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).alternate;

            final textColor = isFilled
                ? FlutterFlowTheme.of(context).primary
                : FlutterFlowTheme.of(context).primaryText;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 50,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: borderColor,
                  width: isActive ? 3.0 : 2.0,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: FlutterFlowTheme.of(context)
                              .primary
                              .withOpacity(0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: FlutterFlowTheme.of(context).bodyLarge.override(
                      fontFamily: 'Lato',
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                child: Text(char),
              ),
            );
          }),
        ),

        // Campo invisible que recibe el input
        Positioned.fill(
          child: Opacity(
            opacity: 0.01,
            child: TextField(
              autofocus: true,
              focusNode: _otpFocusNode,
              controller: _otpController,
              showCursor: false,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),
        ),
      ],
    ),
  );
}


  Widget _buildAdditionalLinks(BuildContext context) {
    return Column(
      children: [
        CustomButton(
          text: 'Reenviar código',
          onPressed: widget.onResendCodePressed,
          backgroundColor: Colors.white,
          textColor: FlutterFlowTheme.of(context).primary,
          elevation: 0,
          height: 44,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: widget.onBackToLoginPressed,
          child: Text(
            'Volver al inicio de sesión',
            textAlign: TextAlign.center,
            style: FlutterFlowTheme.of(context).labelMedium.override(
                  font: GoogleFonts.lato(
                    fontWeight: FontWeight.bold,
                    fontStyle:
                        FlutterFlowTheme.of(context).labelMedium.fontStyle,
                  ),
                  color: const Color(0xFF0022FF),
                ),
          ),
        ),
      ],
    );
  }
}
