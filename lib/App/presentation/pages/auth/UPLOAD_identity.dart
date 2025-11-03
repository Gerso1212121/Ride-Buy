import 'package:ezride/Feature/AUTH/widget/Auth_CustomButton_widget.dart';
import 'package:ezride/flutter_flow/flutter_flow_animations.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class PersonalDataForm extends StatefulWidget {
  final void Function(String phone) onSavePressed;
  final VoidCallback onCancelPressed;
  final String? fullName;
  final String? duiNumber;
  final String? dateOfBirth;
  final Map<String, AnimationInfo> animationsMap;
  final BuildContext parentContext;

  const PersonalDataForm({
    super.key,
    required this.onSavePressed,
    required this.onCancelPressed,
    required this.animationsMap,
    required this.parentContext,
    this.fullName,
    this.duiNumber,
    this.dateOfBirth,
  });

  @override
  State<PersonalDataForm> createState() => _PersonalDataFormState();
}

class _PersonalDataFormState extends State<PersonalDataForm> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  final _phoneFocusNode = FocusNode();

  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _duiController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  bool _isPhoneValid = true;
  bool _isPhoneFilled = false;

  @override
  void initState() {
    super.initState();

    _fullNameController.text = widget.fullName ?? "";
    _duiController.text = widget.duiNumber ?? "";

    if (widget.dateOfBirth != null) {
      try {
        final d = DateTime.parse(widget.dateOfBirth!);
        _birthDateController.text = DateFormat('dd/MM/yyyy').format(d);
      } catch (_) {
        _birthDateController.text = widget.dateOfBirth!;
      }
    }

    _phoneController.addListener(_validatePhone);

    // Agregar listener al focus node del teléfono para desplazar cuando se enfoque
    _phoneFocusNode.addListener(() {
      if (_phoneFocusNode.hasFocus) {
        // Esperar un poco para que el teclado aparezca y luego desplazar
        Future.delayed(const Duration(milliseconds: 300), () {
          _scrollToPhoneField();
        });
      }
    });
  }

  void _scrollToPhoneField() {
    // Desplazar hasta el campo de teléfono
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _validatePhone() {
    if (mounted) {
      setState(() {
        final digits = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
        _isPhoneValid = digits.length >= 8;
        _isPhoneFilled = _phoneController.text.isNotEmpty;
      });
    }
  }

  Color _getPhoneBorderColor(BuildContext context) {
    final text = _phoneController.text;

    if (text.isEmpty) {
      return FlutterFlowTheme.of(context).error; // ROJO cuando está vacío
    }

    return _isPhoneValid
        ? FlutterFlowTheme.of(context).primary // AZUL cuando es válido
        : FlutterFlowTheme.of(context).error; // ROJO cuando es inválido
  }

  Color _getReadOnlyBorderColor(BuildContext context) {
    return FlutterFlowTheme.of(context).primary; // AZUL para campos llenos
  }

  // Validadores para los campos
  String? _readOnlyValidator(String? value) {
    return null; // No hay validación para campos de solo lectura
  }

  String? _phoneValidator(String? value) {
    if (value == null || value.isEmpty) return 'Ingresa tu teléfono';
    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
    if (digits.length < 8) return 'Teléfono inválido';
    return null;
  }

  InputDecoration _buildInputDecoration(String label,
      {IconData? icon, bool readOnly = false, bool isPhone = false}) {
    final borderColor = readOnly
        ? _getReadOnlyBorderColor(context) // AZUL para campos llenos
        : isPhone
            ? _getPhoneBorderColor(context) // Dinámico para teléfono
            : FlutterFlowTheme.of(context).error; // ROJO para teléfono vacío

    return InputDecoration(
      labelText: label,
      labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
            font: GoogleFonts.lato(
              fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
              fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
            ),
            letterSpacing: 0.0,
          ),
      prefixIcon: icon != null
          ? Icon(
              icon,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 24.0,
            )
          : null,
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: borderColor,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(40.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: borderColor,
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
      fillColor: Colors.white, // FONDO BLANCO
      contentPadding: const EdgeInsets.all(24.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0, // ✅ sin sombra
        scrolledUnderElevation:
            0, // ✅ evita sombra al hacer scroll (Flutter 3.x+)
        surfaceTintColor: Colors.transparent, // ✅ evita overlay gris Material 3
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: widget.onCancelPressed, // 🔙 regresar
        ),
        title: Text(
          "Completar tus datos",
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Container(
        color: Colors.white, // ✅ fondo blanco
        child: Align(
          alignment: const AlignmentDirectional(0.0, 0.0),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👇 deja solo el subtítulo porque el título ya está en el AppBar
                    _buildSubtitle(context),

                    // Full Name (readonly)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _fullNameController,
                        focusNode: FocusNode(skipTraversal: true),
                        readOnly: true,
                        validator: _readOnlyValidator,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lato(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                            ),
                        decoration: _buildInputDecoration(
                          'Nombre Completo',
                          icon: Icons.person,
                          readOnly: true,
                        ),
                      ),
                    ),

                    // DUI (readonly)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _duiController,
                        focusNode: FocusNode(skipTraversal: true),
                        readOnly: true,
                        validator: _readOnlyValidator,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lato(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                            ),
                        decoration: _buildInputDecoration(
                          'DUI',
                          icon: Icons.badge,
                          readOnly: true,
                        ),
                      ),
                    ),

                    // Fecha nacimiento (readonly)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _birthDateController,
                        focusNode: FocusNode(skipTraversal: true),
                        readOnly: true,
                        validator: _readOnlyValidator,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lato(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                            ),
                        decoration: _buildInputDecoration(
                          'Fecha de nacimiento',
                          icon: Icons.cake,
                          readOnly: true,
                        ),
                      ),
                    ),

                    // Teléfono (editable)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: TextFormField(
                        controller: _phoneController,
                        focusNode: _phoneFocusNode,
                        keyboardType: TextInputType.phone,
                        validator: _phoneValidator,
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lato(
                                fontWeight: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontWeight,
                                fontStyle: FlutterFlowTheme.of(context)
                                    .bodyMedium
                                    .fontStyle,
                              ),
                              letterSpacing: 0.0,
                            ),
                        decoration: _buildInputDecoration(
                          'Teléfono',
                          icon: Icons.phone,
                          isPhone: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20.0),

                    // Botones
                    _buildActionButtons(context),

                    const SizedBox(height: 100.0),
                  ],
                ).animateOnPageLoad(
                  widget.animationsMap['columnOnPageLoadAnimation'] ??
                      AnimationInfo(
                        trigger: AnimationTrigger.onPageLoad,
                        effectsBuilder: () => [
                          FadeEffect(duration: 300.ms),
                        ],
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 24.0),
      child: Text(
        'Verifica y completa tu información personal para continuar',
        style: FlutterFlowTheme.of(context).bodyMedium.override(
              font: GoogleFonts.lato(
                fontWeight: FontWeight.normal,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
              ),
              color: FlutterFlowTheme.of(context).secondaryText,
              letterSpacing: 0.0,
            ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          height: 56, // altura más grande
          width: double.infinity, // ✅ ocupa el ancho completo disponible
          child: CustomButton(
            text: 'Guardar',
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                widget.onSavePressed(
                  _phoneController.text.trim(),
                );
              } else {
                _validatePhone();
              }
            },
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          width: double.infinity, // ✅ igual para botón cancelar
          child: CustomButton(
            text: 'Cancelar',
            onPressed: widget.onCancelPressed,
            backgroundColor: Colors.white,
            textColor: FlutterFlowTheme.of(context).primaryText,
            elevation: 0,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _duiController.dispose();
    _phoneController.dispose();
    _birthDateController.dispose();
    _phoneFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
