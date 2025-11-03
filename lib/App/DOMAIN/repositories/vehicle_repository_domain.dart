import '../Entities/vehicle_entity.dart';

abstract class VehicleRepositoryDomain {
  Future<List<Vehicle>> searchVehicles({
    required String query,
    String? type,
    String? transmission,
    double? minPrice,
    double? maxPrice,
  });

  Future<List<Vehicle>> getRecommendedVehicles();
}
