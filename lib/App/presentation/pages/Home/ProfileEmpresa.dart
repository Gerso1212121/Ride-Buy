import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/GestionEmpresa.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileButton.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileEmpresaGanancias_widget.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileEmpresaHeader_widget.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfleActions.dart';
import 'package:ezride/Services/api/s3_service.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PerfilEmpresaWidget extends StatefulWidget {
  const PerfilEmpresaWidget({super.key});

  @override
  State<PerfilEmpresaWidget> createState() => _PerfilEmpresaWidgetState();
}

class _PerfilEmpresaWidgetState extends State<PerfilEmpresaWidget> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  EmpresasModel? _empresaData;
  Profile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadEmpresaData();
    SessionManager.empresaNotifier.addListener(_onEmpresaChanged);
    SessionManager.profileNotifier.addListener(_onProfileChanged);
  }

  @override
  void dispose() {
    SessionManager.empresaNotifier.removeListener(_onEmpresaChanged);
    SessionManager.profileNotifier.removeListener(_onProfileChanged);
    super.dispose();
  }

  void _onEmpresaChanged() {
    setState(() {
      _empresaData = SessionManager.currentEmpresa;
    });
  }

  void _onProfileChanged() {
    setState(() {
      _userProfile = SessionManager.currentProfile;
    });
  }

  void _loadEmpresaData() {
    setState(() {
      _empresaData = SessionManager.currentEmpresa;
      _userProfile = SessionManager.currentProfile;
    });
  }

  // ✅ MÉTODO SIMPLIFICADO: URL pública directa para perfil
// En tu PerfilEmpresaWidget, usa el método optimizado:

// ✅ MÉTODO OPTIMIZADO: URL pública directa para perfil
  String? _getPerfilImage() {
    final img = _empresaData?.imagenPerfil;
    if (img == null || img.isEmpty) return null;

    // ✅ USAR MÉTODO OPTIMIZADO - MÁS RÁPIDO
    return S3Service.getPublicUrl(img);
  }

// ✅ MÉTODO OPTIMIZADO: URL pública directa para banner
  String? _getBannerImage() {
    final img = _empresaData?.imagenBanner;
    if (img == null || img.isEmpty) return null;

    // ✅ USAR MÉTODO OPTIMIZADO - MÁS RÁPIDO
    return S3Service.getPublicUrl(img);
  }

  // Método para obtener la descripción de la empresa
  String _getDescripcion() {
    if (_empresaData?.direccion != null) {
      return '${_empresaData?.direccion ?? 'Empresa de Renta de Vehículos'}';
    }
    return 'Empresa de Renta de Vehículos';
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay datos de empresa, mostrar un loading o mensaje
    if (_empresaData == null) {
      return _buildLoadingState();
    }

    // ✅ DEBUG: Mostrar URLs en consola
    _debugImages();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Color(0xFFF0F5F9),
        body: SafeArea(
          top: true,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                PerfilHeader(
                  nombreEmpresa: _empresaData!.nombre,
                  descripcion: _getDescripcion(),
                  bannerUrl: _getBannerImage(), // ✅ URL pública directa
                  logoUrl: _getPerfilImage(), // ✅ URL pública directa
                  ubicacion: _empresaData!.direccion,
                  ncr: _empresaData?.nrc,
                ),
                GananciasCard(
                  gananciasTotales: 45280,
                  gananciasMes: 12450,
                  tendenciaPositiva: true,
                ),
                AccionesGrid(
                  solicitudesPendientes: 12,
                  carrosRentados: 8,
                  carrosDisponibles: 15,
                  onAgregarCarro: () => print('Agregar carro'),
                  onVerSolicitudes: () => print('Ver solicitudes'),
                  onVerRentados: () => print('Ver rentados'),
                  onVerInventario: () => print('Ver inventario'),
                ),
                GestionEmpresa(
                  representante:
                      _userProfile?.displayName ?? 'Nombre no disponible',
                  cargoRepresentante: 'Representante',
                  usuarioEmail: _userProfile?.email ?? 'Email no disponible',
                  onPerfilEmpresa: () => print('Perfil empresa'),
                  onRepresentante: () => context.push('/profile'),
                  onUsuario: () => print('Usuario'),
                ),
                BotonCerrarSesion(
                  onCerrarSesion: () => print('Cerrar sesión'),
                ),
              ]
                  .divide(SizedBox(height: 16))
                  .addToStart(SizedBox(height: 12))
                  .addToEnd(SizedBox(height: 24)),
            ),
          ),
        ),
      ),
    );
  }

  // ✅ MÉTODO DEBUG: Verificar URLs en consola
  void _debugImages() {
    final perfilUrl = _getPerfilImage();
    final bannerUrl = _getBannerImage();

    print('🖼️ DEBUG IMÁGENES:');
    print('   - Perfil URL: $perfilUrl');
    print('   - Banner URL: $bannerUrl');
    print('   - Imagen Perfil en BD: ${_empresaData?.imagenPerfil}');
    print('   - Imagen Banner en BD: ${_empresaData?.imagenBanner}');
  }

  Widget _buildLoadingState() {
    return Scaffold(
      backgroundColor: Color(0xFFF0F5F9),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Cargando datos de la empresa...',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmpresaData,
              child: Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}
