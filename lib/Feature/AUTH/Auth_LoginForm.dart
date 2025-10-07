import 'dart:ui';
import 'package:ezride/Feature/AUTH/controller/Auth_controller.dart';
import 'package:ezride/Feature/AUTH/widget/Auth_CustomButton_widget.dart';
import 'package:ezride/Feature/AUTH/widget/Auth_CustomTextField_widget.dart';
import 'package:ezride/Feature/AUTH/widget/Auth_SocialButton_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_animations.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class LoginForm extends StatefulWidget {
  final AuthModel model;
  final Map<String, AnimationInfo> animationsMap;
  final BuildContext parentContext;
  final VoidCallback onSignInPressed;
  final VoidCallback onForgotPasswordPressed;
  final VoidCallback onRegisterLinkPressed;
  final VoidCallback onGoogleAuthPressed;

  const LoginForm({
    super.key,
    required this.model,
    required this.animationsMap,
    required this.parentContext,
    required this.onSignInPressed,
    required this.onForgotPasswordPressed,
    required this.onRegisterLinkPressed,
    required this.onGoogleAuthPressed,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;

  @override
  void initState() {
    super.initState();

    // Validación en tiempo real
    widget.model.emailAddressTextController.addListener(_validateRealTime);
    widget.model.passwordTextController.addListener(_validateRealTime);
  }

  void _validateRealTime() {
    if (mounted) {
      setState(() {
        _isEmailValid = _validateEmail(widget.model.emailAddressTextController.text);
        _isPasswordValid = _validatePassword(widget.model.passwordTextController.text);
      });
    }
  }

  bool _validateEmail(String value) {
    if (value.isEmpty) return true; // No mostrar error si está vacío
    
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(value);
  }

  bool _validatePassword(String value) {
    if (value.isEmpty) return true; // No mostrar error si está vacío
    
    return value.length >= 6;
  }

  Color _getEmailBorderColor(BuildContext context) {
    final text = widget.model.emailAddressTextController.text;
    
    if (text.isEmpty) {
      return FlutterFlowTheme.of(context).alternate; // Color normal cuando está vacío
    }
    
    return _isEmailValid 
        ? FlutterFlowTheme.of(context).primary // Verde/azul cuando es válido
        : FlutterFlowTheme.of(context).error;  // Rojo cuando es inválido
  }

  Color _getPasswordBorderColor(BuildContext context) {
    final text = widget.model.passwordTextController.text;
    
    if (text.isEmpty) {
      return FlutterFlowTheme.of(context).alternate; // Color normal cuando está vacío
    }
    
    return _isPasswordValid 
        ? FlutterFlowTheme.of(context).primary // Verde/azul cuando es válido
        : FlutterFlowTheme.of(context).error;  // Rojo cuando es inválido
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context, 'Comienza una nueva aventura!'),

              // Email
              CustomTextField(
                controller: widget.model.emailAddressTextController,
                focusNode: widget.model.emailAddressFocusNode,
                label: 'Email',
                autofillHints: const [AutofillHints.email],
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa tu correo';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return 'Correo inválido';
                  return null;
                },
                borderColor: _getEmailBorderColor(context),
                focusedBorderColor: _getEmailBorderColor(context),
              ),

              // Password
              CustomTextField(
                controller: widget.model.passwordTextController,
                focusNode: widget.model.passwordFocusNode,
                label: 'Password',
                autofillHints: const [AutofillHints.password],
                isPassword: true,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                  if (value.length < 6) return 'Esta contraseña ya existe. Intenta con otra.';
                  return null;
                },
                borderColor: _getPasswordBorderColor(context),
                focusedBorderColor: _getPasswordBorderColor(context),
              ),

              // Botón Sign In
              CustomButton(
                text: 'Sign In',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onSignInPressed();
                  } else {
                    // Forzar validación si falla
                    _validateRealTime();
                  }
                },
              ),

              _buildForgotPassword(context),
              _buildSocialAuth(context),
            ],
          ).animateOnPageLoad(
            widget.animationsMap['columnOnPageLoadAnimation1'] ??
                AnimationInfo(
                  trigger: AnimationTrigger.onPageLoad,
                  effectsBuilder: () => [FadeEffect(duration: 300.ms)],
                ),
          ),
        ),
      ),
    );
  }

  // ... (los demás métodos _buildTitle, _buildForgotPassword, _buildSocialAuth se mantienen igual)
  Widget _buildTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 24.0),
      child: Text(
        text,
        style: FlutterFlowTheme.of(context).labelMedium.override(
              font: GoogleFonts.lato(
                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
              ),
              letterSpacing: 0.0,
            ),
      ),
    );
  }

  Widget _buildForgotPassword(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
        child: CustomButton(
          text: '¿Olvidaste tu contraseña?',
          onPressed: widget.onForgotPasswordPressed,
          backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
          textColor: FlutterFlowTheme.of(context).bodyMedium.color,
          elevation: 0.0,
          height: 44.0,
        ),
      ),
    );
  }

  Widget _buildSocialAuth(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Align(
          alignment: const AlignmentDirectional(0.0, 0.0),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 24.0),
            child: GestureDetector(
              onTap: widget.onRegisterLinkPressed,
              child: Text(
                'O registrate aqui',
                textAlign: TextAlign.center,
                style: FlutterFlowTheme.of(context).labelMedium.override(
                      font: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                      ),
                      color: const Color(0xFF0022FF),
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ),
        ),
        SocialAuthButtons(
          onGoogleAuthPressed: widget.onGoogleAuthPressed,
        ),
      ],
    );
  }
}