import 'package:ezride/Feature/VERIFICACIONES/Error/widgets/Error_Auth.dart';
import 'package:go_router/go_router.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthError extends StatelessWidget {
  const AuthError({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PantallaErrorVerificacionWidget(
        onReintentarPressed: () {
          GoRouter.of(context).go('/auth'); // Aquí defines la ruta a la que quieres ir
        },
        onSolicitarLinkPressed: () {
          print('SOLICITAR NUEVO LINK AL CORREO');
        },
        title: 'Error en la verificación',
        description: 'No pudimos verificar tus datos. Revisa la información o solicita un nuevo link al correo.',
        reintentarText: 'Reintentar',
        solicitarLinkText: 'Solicitar nuevo link al correo',
      ),
    );
  }
}