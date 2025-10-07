import 'package:ezride/Feature/VERIFICACIONES/Coverage/widgets/Coverage_Complete.dart';
import 'package:go_router/go_router.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class AuthComplete extends StatelessWidget {
  const AuthComplete({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: VerificacionCompletaWidget(
        onContinuePressed: () {
          // Reemplaza la ruta actual y evita "pop" que deje pantalla negra
          GoRouter.of(context).go('/main'); // Aquí defines la ruta a la que quieres ir
        },
        title: '¡Verificación completada!',
        description: 'Tu cuenta ha sido verificada exitosamente. Ya puedes disfrutar de nuestros servicios de renta de autos.',
        buttonText: 'Continuar',
      ),
    );
  }
}
