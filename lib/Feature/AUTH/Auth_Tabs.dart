import 'package:ezride/Feature/AUTH/Auth_LoginForm.dart';
import 'package:ezride/Feature/AUTH/Auth_Registerform.dart';
import 'package:ezride/Feature/AUTH/controller/Auth_controller.dart';
import 'package:ezride/flutter_flow/flutter_flow_animations.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthTabs extends StatelessWidget {
  final AuthModel model;
  final Map<String, AnimationInfo> animationsMap;
  final BuildContext parentContext;
  
  // ✅ Callbacks para LoginForm
  final VoidCallback onSignInPressed;
  final VoidCallback onForgotPasswordPressed;
  final VoidCallback onRegisterLinkPressed;
  final VoidCallback onGoogleAuthLoginPressed;
  
  // ✅ Callbacks para RegisterForm
  final VoidCallback onRegisterPressed;
  final VoidCallback onLoginLinkPressed;
  final VoidCallback onGoogleAuthRegisterPressed;

  const AuthTabs({
    super.key,
    required this.model,
    required this.animationsMap,
    required this.parentContext,
    // ✅ Recibir todos los callbacks
    required this.onSignInPressed,
    required this.onForgotPasswordPressed,
    required this.onRegisterLinkPressed,
    required this.onGoogleAuthLoginPressed,
    required this.onRegisterPressed,
    required this.onLoginLinkPressed,
    required this.onGoogleAuthRegisterPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 700.0,
      constraints: BoxConstraints(maxWidth: 602.0),
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
        child: Column(
          children: [
            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: model.tabBarController,
                children: [
                  LoginForm(
                    model: model, 
                    animationsMap: animationsMap,
                    parentContext: parentContext,
                    // ✅ Pasar todos los callbacks requeridos
                    onSignInPressed: onSignInPressed,
                    onForgotPasswordPressed: onForgotPasswordPressed,
                    onRegisterLinkPressed: onRegisterLinkPressed,
                    onGoogleAuthPressed: onGoogleAuthLoginPressed,
                  ),
                  RegisterForm(
                    model: model, 
                    animationsMap: animationsMap,
                    parentContext: parentContext,
                    // ✅ Pasar todos los callbacks requeridos
                    onRegisterPressed: onRegisterPressed,
                    onLoginLinkPressed: onLoginLinkPressed,
                    onGoogleAuthPressed: onGoogleAuthRegisterPressed,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Align(
      alignment: Alignment(-1.0, 0),
      child: TabBar(
        isScrollable: true,
        labelColor: FlutterFlowTheme.of(context).primaryText,
        unselectedLabelColor: FlutterFlowTheme.of(context).secondaryText,
        labelPadding: EdgeInsets.all(16.0),
        labelStyle: FlutterFlowTheme.of(context).displaySmall.override(
              font: GoogleFonts.lato(
                fontWeight: FlutterFlowTheme.of(context).displaySmall.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).displaySmall.fontStyle,
              ),
              letterSpacing: 0.0,
            ),
        unselectedLabelStyle: FlutterFlowTheme.of(context).displaySmall.override(
              font: GoogleFonts.lato(
                fontWeight: FontWeight.normal,
                fontStyle: FlutterFlowTheme.of(context).displaySmall.fontStyle,
              ),
              letterSpacing: 0.0,
            ),
        indicatorColor: FlutterFlowTheme.of(context).primary,
        indicatorWeight: 4.0,
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 16.0, 12.0),
        tabs: [
          Tab(text: 'Inicio Sesión'),
          Tab(text: 'Registro'),
        ],
        controller: model.tabBarController,
      ),
    );
  }
}