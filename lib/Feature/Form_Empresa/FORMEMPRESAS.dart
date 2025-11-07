import 'package:ezride/App/DATA/repositories/EmpresaRepository_data.dart';
import 'package:flutter/material.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:ezride/App/DOMAIN/usecases/RegistrarEmpresa_UseCase.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Feature/Form_Empresa/FORM_MODELO.dart';
import 'package:ezride/Feature/AUTH/widget/Auth_CustomButton_widget.dart';
import 'package:ezride/Routers/router/MainComplete.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart'; // Agregar import para Geolocator
import 'package:geocoding/geocoding.dart'; // Agregar import para Geocoding

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

  // Variables para latitud y longitud
  double? latitude;
  double? longitude;

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

    // 👇 Llamar para obtener ubicación interna automáticamente
    _obtenerUbicacionActual();
  }

  @override
  void dispose() {
    _model.dispose();
    _nrcController.dispose();
    _nrcFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Función para obtener coordenadas (latitud y longitud) de la dirección ingresada por el usuario
  Future<void> _obtenerUbicacionActual() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Verifica si el GPS está habilitado
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _alert(
          "Ubicación desactivada", "Por favor, activa el GPS para continuar.");
      return;
    }

    // Verifica permisos
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _alert("Permiso denegado",
            "No se puede registrar sin habilitar la ubicación.");
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _alert("Permiso permanente denegado",
          "Activa los permisos de ubicación manualmente desde los ajustes.");
      return;
    }

    // Obtiene ubicación actual
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });

    print("📍 Ubicación tomada: Lat=$latitude, Lng=$longitude");
  }

void _registrarEmpresa() async {
  final profile = await SessionManager.loadSession();
  if (profile == null) {
    _alert("Error", "No se encontró la sesión del usuario.");
    return;
  }

  // Verificar si el usuario ya tiene una empresa registrada
  if (SessionManager.currentEmpresa != null) {
    _alert("Error", "Ya tienes una empresa registrada.");
    return;
  }

  try {
    // 🧩 Crear repositorio y caso de uso
    final repo = EmpresarepositoryData();
    final useCase = RegistrarEmpresaUseCase(repo);

    // 🚀 Ejecutar flujo de registro de la nueva empresa
    final empresa = await useCase.execute(
      ownerId: profile.id,
      nombre: _model.textController1!.text.trim(),
      nit: _model.textController2!.text.trim(),
      nrc: _nrcController.text.trim(),
      direccion: _model.textController3!.text.trim(),
      telefono: _model.textController5!.text.trim(),
      email: _model.textController6!.text.trim(),
      latitud: latitude!,
      longitud: longitude!,
    );

    // Actualizar el perfil con la empresa asociada
    await SessionManager.updateProfile(
      displayName: profile.displayName,
      phone: profile.phone,
      emailVerified: profile.emailVerified,
    );

    // Ahora también asignamos la empresa recién registrada al SessionManager
    SessionManager.currentEmpresa = empresa;

    // ✅ Mostrar alerta y redirigir
    if (mounted) {
      _alert("Éxito", "Empresa registrada: ${empresa.nombre}", onOk: () {
        // Redirige a la ruta principal
        context.go('/main');
      });
    }
  } catch (e) {
    if (mounted) {
      _alert("Error", "No se pudo registrar la empresa.\n$e");
    }
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
              Navigator.pop(context); // Cierra el diálogo
              if (onOk != null) {
                if (mounted) {
                  onOk();
                }
              }
            },
            child: const Text("OK"),
          ),
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
