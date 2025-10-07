import 'package:ezride/Feature/AUTH/widget/Auth_CustomButton_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SocialAuthButtons extends StatelessWidget {
  final VoidCallback onGoogleAuthPressed; // ✅ Nuevo callback

  const SocialAuthButtons({
    super.key,
    required this.onGoogleAuthPressed, // ✅ Recibir callback
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
        child: Wrap(
          spacing: 16.0,
          runSpacing: 0.0,
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            CustomButton(
              text: 'Continuar con Google',
              icon: FaIcon(FontAwesomeIcons.google, size: 20.0),
              onPressed: onGoogleAuthPressed, // ✅ Usar callback recibido
              backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
              textColor: FlutterFlowTheme.of(context).bodyMedium.color,
              borderColor: FlutterFlowTheme.of(context).alternate,
              elevation: 0.0,
              height: 44.0,
              isSocial: true,
            ),
          ],
        ),
      ),
    );
  }
}