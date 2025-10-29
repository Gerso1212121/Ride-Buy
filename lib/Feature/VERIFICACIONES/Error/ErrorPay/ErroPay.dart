import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Diseña una pantalla de pago rechazado en una app de alquiler de autos.
///
/// Arriba un AppBar transparente con flecha de retroceso y texto centrado
/// “Pago Fallido”. Debajo, un mensaje principal claro y llamativo indicando
/// que la transacción no se pudo completar, acompañado de un ícono de alerta
/// o error (por ejemplo, un círculo rojo con una X). Incluye una explicación
/// breve de posibles motivos (saldo insuficiente, tarjeta inválida, etc.) en
/// tipografía legible y colores suaves. Agrega un botón principal en rojo o
/// gris que diga “Intentar de nuevo”, y un botón secundario en texto para
/// volver al inicio. Mantén un diseño limpio, moderno, minimalista, con
/// jerarquía visual clara y uso de iconografía intuitiva para alertar al
/// usuario. La pantalla debe transmitir seguridad y claridad sobre el estado
/// de la transacción.
class RechazoWidget extends StatefulWidget {
  const RechazoWidget({super.key});

  static String routeName = 'RECHAZO';
  static String routePath = '/rechazo';

  @override
  State<RechazoWidget> createState() => _RechazoWidgetState();
}

class _RechazoWidgetState extends State<RechazoWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: responsiveVisibility(
          context: context,
          tabletLandscape: false,
          desktop: false,
        )
            ? AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                leading: FlutterFlowIconButton(
                  borderColor: Colors.transparent,
                  borderRadius: 20,
                  borderWidth: 1,
                  buttonSize: 40,
                  icon: Icon(
                    Icons.arrow_back_rounded,
                    color: FlutterFlowTheme.of(context).primaryText,
                    size: 24,
                  ),
                  onPressed: () {
                    print('IconButton pressed ...');
                  },
                ),
                title: Text(
                  'Pago Fallido',
                  style: FlutterFlowTheme.of(context).titleLarge.override(
                        font: GoogleFonts.outfit(
                          fontWeight: FontWeight.w600,
                          fontStyle:
                              FlutterFlowTheme.of(context).titleLarge.fontStyle,
                        ),
                        color: FlutterFlowTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w600,
                        fontStyle:
                            FlutterFlowTheme.of(context).titleLarge.fontStyle,
                      ),
                ),
                actions: const [],
                centerTitle: true,
                elevation: 0,
              )
            : null,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24, 40, 24, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFF4444),
                          shape: BoxShape.circle,
                        ),
                        child: const Align(
                          alignment: AlignmentDirectional(0, 0),
                          child: Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            'Pago Rechazado',
                            textAlign: TextAlign.center,
                            style: FlutterFlowTheme.of(context)
                                .headlineMedium
                                .override(
                                  font: GoogleFonts.outfit(
                                    fontWeight: FontWeight.bold,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .headlineMedium
                                        .fontStyle,
                                  ),
                                  color:
                                      FlutterFlowTheme.of(context).primaryText,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.bold,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .headlineMedium
                                      .fontStyle,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16, 0, 16, 0),
                            child: Text(
                              'No pudimos procesar tu transacción',
                              textAlign: TextAlign.center,
                              style: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .override(
                                    font: GoogleFonts.figtree(
                                      fontWeight: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .bodyLarge
                                          .fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context)
                                        .secondaryText,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .bodyLarge
                                        .fontStyle,
                                    lineHeight: 1.4,
                                  ),
                            ),
                          ),
                        ].divide(const SizedBox(height: 16)),
                      ),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            children: [
                              Text(
                                'Posibles motivos:',
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      font: GoogleFonts.figtree(
                                        fontWeight: FontWeight.w600,
                                        fontStyle: FlutterFlowTheme.of(context)
                                            .titleMedium
                                            .fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context)
                                          .primaryText,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                      fontStyle: FlutterFlowTheme.of(context)
                                          .titleMedium
                                          .fontStyle,
                                    ),
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 2, 0, 0),
                                        child: Icon(
                                          Icons.circle,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Saldo insuficiente en tu tarjeta',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.figtree(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 12)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 2, 0, 0),
                                        child: Icon(
                                          Icons.circle,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Datos de tarjeta incorrectos',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.figtree(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 12)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 2, 0, 0),
                                        child: Icon(
                                          Icons.circle,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Tarjeta vencida o bloqueada',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.figtree(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 12)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 2, 0, 0),
                                        child: Icon(
                                          Icons.circle,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Problema temporal del banco',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.figtree(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 12)),
                                  ),
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0, 2, 0, 0),
                                        child: Icon(
                                          Icons.circle,
                                          color: FlutterFlowTheme.of(context)
                                              .secondaryText,
                                          size: 20,
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          'Link de pago vencido',
                                          style: FlutterFlowTheme.of(context)
                                              .bodyMedium
                                              .override(
                                                font: GoogleFonts.figtree(
                                                  fontWeight:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontWeight,
                                                  fontStyle:
                                                      FlutterFlowTheme.of(
                                                              context)
                                                          .bodyMedium
                                                          .fontStyle,
                                                ),
                                                color:
                                                    FlutterFlowTheme.of(context)
                                                        .secondaryText,
                                                letterSpacing: 0.0,
                                                fontWeight:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontWeight,
                                                fontStyle:
                                                    FlutterFlowTheme.of(context)
                                                        .bodyMedium
                                                        .fontStyle,
                                                lineHeight: 1.4,
                                              ),
                                        ),
                                      ),
                                    ].divide(const SizedBox(width: 12)),
                                  ),
                                ].divide(const SizedBox(height: 12)),
                              ),
                            ].divide(const SizedBox(height: 16)),
                          ),
                        ),
                      ),
                    ].divide(const SizedBox(height: 32)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 24, 32),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    FFButtonWidget(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      text: 'Intentar de nuevo',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 56,
                        padding: const EdgeInsets.all(8),
                        iconPadding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: const Color(0xFFFF4444),
                        textStyle:
                            FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.figtree(
                                    fontWeight: FontWeight.w600,
                                    fontStyle: FlutterFlowTheme.of(context)
                                        .titleMedium
                                        .fontStyle,
                                  ),
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                  fontStyle: FlutterFlowTheme.of(context)
                                      .titleMedium
                                      .fontStyle,
                                ),
                        elevation: 0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    FFButtonWidget(
                      onPressed: () {
                        print('Button pressed ...');
                      },
                      text: 'Volver al inicio',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 48,
                        padding: const EdgeInsets.all(8),
                        iconPadding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: Colors.transparent,
                        textStyle: FlutterFlowTheme.of(context)
                            .bodyLarge
                            .override(
                              font: GoogleFonts.figtree(
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyLarge
                                    .fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).secondaryText,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context)
                                  .bodyLarge
                                  .fontStyle,
                            ),
                        elevation: 0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ].divide(const SizedBox(height: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
