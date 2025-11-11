// services/vehicle_cache_service.dart
import 'package:ezride/App/DATA/datasources/Auth/vehicle_remote_datasource.dart';
import 'package:ezride/App/DATA/models/Vehiculo_model.dart';
import 'package:ezride/App/DATA/repositories/vehicle_repository_data.dart';
import 'package:ezride/Core/sessions/session_manager.dart';

class VehicleCacheService {
  static final VehicleCacheService _instance = VehicleCacheService._internal();
  factory VehicleCacheService() => _instance;
  VehicleCacheService._internal();

  static const Duration _cacheDuration = Duration(minutes: 10);

  List<VehicleModel>? _cachedVehicles;
  Map<String, String>? _cachedStatus;
  DateTime? _lastUpdate;
  String? _cachedEmpresaId;

  // ✅ Obtener vehículos con cache
  Future<VehicleData> getVehicles() async {
    final empresa = SessionManager.currentEmpresa;
    if (empresa == null) throw Exception('No hay empresa activa');

    // Verificar si el cache es válido
    if (_isCacheValid(empresa.id)) {
      return VehicleData(
        vehicles: _cachedVehicles!,
        status: _cachedStatus!,
      );
    }

    // Cargar datos frescos
    return await _loadFreshData(empresa.id);
  }

  // ✅ Precargar datos en segundo plano
  Future<void> preloadVehicles() async {
    final empresa = SessionManager.currentEmpresa;
    if (empresa == null || _isCacheValid(empresa.id)) return;

    try {
      await _loadFreshData(empresa.id);
      print('✅ Precarga de vehículos completada');
    } catch (e) {
      print('⚠️ Error en precarga: $e');
    }
  }

  bool _isCacheValid(String empresaId) {
    return _cachedVehicles != null &&
        _cachedStatus != null &&
        _cachedEmpresaId == empresaId &&
        _lastUpdate != null &&
        DateTime.now().difference(_lastUpdate!) < _cacheDuration;
  }

  Future<VehicleData> _loadFreshData(String empresaId) async {
    final repository = VehicleRepositoryData(VehicleRemoteDataSource());
    final vehicles = await repository.getVehiclesByEmpresa(empresaId);

    // Cargar estados
    final statusMap = <String, String>{};
    for (final vehicle in vehicles) {
      final realStatus = await _getVehicleRealStatus(vehicle, repository);
      statusMap[vehicle.id!] = realStatus;
    }

    // Actualizar cache
    _cachedVehicles = vehicles;
    _cachedStatus = statusMap;
    _cachedEmpresaId = empresaId;
    _lastUpdate = DateTime.now();

    return VehicleData(vehicles: vehicles, status: statusMap);
  }

  Future<String> _getVehicleRealStatus(
      VehicleModel vehicle, VehicleRepositoryData repo) async {
    if (vehicle.estado == 'mantenimiento' || vehicle.estado == 'inactivo') {
      return vehicle.estado!;
    }

    try {
      final hasActiveRent = await repo.hasActiveRent(vehicle.id!);
      return hasActiveRent ? 'en_renta' : 'disponible';
    } catch (e) {
      return vehicle.estado ?? 'disponible';
    }
  }

  // ✅ Forzar actualización
  void invalidateCache() {
    _cachedVehicles = null;
    _cachedStatus = null;
    _lastUpdate = null;
  }
}

class VehicleData {
  final List<VehicleModel> vehicles;
  final Map<String, String> status;

  VehicleData({required this.vehicles, required this.status});
}
