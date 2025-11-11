import 'package:ezride/App/DATA/datasources/Auth/vehicle_remote_datasource.dart';
import 'package:ezride/Core/widgets/Modals/GlobalModalAction.widget.dart';
import 'package:flutter/material.dart';
import 'package:ezride/App/DATA/repositories/vehicle_repository_data.dart';
import 'package:ezride/App/DOMAIN/usecases/create_vehicle_usecase.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Services/api/s3_service.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class FormularioVehiculoWidget extends StatefulWidget {
  const FormularioVehiculoWidget({super.key});

  @override
  State<FormularioVehiculoWidget> createState() =>
      _FormularioVehiculoWidgetState();
}

class _FormularioVehiculoWidgetState extends State<FormularioVehiculoWidget> {
  final _formKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

  // Controladores
  final TextEditingController _tituloController = TextEditingController();
  final TextEditingController _marcaController = TextEditingController();
  final TextEditingController _modeloController = TextEditingController();
  final TextEditingController _anioController = TextEditingController();
  final TextEditingController _placaController = TextEditingController();
  final TextEditingController _precioController = TextEditingController();
  final TextEditingController _colorController = TextEditingController();
  final TextEditingController _capacidadController = TextEditingController();
  final TextEditingController _kilometrajeController = TextEditingController();
  final TextEditingController _puertasController = TextEditingController();
  
  // ✅ NUEVOS CONTROLADORES
  final TextEditingController _tipoController = TextEditingController();
  final TextEditingController _soaNumberController = TextEditingController();
  final TextEditingController _circulacionVenceController = TextEditingController();
  final TextEditingController _soaVenceController = TextEditingController();

  // Imágenes
  File? _imagenVehiculo;
  File? _imagenPlaca;
  bool _creandoVehiculo = false;

  // Dropdowns
  String? _transmisionValue;
  String? _combustibleValue;

