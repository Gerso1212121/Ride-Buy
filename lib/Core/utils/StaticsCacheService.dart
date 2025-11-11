// services/statistics_cache_service.dart
import 'package:ezride/App/DATA/models/Empresas_model.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Services/render/render_db_client.dart';

class StatisticsCacheService {
  static final StatisticsCacheService _instance = StatisticsCacheService._internal();
  factory StatisticsCacheService() => _instance;
  StatisticsCacheService._internal();

  static const Duration _cacheDuration = Duration(minutes: 5);
  
  EmpresaStatistics? _cachedStats;
  DateTime? _lastUpdate;
  String? _cachedEmpresaId;

  // ✅ Obtener estadísticas con cache
  Future<EmpresaStatistics> getStatistics() async {
    final empresa = SessionManager.currentEmpresa;
    if (empresa == null) throw Exception('No hay empresa activa');

    // Verificar si el cache es válido
    if (_isCacheValid(empresa.id)) {
      return _cachedStats!;
    }

    // Cargar datos frescos
    return await _loadFreshStatistics(empresa.id);
  }

  // ✅ Precargar estadísticas en segundo plano
  Future<void> preloadStatistics() async {
    final empresa = SessionManager.currentEmpresa;
    if (empresa == null || _isCacheValid(empresa.id)) return;

    try {
      await _loadFreshStatistics(empresa.id);
      print('✅ Precarga de estadísticas completada');
    } catch (e) {
      print('⚠️ Error en precarga de estadísticas: $e');
    }
  }

  bool _isCacheValid(String empresaId) {
    return _cachedStats != null &&
           _cachedEmpresaId == empresaId &&
           _lastUpdate != null &&
           DateTime.now().difference(_lastUpdate!) < _cacheDuration;
  }

  Future<EmpresaStatistics> _loadFreshStatistics(String empresaId) async {
    print('📊 Cargando estadísticas frescas para empresa: $empresaId');

    const sql = '''
      SELECT 
        COALESCE((
          SELECT SUM(total) 
          FROM public.rentas 
          WHERE empresa_id = @empresa_id 
        ), 0) as ganancias_totales,

        COALESCE((
          SELECT SUM(total) 
          FROM public.rentas 
          WHERE empresa_id = @empresa_id 
          AND fecha_inicio_renta >= DATE_TRUNC('month', CURRENT_DATE)
          AND fecha_inicio_renta < DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
        ), 0) as ganancias_mes,

        COALESCE((
          SELECT COUNT(*) 
          FROM public.rentas 
          WHERE empresa_id = @empresa_id 
          AND status = 'pendiente'
        ), 0) as solicitudes_pendientes,

        COALESCE((
          SELECT COUNT(DISTINCT vehiculo_id) 
          FROM public.rentas 
          WHERE empresa_id = @empresa_id 
          AND status IN ('confirmada', 'en_curso')
          AND fecha_inicio_renta <= CURRENT_TIMESTAMP
          AND fecha_entrega_vehiculo >= CURRENT_TIMESTAMP
        ), 0) as carros_rentados,

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

        COALESCE((
          SELECT COUNT(*) 
          FROM public.vehiculos 
          WHERE empresa_id = @empresa_id
        ), 0) as total_inventario
    ''';

    final result = await RenderDbClient.query(sql, parameters: {
      'empresa_id': empresaId,
    });

    if (result.isEmpty) {
      throw Exception('No se encontraron estadísticas para la empresa');
    }

    final stats = result.first;

    final statistics = EmpresaStatistics(
      gananciasTotales: _parseDouble(stats['ganancias_totales']),
      gananciasMes: _parseDouble(stats['ganancias_mes']),
      solicitudesPendientes: _parseInt(stats['solicitudes_pendientes']),
      carrosRentados: _parseInt(stats['carros_rentados']),
      carrosDisponibles: _parseInt(stats['carros_disponibles']),
      totalInventario: _parseInt(stats['total_inventario']),
    );

    // Ajustar datos si es necesario
    final sumaActual = statistics.carrosRentados + statistics.carrosDisponibles;
    if (sumaActual > statistics.totalInventario) {
      statistics.carrosDisponibles = statistics.totalInventario - statistics.carrosRentados;
      if (statistics.carrosDisponibles < 0) statistics.carrosDisponibles = 0;
    }

    // Actualizar cache
    _cachedStats = statistics;
    _cachedEmpresaId = empresaId;
    _lastUpdate = DateTime.now();

    print('✅ Estadísticas cacheadas: ${statistics.totalInventario} vehículos');
    return statistics;
  }

  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  // ✅ Forzar actualización
  void invalidateCache() {
    _cachedStats = null;
    _lastUpdate = null;
  }
}

class EmpresaStatistics {
  final double gananciasTotales;
  final double gananciasMes;
  final int solicitudesPendientes;
  final int carrosRentados;
  int carrosDisponibles;
  final int totalInventario;

  EmpresaStatistics({
    required this.gananciasTotales,
    required this.gananciasMes,
    required this.solicitudesPendientes,
    required this.carrosRentados,
    required this.carrosDisponibles,
    required this.totalInventario,
  });
}