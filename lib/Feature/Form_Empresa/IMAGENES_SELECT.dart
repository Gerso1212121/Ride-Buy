import 'package:ezride/Core/widgets/Modals/GlobalModalAction.widget.dart';
import 'package:ezride/Services/api/s3_service.dart';
import 'package:flutter/material.dart';
import 'package:ezride/App/DATA/repositories/EmpresaRepository_data.dart';
import 'package:ezride/App/DOMAIN/usecases/RegistrarEmpresa_UseCase.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';

class ImagenesSelectWidget extends StatefulWidget {
  final Map<String, dynamic>? datosEmpresa; // ✅ <-- añade esto

  const ImagenesSelectWidget({
    super.key,
    this.datosEmpresa, // ✅ <-- y aquí
  });

  @override
  State<ImagenesSelectWidget> createState() => _ImagenesSelectWidgetState();
}

class _ImagenesSelectWidgetState extends State<ImagenesSelectWidget> {
  File? _imagenPerfil;
  File? _imagenBanner;
  bool _registrando = false;
  late Map<String, dynamic> _datosEmpresa;

  @override
  void initState() {
    super.initState();

    if (widget.datosEmpresa == null) {
      throw Exception("❌ No se recibieron datos para registrar la empresa.");
    }

    _datosEmpresa = widget.datosEmpresa!;
  }

  Future<void> _seleccionarImagen(bool esPerfil) async {
    final source = await _mostrarOpcionesImagen();
    if (source == null) return;

    try {
      final imagen = await S3Service.pickImage(source);
      if (imagen != null && mounted) {
        setState(() {
          if (esPerfil) {
            _imagenPerfil = imagen;
          } else {
            _imagenBanner = imagen;
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

  Future<void> _registrarEmpresa() async {
    if (_imagenPerfil == null) {
      _mostrarError("Imagen Requerida",
          "Por favor selecciona una imagen de perfil para tu empresa");
      return;
    }

    if (mounted) {
      setState(() => _registrando = true);
    }

    try {
      final profile = await SessionManager.loadSession();
      if (profile == null) {
        throw Exception("No se encontró la sesión del usuario");
      }

      // Verificar si el usuario ya tiene una empresa registrada
      final empresas =
          await EmpresarepositoryData().obtenerEmpresasPorOwner(profile.id);
      if (empresas.isNotEmpty) {
        throw Exception("Ya tienes una empresa registrada");
      }

      final repo = EmpresarepositoryData();
      final useCase = RegistrarEmpresaUseCase(repo);

      // 🚀 EJECUTAR REGISTRO COMPLETO CON IMÁGENES
      final empresa = await useCase.execute(
        ownerId: profile.id,
        nombre: _datosEmpresa['nombre'],
        nit: _datosEmpresa['nit'],
        nrc: _datosEmpresa['nrc'],
        direccion: _datosEmpresa['direccion'],
        telefono: _datosEmpresa['telefono'],
        email: _datosEmpresa['email'] ?? '',
        latitud: _datosEmpresa['latitud'],
        longitud: _datosEmpresa['longitud'],
        imagePerfil: _imagenPerfil!, // ✅ Imagen obligatoria
        imageBanner: _imagenBanner, // ✅ Imagen opcional
      );

      // ✅ Actualizar sesión con la nueva empresa
      await SessionManager.updateCurrentEmpresa(empresa);

      if (mounted) {
        _mostrarExito("¡Empresa Registrada!",
            "Tu empresa '${empresa.nombre}' ha sido registrada exitosamente");
      }
    } catch (e) {
      if (mounted) {
        _mostrarError(
            "Error al Registrar", "No se pudo registrar la empresa:\n$e");
      }
    } finally {
      if (mounted) {
        setState(() => _registrando = false);
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
      String titulo, String descripcion, File? imagen, bool esPerfil) {
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
                  esPerfil ? Icons.person : Icons.photo_library,
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
              height: esPerfil ? 180 : 120,
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
                          esPerfil
                              ? Icons.person_outline
                              : Icons.photo_library_outlined,
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
                onPressed: () => _seleccionarImagen(esPerfil),
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
          "Imágenes de la Empresa",
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Información de la empresa
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Resumen de la Empresa",
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _datosEmpresa['nombre'],
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                    Text(
                      "NIT: ${_datosEmpresa['nit']} • NRC: ${_datosEmpresa['nrc']}",
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Selección de imágenes
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _tarjetaImagen(
                      "Imagen de Perfil *",
                      "Esta imagen representará tu empresa en la app (obligatoria)",
                      _imagenPerfil,
                      true,
                    ),
                    const SizedBox(height: 20),
                    _tarjetaImagen(
                      "Imagen de Banner",
                      "Imagen de portada para el perfil de tu empresa (opcional)",
                      _imagenBanner,
                      false,
                    ),

                    // Información adicional
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Optimización automática",
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Las imágenes se comprimen automáticamente para optimizar espacio y velocidad de carga",
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
                  ],
                ),
              ),
            ),

            // Botón de registro
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _registrando ? null : _registrarEmpresa,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40.0),
                  ),
                ),
                child: _registrando
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
                            "Registrando Empresa...",
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    : Text(
                        "Registrar Empresa",
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
    );
  }
}