  @override
  void dispose() {
    _tituloController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _anioController.dispose();
    _placaController.dispose();
    _precioController.dispose();
    _colorController.dispose();
    _capacidadController.dispose();
    _kilometrajeController.dispose();
    _puertasController.dispose();
    
    // ✅ NUEVOS DISPOSE
    _tipoController.dispose();
    _soaNumberController.dispose();
    _circulacionVenceController.dispose();
    _soaVenceController.dispose();
    
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen(bool esVehiculo) async {
    final source = await _mostrarOpcionesImagen();
    if (source == null) return;

    try {
      final imagen = await S3Service.pickImage(source);
      if (imagen != null && mounted) {
        setState(() {
          if (esVehiculo) {
            _imagenVehiculo = imagen;
          } else {
            _imagenPlaca = imagen;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        _mostrarError("Error", "No se pudo seleccionar la imagen: $e");
      }
    }
  }

  Future<ImageSource?> _mostrarOpcionesImagen() async {
    return await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Seleccionar imagen"),
        content: const Text("¿Desde dónde quieres tomar la imagen?"),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.camera),
            icon: const Icon(Icons.camera_alt),
            label: const Text("Cámara"),
          ),
          TextButton.icon(
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
            icon: const Icon(Icons.photo_library),
            label: const Text("Galería"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTODO PARA SELECCIONAR FECHA
  Future<void> _seleccionarFecha(TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (picked != null && mounted) {
      setState(() {
        controller.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  // ✅ MÉTODO PARA PARSEAR FECHA
  DateTime? _parseFecha(String fechaStr) {
    try {
      final parts = fechaStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<void> _crearVehiculo() async {
    if (!_formKey.currentState!.validate()) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      return;
    }

    if (_imagenVehiculo == null || _imagenPlaca == null) {
      _mostrarError("Imágenes Requeridas",
          "Debes seleccionar ambas imágenes: vehículo completo y placa");
      return;
    }

    final empresa = SessionManager.currentEmpresa;
    if (empresa == null) {
      _mostrarError("Empresa Requerida",
          "Debes tener una empresa registrada para crear vehículos");
      return;
    }

    if (mounted) {
      setState(() => _creandoVehiculo = true);
    }

    try {
      final repo = VehicleRepositoryData(VehicleRemoteDataSource());
      final useCase = CreateVehicleUseCase(repo);

      await useCase.execute(
        empresaId: empresa.id,
        titulo: _tituloController.text.trim(),
        marca: _marcaController.text.trim(),
        modelo: _modeloController.text.trim(),
        anio: int.tryParse(_anioController.text),
        placa: _placaController.text.trim().toUpperCase(),
        precioPorDia: double.parse(_precioController.text),
        imagenVehiculo: _imagenVehiculo!,
        imagenPlaca: _imagenPlaca!,
        color: _colorController.text.trim().isEmpty
            ? null
            : _colorController.text.trim(),
        capacidad: int.tryParse(_capacidadController.text),
        transmision: _transmisionValue,
        combustible: _combustibleValue,
        kilometraje: int.tryParse(_kilometrajeController.text),
        puertas: int.tryParse(_puertasController.text),
        
        // ✅ NUEVOS CAMPOS
        tipo: _tipoController.text.trim().isEmpty 
            ? null 
            : _tipoController.text.trim(),
        soaNumber: _soaNumberController.text.trim().isEmpty
            ? null
            : _soaNumberController.text.trim(),
        circulacionVence: _circulacionVenceController.text.trim().isEmpty
            ? null
            : _parseFecha(_circulacionVenceController.text.trim()),
        soaVence: _soaVenceController.text.trim().isEmpty
            ? null
            : _parseFecha(_soaVenceController.text.trim()),
      );

      if (mounted) {
        _mostrarExito("¡Vehículo Creado!",
            "Tu vehículo '${_tituloController.text}' ha sido registrado exitosamente con validación IA");
      }
    } catch (e) {
      if (mounted) {
        _mostrarError(
            "Error al Crear Vehículo", "No se pudo registrar el vehículo:\n$e");
      }
    } finally {
      if (mounted) {
        setState(() => _creandoVehiculo = false);
      }
    }
  }

  void _mostrarError(String titulo, String mensaje) {
    showGlobalStatusModalAction(
      context,
      title: titulo,
      message: mensaje,
      icon: Icons.error,
      iconColor: Colors.red,
      confirmText: "OK",
    );
  }

  void _mostrarExito(String titulo, String mensaje) {
    showGlobalStatusModalAction(
      context,
      title: titulo,
      message: mensaje,
      icon: Icons.check_circle,
      iconColor: Colors.green,
      confirmText: "Continuar al Inicio",
      onConfirm: () => context.go('/main'),
    );
  }

  Widget _tarjetaImagen(
      String titulo, String descripcion, File? imagen, bool esVehiculo) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Icon(
                  esVehiculo ? Icons.directions_car : Icons.confirmation_number,
                  color: FlutterFlowTheme.of(context).primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: GoogleFonts.lato(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        descripcion,
                        style: GoogleFonts.lato(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Preview de imagen
            Container(
              width: double.infinity,
              height: esVehiculo ? 200 : 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey[50],
                border: Border.all(color: Colors.grey[300]!),
                image: imagen != null
                    ? DecorationImage(
                        image: FileImage(imagen),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: imagen == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          esVehiculo
                              ? Icons.car_rental
                              : Icons.confirmation_number,
                          size: 50,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Sin imagen",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  : null,
            ),

            const SizedBox(height: 16),

            // Botón de acción
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _seleccionarImagen(esVehiculo),
                style: ElevatedButton.styleFrom(
                  backgroundColor: FlutterFlowTheme.of(context).primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                icon: Icon(
                  imagen == null ? Icons.add_photo_alternate : Icons.edit,
                  size: 20,
                ),
                label: Text(
                  imagen == null ? "Seleccionar Imagen" : "Cambiar Imagen",
                  style: GoogleFonts.lato(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputStyle(String label, IconData icon,
      {bool opcional = false}) {
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

  String? _validarNumero(String? value, String campo) {
    if (value == null || value.trim().isEmpty) return null;
    final numero = int.tryParse(value);
    if (numero == null) {
      return 'Ingresa un número válido para $campo';
    }
    return null;
  }

  String? _validarPrecio(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingresa el precio por día';
    }
    final precio = double.tryParse(value);
    if (precio == null || precio <= 0) {
      return 'Ingresa un precio válido mayor a 0';
    }
    return null;
  }

  String? _validarAnio(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final anio = int.tryParse(value);
    if (anio == null || anio < 1980 || anio > DateTime.now().year + 1) {
      return 'Ingresa un año válido entre 1980 y ${DateTime.now().year + 1}';
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
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Registrar Vehículo",
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
                "Completa los datos de tu vehículo",
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
                      // Información de validación IA
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.verified_user, color: Colors.blue[700]),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Validación IA Activada",
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "Las imágenes serán validadas automáticamente por Azure GPT-4o antes del registro",
                                    style: TextStyle(
                                      color: Colors.blue[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Campos básicos
                      TextFormField(
                        controller: _tituloController,
                        decoration:
                            _inputStyle("Título del Vehículo", Icons.title),
                        validator: (value) =>
                            _validarRequerido(value, 'el título'),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _marcaController,
                        decoration:
                            _inputStyle("Marca", Icons.branding_watermark),
                        validator: (value) =>
                            _validarRequerido(value, 'la marca'),
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _modeloController,
                        decoration: _inputStyle("Modelo", Icons.model_training),
                        validator: (value) =>
                            _validarRequerido(value, 'el modelo'),
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _anioController,
                              decoration:
                                  _inputStyle("Año", Icons.calendar_today),
                              keyboardType: TextInputType.number,
                              validator: _validarAnio,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _placaController,
                              decoration: _inputStyle(
                                  "Placa", Icons.confirmation_number),
                              validator: (value) =>
                                  _validarRequerido(value, 'la placa'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _precioController,
                        decoration: _inputStyle(
                            "Precio por Día (\$)", Icons.attach_money),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        validator: _validarPrecio,
                      ),
                      const SizedBox(height: 16),

                      // Dropdowns
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _transmisionValue,
                              decoration:
                                  _inputStyle("Transmisión", Icons.settings),
                              items: const [
                                DropdownMenuItem(
                                    value: 'automatica',
                                    child: Text('Automática')),
                                DropdownMenuItem(
                                    value: 'manual', child: Text('Manual')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _transmisionValue = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _combustibleValue,
                              decoration: _inputStyle(
                                  "Combustible", Icons.local_gas_station),
                              items: const [
                                DropdownMenuItem(
                                    value: 'gasolina', child: Text('Gasolina')),
                                DropdownMenuItem(
                                    value: 'diesel', child: Text('Diesel')),
                                DropdownMenuItem(
                                    value: 'hibrido', child: Text('Híbrido')),
                                DropdownMenuItem(
                                    value: 'electrico',
                                    child: Text('Eléctrico')),
                                DropdownMenuItem(
                                    value: 'otros', child: Text('Otros')),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  _combustibleValue = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Campos opcionales
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _colorController,
                              decoration: _inputStyle("Color", Icons.color_lens,
                                  opcional: true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _capacidadController,
                              decoration: _inputStyle("Capacidad", Icons.people,
                                  opcional: true),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  _validarNumero(value, 'capacidad'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _kilometrajeController,
                              decoration: _inputStyle(
                                  "Kilometraje", Icons.speed,
                                  opcional: true),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  _validarNumero(value, 'kilometraje'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _puertasController,
                              decoration: _inputStyle(
                                  "Puertas", Icons.door_back_door,
                                  opcional: true),
                              keyboardType: TextInputType.number,
                              validator: (value) =>
                                  _validarNumero(value, 'puertas'),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ✅ NUEVOS CAMPOS - Fila 1
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _tipoController,
                              decoration: _inputStyle("Tipo de Vehículo", Icons.directions_car, opcional: true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _soaNumberController,
                              decoration: _inputStyle("Número SOA", Icons.confirmation_number, opcional: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ✅ NUEVOS CAMPOS - Fila 2 (Fechas)
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _circulacionVenceController,
                              decoration: _inputStyle("Vencimiento Circulación", Icons.date_range, opcional: true),
                              onTap: () => _seleccionarFecha(_circulacionVenceController),
                              readOnly: true,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: TextFormField(
                              controller: _soaVenceController,
                              decoration: _inputStyle("Vencimiento SOA", Icons.date_range, opcional: true),
                              onTap: () => _seleccionarFecha(_soaVenceController),
                              readOnly: true,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Imágenes
                      _tarjetaImagen(
                        "Imagen del Vehículo *",
                        "Foto nítida del vehículo completo (obligatoria)",
                        _imagenVehiculo,
                        true,
                      ),
                      const SizedBox(height: 20),
                      _tarjetaImagen(
                        "Imagen de la Placa *",
                        "Foto nítida y legible de la placa (obligatoria)",
                        _imagenPlaca,
                        false,
                      ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),

              // Botón de creación
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _creandoVehiculo ? null : _crearVehiculo,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                  ),
                  child: _creandoVehiculo
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Creando Vehículo...",
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        )
                      : Text(
                          "Crear Vehículo con Validación IA",
                          style: GoogleFonts.lato(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}