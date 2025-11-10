import 'package:flutter/material.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';

class FormularioEmpresaWidget extends StatefulWidget {
  const FormularioEmpresaWidget({super.key});

  @override
  State<FormularioEmpresaWidget> createState() => _FormularioEmpresaWidgetState();
}

class _FormularioEmpresaWidgetState extends State<FormularioEmpresaWidget> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Controladores
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _nitController = TextEditingController();
  final TextEditingController _nrcController = TextEditingController();
  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // Focus nodes
  final FocusNode _nombreFocus = FocusNode();
  final FocusNode _nitFocus = FocusNode();
  final FocusNode _nrcFocus = FocusNode();
  final FocusNode _direccionFocus = FocusNode();
  final FocusNode _telefonoFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();

  // Variables para ubicación
  double? _latitud;
  double? _longitud;
  bool _ubicacionObtenida = false;
  bool _obteniendoUbicacion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _solicitarUbicacion();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _nitController.dispose();
    _nrcController.dispose();
    _direccionController.dispose();
    _telefonoController.dispose();
    _emailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _solicitarUbicacion() async {
    _mostrarModalUbicacion();
  }

  void _mostrarModalUbicacion() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("📍 Ubicación Requerida"),
          content: const Text(
              "Para registrar tu empresa necesitamos acceder a tu ubicación actual para mostrar tu negocio en el mapa."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _obtenerUbicacion();
              },
              child: const Text("Activar Ubicación"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _cerrarPantalla();
              },
              child: const Text("Cancelar"),
            ),
          ],
        );
      },
    );
  }

  void _cerrarPantalla() {
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _obtenerUbicacion() async {
    if (mounted) {
      setState(() {
        _obteniendoUbicacion = true;
      });
    }

    try {
      bool serviceEnabled;
      LocationPermission permission;

      // Verificar si el servicio de ubicación está activado
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _mostrarErrorUbicacion(
            "GPS Desactivado", "Por favor, activa el GPS para continuar.");
        return;
      }

      // Verificar permisos
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _mostrarErrorUbicacion("Permiso Denegado",
              "No se puede registrar la empresa sin permisos de ubicación.");
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _mostrarErrorUbicacion("Permiso Bloqueado",
            "Activa los permisos de ubicación manualmente desde Ajustes > EzRide > Ubicación.");
        return;
      }

      // Obtener ubicación actual
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15),
      );

      if (mounted) {
        setState(() {
          _latitud = position.latitude;
          _longitud = position.longitude;
          _ubicacionObtenida = true;
          _obteniendoUbicacion = false;
        });
      }

      print("📍 Ubicación obtenida: Lat=$_latitud, Lng=$_longitud");
    } catch (e) {
      if (mounted) {
        setState(() {
          _obteniendoUbicacion = false;
        });
      }
      _mostrarErrorUbicacion(
          "Error de Ubicación", "No se pudo obtener la ubicación: $e");
    }
  }

  void _mostrarErrorUbicacion(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _cerrarPantalla();
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _continuarAImagenes() {
    if (!_ubicacionObtenida) {
      _mostrarErrorUbicacion(
          "Ubicación Requerida", "Es necesario obtener la ubicación para continuar.");
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }

    // Validar formato de teléfono
    if (!_validarTelefono(_telefonoController.text)) {
      _mostrarError("Teléfono Inválido", "Ingresa un número de teléfono válido (8 dígitos)");
      return;
    }

    // Navegar a la siguiente pantalla con los datos
    final datosEmpresa = {
      'nombre': _nombreController.text.trim(),
      'nit': _nitController.text.trim(),
      'nrc': _nrcController.text.trim(),
      'direccion': _direccionController.text.trim(),
      'telefono': _telefonoController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'latitud': _latitud,
      'longitud': _longitud,
    };

    // Navegar a la pantalla de imágenes
    context.push('/empresa-imagenes', extra: datosEmpresa);
  }

  bool _validarTelefono(String telefono) {
    final telefonoRegex = RegExp(r'^[0-9]{8}$');
    return telefonoRegex.hasMatch(telefono);
  }

  void _mostrarError(String titulo, String mensaje) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon, {bool opcional = false}) {
    return InputDecoration(
      labelText: opcional ? '$label (opcional)' : label,
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
      errorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(40.0),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: const BorderSide(
          color: Colors.red,
          width: 2.0,
        ),
        borderRadius: BorderRadius.circular(40.0),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(20.0),
    );
  }

  String? _validarRequerido(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa $campo';
    }
    return null;
  }

  String? _validarEmail(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  String? _validarTelefonoField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa el teléfono';
    }
    if (!_validarTelefono(value)) {
      return 'Ingresa un teléfono válido (8 dígitos)';
    }
    return null;
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
          onPressed: _cerrarPantalla,
        ),
        title: Text(
          "Datos de la Empresa",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                "Ingresa los datos básicos de tu empresa",
                style: theme.bodyMedium.override(
                  font: GoogleFonts.lato(),
                  color: theme.secondaryText,
                ),
              ),
              const SizedBox(height: 20),

              // Form Fields
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nombreController,
                        focusNode: _nombreFocus,
                        decoration: _inputStyle("Nombre de la Empresa", Icons.business),
                        validator: (value) => _validarRequerido(value, 'el nombre'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nitController,
                        focusNode: _nitFocus,
                        decoration: _inputStyle("NIT", Icons.assignment),
                        validator: (value) => _validarRequerido(value, 'el NIT'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _nrcController,
                        focusNode: _nrcFocus,
                        decoration: _inputStyle("NRC", Icons.badge),
                        validator: (value) => _validarRequerido(value, 'el NRC'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _direccionController,
                        focusNode: _direccionFocus,
                        decoration: _inputStyle("Dirección", Icons.location_on),
                        validator: (value) => _validarRequerido(value, 'la dirección'),
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _telefonoController,
                        focusNode: _telefonoFocus,
                        keyboardType: TextInputType.phone,
                        decoration: _inputStyle("Teléfono", Icons.phone),
                        validator: _validarTelefonoField,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        focusNode: _emailFocus,
                        keyboardType: TextInputType.emailAddress,
                        decoration: _inputStyle("Email", Icons.email, opcional: true),
                        validator: _validarEmail,
                        textInputAction: TextInputAction.done,
                      ),

                      // Indicador de ubicación
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _ubicacionObtenida 
                              ? Colors.green[50] 
                              : _obteniendoUbicacion
                                  ? Colors.blue[50]
                                  : Colors.orange[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _ubicacionObtenida 
                                ? Colors.green 
                                : _obteniendoUbicacion
                                    ? Colors.blue
                                    : Colors.orange,
                          ),
                        ),
                        child: Row(
                          children: [
                            _obteniendoUbicacion
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Icon(
                                    _ubicacionObtenida 
                                        ? Icons.check_circle 
                                        : Icons.location_on,
                                    color: _ubicacionObtenida 
                                        ? Colors.green 
                                        : Colors.orange,
                                  ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _obteniendoUbicacion
                                        ? "Obteniendo ubicación..."
                                        : _ubicacionObtenida 
                                            ? "Ubicación obtenida" 
                                            : "Ubicación requerida",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _ubicacionObtenida 
                                          ? Colors.green 
                                          : _obteniendoUbicacion
                                              ? Colors.blue
                                              : Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _obteniendoUbicacion
                                        ? "Estamos obteniendo tu ubicación actual..."
                                        : _ubicacionObtenida 
                                            ? "Lat: ${_latitud?.toStringAsFixed(4)}, Lng: ${_longitud?.toStringAsFixed(4)}" 
                                            : "Necesitamos tu ubicación para registrar la empresa",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _ubicacionObtenida 
                                          ? Colors.green[700] 
                                          : _obteniendoUbicacion
                                              ? Colors.blue[700]
                                              : Colors.orange[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!_ubicacionObtenida && !_obteniendoUbicacion)
                              TextButton(
                                onPressed: _obtenerUbicacion,
                                child: const Text("Reintentar"),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _ubicacionObtenida ? _continuarAImagenes : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                  child: Text(
                    "Continuar a Imágenes",
                    style: GoogleFonts.lato(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: OutlinedButton(
                  onPressed: _cerrarPantalla,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    side: BorderSide(color: theme.primary),
                  ),
                  child: Text(
                    "Cancelar Registro",
                    style: GoogleFonts.lato(
                      color: theme.primaryText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}