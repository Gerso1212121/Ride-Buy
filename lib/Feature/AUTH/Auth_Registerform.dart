import 'package:ezride/Feature/AUTH/Auht_Model/Auth_Model.dart';
import 'package:ezride/Feature/AUTH/widget/Auth_CustomButton_widget.dart';
import 'package:ezride/Feature/AUTH/widget/Auth_CustomTextField_widget.dart';
import 'package:ezride/Feature/AUTH/widget/Auth_SocialButton_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_animations.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class RegisterForm extends StatefulWidget {
  final AuthModel model;
  final Map<String, AnimationInfo> animationsMap;
  final BuildContext parentContext;
  final VoidCallback onRegisterPressed;
  final VoidCallback onLoginLinkPressed;
  final VoidCallback onGoogleAuthPressed;

  const RegisterForm({
    super.key,
    required this.model,
    required this.animationsMap,
    required this.parentContext,
    required this.onRegisterPressed,
    required this.onLoginLinkPressed,
    required this.onGoogleAuthPressed,
  });

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();

  bool _isEmailValid = true;
  bool _isPasswordValid = true;
  bool _isConfirmPasswordValid = true;

  @override
  void initState() {
    super.initState();

    // Validación en tiempo real unificada
    widget.model.emailAddressCreateTextController.addListener(_validateRealTime);
    widget.model.passwordCreateTextController.addListener(_validateRealTime);
    widget.model.passwordConfirmTextController.addListener(_validateRealTime);
  }

  void _validateRealTime() {
    if (mounted) {
      setState(() {
        _isEmailValid = _validateEmail(widget.model.emailAddressCreateTextController.text);
        _isPasswordValid = _validatePassword(widget.model.passwordCreateTextController.text);
        _isConfirmPasswordValid = _validateConfirmPassword(
          widget.model.passwordCreateTextController.text,
          widget.model.passwordConfirmTextController.text
        );
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

  bool _validateConfirmPassword(String password, String confirmPassword) {
    if (confirmPassword.isEmpty) return true; // No mostrar error si está vacío
    
    return password == confirmPassword;
  }

  Color _getEmailBorderColor(BuildContext context) {
    final text = widget.model.emailAddressCreateTextController.text;
    
    if (text.isEmpty) {
      return FlutterFlowTheme.of(context).alternate; // Color normal cuando está vacío
    }
    
    return _isEmailValid 
        ? FlutterFlowTheme.of(context).primary // Verde/azul cuando es válido
        : FlutterFlowTheme.of(context).error;  // Rojo cuando es inválido
  }

  Color _getPasswordBorderColor(BuildContext context) {
    final text = widget.model.passwordCreateTextController.text;
    
    if (text.isEmpty) {
      return FlutterFlowTheme.of(context).alternate; // Color normal cuando está vacío
    }
    
    return _isPasswordValid 
        ? FlutterFlowTheme.of(context).primary // Verde/azul cuando es válido
        : FlutterFlowTheme.of(context).error;  // Rojo cuando es inválido
  }

  Color _getConfirmPasswordBorderColor(BuildContext context) {
    final text = widget.model.passwordConfirmTextController.text;
    
    if (text.isEmpty) {
      return FlutterFlowTheme.of(context).alternate; // Color normal cuando está vacío
    }
    
    return _isConfirmPasswordValid 
        ? FlutterFlowTheme.of(context).primary // Verde/azul cuando es válido
        : FlutterFlowTheme.of(context).error;  // Rojo cuando es inválido
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Align(
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 12.0, 12.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitle(context, 'Registrate para comenzar tu aventura!'),

              // Email
              CustomTextField(
                controller: widget.model.emailAddressCreateTextController,
                focusNode: widget.model.emailAddressCreateFocusNode,
                label: 'Email',
                keyboardType: TextInputType.emailAddress,
                borderColor: _getEmailBorderColor(context),
                focusedBorderColor: _getEmailBorderColor(context),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa tu correo';
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) return 'Correo inválido';
                  return null;
                },
              ),

              // Password
              CustomTextField(
                controller: widget.model.passwordCreateTextController,
                focusNode: widget.model.passwordCreateFocusNode,
                label: 'Password',
                isPassword: true,
                borderColor: _getPasswordBorderColor(context),
                focusedBorderColor: _getPasswordBorderColor(context),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa tu contraseña';
                  if (value.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),

              // Confirm Password
              CustomTextField(
                controller: widget.model.passwordConfirmTextController,
                focusNode: widget.model.passwordConfirmFocusNode,
                label: 'Confirmar Password',
                isPassword: true,
                borderColor: _getConfirmPasswordBorderColor(context),
                focusedBorderColor: _getConfirmPasswordBorderColor(context),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Confirma tu contraseña';
                  if (value != widget.model.passwordCreateTextController.text)
                    return 'Las contraseñas no coinciden';
                  return null;
                },
              ),

              CustomButton(
                text: 'Crear Cuenta',
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    widget.onRegisterPressed();
                  } else {
                    // Forzar validación si falla
                    _validateRealTime();
                  }
                },
              ),

              _buildLoginLink(context),

              SocialAuthButtons(
                onGoogleAuthPressed: widget.onGoogleAuthPressed,
              ),
            ],
          ).animateOnPageLoad(widget.animationsMap['columnOnPageLoadAnimation1'] ??
              AnimationInfo(
                trigger: AnimationTrigger.onPageLoad,
                effectsBuilder: () => [FadeEffect(duration: 300.ms)],
              )),
        ),
      ),
    );
  }

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

  Widget _buildLoginLink(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '¿Ya tienes cuenta? ',
              style: FlutterFlowTheme.of(context).labelMedium.override(
                    font: GoogleFonts.lato(
                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                    ),
                    color: const Color(0xFF2E4754),
                    letterSpacing: 0.0,
                  ),
            ),
            GestureDetector(
              onTap: widget.onLoginLinkPressed,
              child: Text(
                'Inicia aqui',
                style: FlutterFlowTheme.of(context).bodySmall.override(
                      font: GoogleFonts.lato(
                        fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                        fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                      ),
                      color: const Color(0xFF004CFF),
                      letterSpacing: 0.0,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}