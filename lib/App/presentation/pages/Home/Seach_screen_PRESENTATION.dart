import 'package:ezride/Core/widgets/Cards/Card_CarsDetails.dart';
import 'package:ezride/Feature/Home/SEARCH/shared/Search_Header.dart';
import 'package:go_router/go_router.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';
import 'package:ezride/Feature/Home/SEARCH/Search_model/Search_controller.dart'
    as EzrideSearch;

class SearchAutos extends StatefulWidget {
  const SearchAutos({super.key});

  static String routeName = 'BUSQUEDAAUTOS';
  static String routePath = 'busquedaautos';

  @override
  State<SearchAutos> createState() => _SearchAutosState();
}

class _SearchAutosState extends State<SearchAutos> {
  @override
  Widget build(BuildContext context) {
    final searchController = context.watch<EzrideSearch.SearchController>();
    final vehicles = searchController.vehicles;
    final isLoading = searchController.isLoading;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            VehicleSearchWidget(
              onSearchSubmitted: (text) {
                context.read<EzrideSearch.SearchController>().search(text);
              },
              onFiltersChanged: (type, trans, price) {
                // Esto se conectará después
              },
              onSearchCleared: () {
                context.read<EzrideSearch.SearchController>().clear();
              },
              initialSearchText: '',
              borderColor: const Color(0xFF0035FF),
              showAllFilters: true,
            ),

            // 📍 RESULTADOS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${vehicles.length} vehículos encontrados',
                          style: FlutterFlowTheme.of(context)
                              .titleMedium
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),

                  if (isLoading)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(child: CircularProgressIndicator()),
                    ),

                  // ✅ Lista REAL de vehículos
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: vehicles.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final v = vehicles[index];

                      return VehicleCardWidget(
                        imageUrl:
                            'https://picsum.photos/800/600?random=${v.id}',
                        rentalAgency: 'RentaMax',
                        rating: 4.5,
                        reviewCount: 50,
                        distance: 1.2,
                        vehicleModel: v.titulo,
                        fuelType: v.combustible,
                        passengerCapacity: v.capacidad,
                        transmission: v.transmision,
                        pricePerDay: v.precioPorDia,
                        onDetailsPressed: () {
                          print("🔍 Ver detalles del vehículo: ${v.titulo}");
                          GoRouter.of(context).push(
                            '/auto-details',
                            extra: {
                              'vehicleId': v.id,
                              'vehicleTitle': v.titulo,
                              'vehicleImage':
                                  'https://picsum.photos/800/600?random=${v.id}',
                              'dailyPrice': v.precioPorDia,
                              'year': v.year.toString(), // ✅ FIX
                              'isRented': v.status.name,
                            },
                          );
                        },
                        onCardPressed: () {
                          print("📦 Card presionada: ${v.titulo}");
                          GoRouter.of(context).push(
                            '/auto-details',
                            extra: {
                              'vehicleId': v.id,
                              'vehicleTitle': v.titulo,
                              'vehicleImage':
                                  'https://picsum.photos/800/600?random=${v.id}',
                              'dailyPrice': v.precioPorDia,
                              'year': v.year.toString(), // ✅ FIX
                              'isRented': v.status.name,
                            },
                          );
                        },
                        onFavoritePressed: () {},
                        accentColor: const Color(0xFF0035FF),
                        showDistance: true,
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}