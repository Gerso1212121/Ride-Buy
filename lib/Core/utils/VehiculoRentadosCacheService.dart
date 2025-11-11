// lib/Services/cache/rentas_cache_service.dart
import 'package:ezride/App/DATA/models/RentaClienteModel.dart';

class RentasCacheService {
  static final RentasCacheService _instance = RentasCacheService._internal();
  factory RentasCacheService() => _instance;
  RentasCacheService._internal();

  // Cache por empresa ID
  final Map<String, List<RentaClienteModel>> _cache = {};
  final Map<String, DateTime> _lastUpdate = {};
  static const Duration cacheDuration = Duration(minutes: 2); // 2 minutos de cache

  // Obtener rentas del cache si están disponibles y no están expiradas
  List<RentaClienteModel>? getCachedRentas(String empresaId) {
    if (_cache.containsKey(empresaId) && _lastUpdate.containsKey(empresaId)) {
      final lastUpdate = _lastUpdate[empresaId]!;
      if (DateTime.now().difference(lastUpdate) < cacheDuration) {
        print('🔄 Usando datos cacheados para empresa: $empresaId');
        return List.from(_cache[empresaId]!); // Retornar copia
      } else {
        print('🗑️ Cache expirado para empresa: $empresaId');
        _cache.remove(empresaId);
        _lastUpdate.remove(empresaId);
      }
    }
    return null;
  }

  // Guardar rentas en cache
  void saveRentasToCache(String empresaId, List<RentaClienteModel> rentas) {
    _cache[empresaId] = List.from(rentas); // Guardar copia
    _lastUpdate[empresaId] = DateTime.now();
    print('💾 Datos guardados en cache para empresa: $empresaId (${rentas.length} rentas)');
  }

  // Invalidar cache para una empresa específica
  void invalidateCache(String empresaId) {
    _cache.remove(empresaId);
    _lastUpdate.remove(empresaId);
    print('🗑️ Cache invalidado para empresa: $empresaId');
  }

  // Invalidar todo el cache
  void invalidateAllCache() {
    _cache.clear();
    _lastUpdate.clear();
    print('🗑️ Todo el cache de rentas ha sido invalidado');
  }

  // Verificar si hay datos cacheados válidos
  bool hasValidCache(String empresaId) {
    if (!_cache.containsKey(empresaId) || !_lastUpdate.containsKey(empresaId)) {
      return false;
    }
    return DateTime.now().difference(_lastUpdate[empresaId]!) < cacheDuration;
  }
}