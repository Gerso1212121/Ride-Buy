import 'package:ezride/App/DATA/repositories/EmpresaRepository_data.dart';
import 'package:ezride/App/DOMAIN/usecases/RegistrarEmpresa_UseCase.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Feature/Form_Empresa/FORM_MODELO.dart';
import 'package:ezride/Feature/AUTH/widget/Auth_CustomButton_widget.dart';
import 'package:ezride/Routers/router/MainComplete.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FormularioEmpresaWidget extends StatefulWidget {
  const FormularioEmpresaWidget({super.key});

  @override
  State<FormularioEmpresaWidget> createState() =>
      _FormularioEmpresaWidgetState();
}

class _FormularioEmpresaWidgetState extends State<FormularioEmpresaWidget> {
  late FormularioEmpresaModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _nrcController = TextEditingController();
  final FocusNode _nrcFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => FormularioEmpresaModel());

    _model.textController1 ??= TextEditingController();
    _model.textController2 ??= TextEditingController();
    _model.textController3 ??= TextEditingController();
    _model.textController5 ??= TextEditingController();
    _model.textController6 ??= TextEditingController();

    _model.textFieldFocusNode1 ??= FocusNode();
    _model.textFieldFocusNode2 ??= FocusNode();
    _model.textFieldFocusNode3 ??= FocusNode();
    _model.textFieldFocusNode5 ??= FocusNode();
    _model.textFieldFocusNode6 ??= FocusNode();
  }

  @override
  void dispose() {
    _model.dispose();
    _nrcController.dispose();
    _nrcFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _registrarEmpresa() async {
    if (_model.textController1!.text.isEmpty ||
        _model.textController2!.text.isEmpty ||
        _nrcController.text.isEmpty ||
        _model.textController3!.text.isEmpty ||
        _model.textController5!.text.isEmpty) {
      _alert("Error", "Complete todos los campos obligatorios");
      return;
    }

    try {
      // 🧩 Crear repositorio y caso de uso
      final repo = EmpresarepositoryData();
      final useCase = RegistrarEmpresaUseCase(repo);

      // 🪪 Obtener usuario actual
      final profile = await SessionManager.loadSession();
      if (profile == null) {
        _alert("Error", "No se encontró la sesión del usuario.");
        return;
      }

      // 🚀 Ejecutar flujo de registro
      final empresa = await useCase.execute(
        ownerId: profile.id,
        nombre: _model.textController1!.text.trim(),
        nit: _model.textController2!.text.trim(),
        nrc: _nrcController.text.trim(),
        direccion: _model.textController3!.text.trim(),
        telefono: _model.textController5!.text.trim(),
        email: _model.textController6!.text.trim(),
      );

      // 🔄 Actualizar localmente el perfil
      await SessionManager.updateProfile();

      // ✅ Mostrar alerta y redirigir
      _alert("Éxito", "Empresa registrada: ${empresa.nombre}", onOk: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      });
    } catch (e) {
      _alert("Error", "No se pudo registrar la empresa.\n$e");
    }
  }

  void _alert(String title, String msg, {VoidCallback? onOk}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onOk != null) onOk();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
            font: GoogleFonts.lato(),
            letterSpacing: 0.0,
          ),
      prefixIcon: Icon(icon, color: FlutterFlowTheme.of(context).secondaryText),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).primary,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(40.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: FlutterFlowTheme.of(context).primary,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(40.0),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(20.0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Registrar Empresa",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Subtitle
              Text(
                "Ingresa los datos de tu empresa para continuar",
                style: theme.bodyMedium.override(
                  font: GoogleFonts.lato(),
                  color: theme.secondaryText,
                ),
              ),

              const SizedBox(height: 20),

              // Inputs
              TextFormField(
                controller: _model.textController1,
                focusNode: _model.textFieldFocusNode1,
                decoration: _inputStyle("Nombre de la Empresa", Icons.business),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _model.textController2,
                focusNode: _model.textFieldFocusNode2,
                decoration: _inputStyle("NIT", Icons.assignment),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _nrcController,
                focusNode: _nrcFocusNode,
                decoration: _inputStyle("NRC", Icons.badge),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _model.textController3,
                focusNode: _model.textFieldFocusNode3,
                decoration: _inputStyle("Dirección", Icons.location_on),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _model.textController5,
                focusNode: _model.textFieldFocusNode5,
                keyboardType: TextInputType.phone,
                decoration: _inputStyle("Teléfono", Icons.phone),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _model.textController6,
                focusNode: _model.textFieldFocusNode6,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputStyle("Email (opcional)", Icons.email),
              ),

              const SizedBox(height: 35),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: CustomButton(
                  text: "Guardar",
                  onPressed: _registrarEmpresa,
                ),
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: CustomButton(
                  text: "Cancelar",
                  backgroundColor: Colors.white,
                  textColor: theme.primaryText,
                  elevation: 0,
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
