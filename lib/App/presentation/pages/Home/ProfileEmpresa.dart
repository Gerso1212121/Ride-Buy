import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/App/DOMAIN/Entities/Auth/PROFILE_user_entity.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Core/utils/StaticsCacheService.dart';
import 'package:ezride/Core/utils/VehicleCacheService.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/GestionEmpresa.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileButton.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileEmpresaGanancias_widget.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfileEmpresaHeader_widget.dart';
import 'package:ezride/Feature/Home/Profle_Empresa/widget/ProfleActions.dart';
import 'package:ezride/Services/api/s3_service.dart';
import 'package:ezride/Services/render/render_db_client.dart';
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
  double _gananciasTotales = 0.0;
  double _gananciasMes = 0.0;
  int _solicitudesPendientes = 0;
  int _carrosRentados = 0;
  int _carrosDisponibles = 0;
  int _totalInventario = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmpresaData();
    _preloadAllData(); // ✅ PRECARGAR TODOS los datos
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
    _loadStatisticsFromCache(); // ✅ Usar cache para estadísticas
    _preloadAllData(); // ✅ Reprecargar si cambia la empresa
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
    _loadStatisticsFromCache(); // ✅ Usar cache en lugar de consulta directa
  }

  // ✅ MÉTODO NUEVO: Precargar TODOS los datos en segundo plano
  void _preloadAllData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await Future.wait([
          VehicleCacheService().preloadVehicles(),
          StatisticsCacheService().preloadStatistics(),
        ]);
        print('✅ Precarga completa de vehículos y estadísticas');
      } catch (e) {
        print('⚠️ Precarga fallida: $e');
      }
    });
  }

  // ✅ MÉTODO NUEVO: Cargar estadísticas desde cache
  Future<void> _loadStatisticsFromCache() async {
    if (_empresaData == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      final stats = await StatisticsCacheService().getStatistics();
      
      setState(() {
        _gananciasTotales = stats.gananciasTotales;
        _gananciasMes = stats.gananciasMes;
        _solicitudesPendientes = stats.solicitudesPendientes;
        _carrosRentados = stats.carrosRentados;
        _carrosDisponibles = stats.carrosDisponibles;
        _totalInventario = stats.totalInventario;
        _isLoading = false;
      });

      print('✅ Estadísticas cargadas desde cache');
      
    } catch (e) {
      print('❌ Error cargando estadísticas desde cache: $e');
      // Fallback al método original
      _loadEstadisticasEmpresaFallback();
    }
  }

  // ✅ MÉTODO DE FALLBACK (mantener tu método original como backup)
  Future<void> _loadEstadisticasEmpresaFallback() async {
    if (_empresaData == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
      });

      print('📊 Cargando estadísticas directamente (fallback)...');

      const sql = '''
        SELECT 
          -- ✅ GANANCIAS TOTALES (TODAS las rentas sin importar estado)
          COALESCE((
            SELECT SUM(total) 
            FROM public.rentas 
            WHERE empresa_id = @empresa_id 
          ), 0) as ganancias_totales,

          -- ✅ GANANCIAS DEL MES ACTUAL (TODAS las rentas sin importar estado)
          COALESCE((
            SELECT SUM(total) 
            FROM public.rentas 
            WHERE empresa_id = @empresa_id 
            AND fecha_inicio_renta >= DATE_TRUNC('month', CURRENT_DATE)
            AND fecha_inicio_renta < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
          ), 0) as ganancias_mes,

          -- ✅ SOLICITUDES PENDIENTES
          COALESCE((
            SELECT COUNT(*) 
            FROM public.rentas 
            WHERE empresa_id = @empresa_id 
            AND status = 'pendiente'
          ), 0) as solicitudes_pendientes,

          -- ✅ CARROS RENTADOS ACTUALMENTE
          COALESCE((
            SELECT COUNT(DISTINCT vehiculo_id) 
            FROM public.rentas 
            WHERE empresa_id = @empresa_id 
            AND status IN ('confirmada', 'en_curso')
            AND fecha_inicio_renta <= CURRENT_TIMESTAMP
            AND fecha_entrega_vehiculo >= CURRENT_TIMESTAMP
          ), 0) as carros_rentados,

          -- ✅ CARROS DISPONIBLES
          COALESCE((
            SELECT COUNT(*) 
            FROM public.vehiculos 
            WHERE empresa_id = @empresa_id 
            AND estado = 'disponible'
            AND NOT EXISTS (
              SELECT 1 FROM public.rentas r 
              WHERE r.vehiculo_id = vehiculos.id 
              AND r.status IN ('confirmada', 'en_curso')
              AND r.fecha_inicio_renta <= CURRENT_TIMESTAMP
              AND r.fecha_entrega_vehiculo >= CURRENT_TIMESTAMP
            )
          ), 0) as carros_disponibles,

          -- ✅ TOTAL INVENTARIO
          COALESCE((
            SELECT COUNT(*) 
            FROM public.vehiculos 
            WHERE empresa_id = @empresa_id
          ), 0) as total_inventario
      ''';

      final result = await RenderDbClient.query(sql, parameters: {
        'empresa_id': _empresaData!.id,
      });

      if (result.isNotEmpty) {
        final stats = result.first;
        setState(() {
          _gananciasTotales = _parseDouble(stats['ganancias_totales']);
          _gananciasMes = _parseDouble(stats['ganancias_mes']);
          _solicitudesPendientes = _parseInt(stats['solicitudes_pendientes']);
          _carrosRentados = _parseInt(stats['carros_rentados']);
          _carrosDisponibles = _parseInt(stats['carros_disponibles']);
          _totalInventario = _parseInt(stats['total_inventario']);
        });

        // Ajustar datos si es necesario
        final sumaActual = _carrosRentados + _carrosDisponibles;
        if (sumaActual > _totalInventario) {
          _carrosDisponibles = _totalInventario - _carrosRentados;
          if (_carrosDisponibles < 0) _carrosDisponibles = 0;
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error cargando estadísticas: $e');
      // Datos de fallback
      setState(() {
        _gananciasTotales = 0.0;
        _gananciasMes = 0.0;
        _solicitudesPendientes = 0;
        _carrosRentados = 0;
        _carrosDisponibles = 0;
        _totalInventario = 0;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ MÉTODO PARA REFRESCAR DATOS
  Future<void> _refreshData() async {
    print('🔄 Forzando actualización de todos los datos...');
    
    // Invalidar ambos caches
    VehicleCacheService().invalidateCache();
    StatisticsCacheService().invalidateCache();
    
    // Recargar datos
    await _loadStatisticsFromCache();
  }

  // ✅ MÉTODO AUXILIAR: Parsing seguro de double
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.tryParse(value) ?? 0.0;
      } catch (e) {
        print('⚠️ Error parsing double from string: "$value"');
        return 0.0;
      }
    }
    print('⚠️ Tipo no manejado en _parseDouble: ${value.runtimeType}');
    return 0.0;
  }

  // ✅ MÉTODO AUXILIAR: Parsing seguro de int
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.tryParse(value) ?? 0;
      } catch (e) {
        print('⚠️ Error parsing int from string: "$value"');
        return 0;
      }
    }
    print('⚠️ Tipo no manejado en _parseInt: ${value.runtimeType}');
    return 0;
  }

  // ✅ MÉTODO OPTIMIZADO: URL pública directa para perfil
  String? _getPerfilImage() {
    final img = _empresaData?.imagenPerfil;
    if (img == null || img.isEmpty) return null;
    return S3Service.getPublicUrl(img);
  }

  // ✅ MÉTODO OPTIMIZADO: URL pública directa para banner
  String? _getBannerImage() {
    final img = _empresaData?.imagenBanner;
    if (img == null || img.isEmpty) return null;
    return S3Service.getPublicUrl(img);
  }

  // Método para obtener la descripción de la empresa
  String _getDescripcion() {
    if (_empresaData?.direccion != null) {
      return '${_empresaData?.direccion ?? 'Empresa de Renta de Vehículos'}';
    }
    return 'Empresa de Renta de Vehículos';
  }

  // ✅ MÉTODO NUEVO: Navegación optimizada a inventario
  void _navigateToInventory() {
    print('🚀 Navegando a inventario con cache...');
    VehicleCacheService().preloadVehicles().then((_) {
      context.push("/empresa-vehiculos");
    }).catchError((e) {
      context.push("/empresa-vehiculos");
    });
  }

  // ✅ MÉTODO NUEVO: Navegación optimizada a vehículos rentados
  void _navigateToRentados() {
    print('🚗 Navegando a vehículos rentados con cache...');
    VehicleCacheService().preloadVehicles().then((_) {
      context.push("/vehiculos-rentados");
    }).catchError((e) {
      context.push("/vehiculos-rentados");
    });
  }

  void _verSolicitudesPendientes() {
    print('🔍 Navegando a solicitudes pendientes');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Solicitudes pendientes: $_solicitudesPendientes'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  void _cerrarSesion() {
    print('🚪 Cerrando sesión...');
    // ✅ LIMPIAR AMBOS CACHES al cerrar sesión
    VehicleCacheService().invalidateCache();
    StatisticsCacheService().invalidateCache();
    SessionManager.clearProfile().then((_) {
      context.go('/auth');
    });
  }

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
              _empresaData == null
                  ? 'Cargando datos de la empresa...'
                  : 'Calculando estadísticas...',
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

  @override
  Widget build(BuildContext context) {
    if (_empresaData == null || _isLoading) {
      return _buildLoadingState();
    }

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
          child: RefreshIndicator( // ✅ AGREGAR PULL-TO-REFRESH
            onRefresh: _refreshData,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  PerfilHeader(
                    nombreEmpresa: _empresaData!.nombre,
                    descripcion: _getDescripcion(),
                    bannerUrl: _getBannerImage(),
                    logoUrl: _getPerfilImage(),
                    ubicacion: _empresaData!.direccion,
                    ncr: _empresaData?.nrc,
                  ),
                  GananciasCard(
                    gananciasTotales: _gananciasTotales,
                    gananciasMes: _gananciasMes,
                    tendenciaPositiva: _gananciasMes > 0,
                  ),
                  AccionesGrid(
                    solicitudesPendientes: _solicitudesPendientes,
                    carrosRentados: _carrosRentados,
                    carrosDisponibles: _carrosDisponibles,
                    totalInventario: _totalInventario,
                    onAgregarCarro: () => context.push("/crear-vehiculo"),
                    onVerSolicitudes: () => context.push("/empresa-solicitudes"),
                    onVerRentados: () => _navigateToRentados(), // ✅ USAR NAVEGACIÓN OPTIMIZADA
                    onVerInventario: () => _navigateToInventory(), // ✅ USAR NAVEGACIÓN OPTIMIZADA
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
                    onCerrarSesion: () => _cerrarSesion(),
                  ),
                ]
                    .divide(SizedBox(height: 16))
                    .addToStart(SizedBox(height: 12))
                    .addToEnd(SizedBox(height: 24)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}