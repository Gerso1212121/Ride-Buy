import '../Entities/vehicle_entity.dart';
import '../repositories/vehicle_repository_domain.dart';

class SearchVehiclesUseCase {
  final VehicleRepositoryDomain repository;

  SearchVehiclesUseCase(this.repository);

  Future<List<Vehicle>> call({
    required String query,
    String? type,
    String? transmission,
    double? minPrice,
    double? maxPrice,
  }) {
    return repository.searchVehicles(
      query: query,
      type: type,
      transmission: transmission,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }
}
