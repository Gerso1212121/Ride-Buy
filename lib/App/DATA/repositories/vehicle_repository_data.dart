import 'package:ezride/App/DOMAIN/Entities/vehicle_entity.dart';
import 'package:ezride/App/DOMAIN/repositories/vehicle_repository_domain.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryData implements VehicleRepositoryDomain {
  final VehicleRemoteDataSource remote;

  VehicleRepositoryData(this.remote);

  @override
  Future<List<Vehicle>> searchVehicles({
    required String query,
    String? type,
    String? transmission,
    double? minPrice,
    double? maxPrice,
  }) {
    return remote.searchVehicles(
      query: query,
      type: type,
      transmission: transmission,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  @override
  Future<List<Vehicle>> getRecommendedVehicles() {
    return remote.getRecommendedVehicles();
  }
}
