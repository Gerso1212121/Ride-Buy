import 'package:flutter/material.dart';
import 'package:ezride/App/DOMAIN/Entities/VEHICLE_ENTITY.dart';
import 'package:ezride/App/DOMAIN/usecases/search_vehicles_usecase.dart';

class SearchController extends ChangeNotifier {
  final SearchVehiclesUseCase searchVehiclesUseCase;

  List<VehicleEntity> vehicles = [];
  bool isLoading = false;

  SearchController(this.searchVehiclesUseCase);

  Future<void> search(String query) async {
    if (query.isEmpty) return;

    isLoading = true;
    notifyListeners();

    try {
      vehicles = await searchVehiclesUseCase(
        query: query,
      );
    } catch (e) {
      debugPrint("❌ Error buscando vehículos: $e");
      vehicles = [];
    }

    isLoading = false;
    notifyListeners();
  }

  void clear() {
    vehicles = [];
    notifyListeners();
  }
}
