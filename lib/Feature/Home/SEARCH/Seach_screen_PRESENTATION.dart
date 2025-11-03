import 'package:ezride/Core/widgets/Cards/Card_CarsDetails.dart';
import 'package:ezride/Feature/Home/SEARCH/Search_model/Search_model.dart';
import 'package:ezride/Feature/Home/SEARCH/shared/Search_Header.dart';
import 'package:go_router/go_router.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/form_field_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SearchAutos extends StatefulWidget {
  const SearchAutos({super.key});

  static String routeName = 'BUSQUEDAAUTOS';
  static String routePath = 'busquedaautos';

  @override
  State<SearchAutos> createState() => _SearchAutosState();
}

class _SearchAutosState extends State<SearchAutos> {
  // Controladores para el estado
  final List<Map<String, dynamic>> _vehicles = [
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1750493601730-10ff85ecc35b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTk0NDYzODR8&ixlib=rb-4.1.0&q=80&w=1080',
      'rentalAgency': 'Premium Rentals',
      'rating': 4.5,
      'reviewCount': 150,
      'distance': 2.0,
      'vehicleModel': 'BMW Serie 3 2024',
      'fuelType': 'Gasolina',
      'passengerCapacity': 5,
      'transmission': 'Automática',
      'pricePerDay': 1200.0,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTk0NDYzODR8&ixlib=rb-4.1.0&q=80&w=1080',
      'rentalAgency': 'City Rentals',
      'rating': 4.2,
      'reviewCount': 89,
      'distance': 3.5,
      'vehicleModel': 'Toyota Corolla 2023',
      'fuelType': 'Híbrido',
      'passengerCapacity': 5,
      'transmission': 'Automática',
      'pricePerDay': 800.0,
    },
    {
      'imageUrl':
          'https://images.unsplash.com/photo-1552519507-da3b142c6e3d?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHJhbmRvbXx8fHx8fHx8fDE3NTk0NDYzODR8&ixlib=rb-4.1.0&q=80&w=1080',
      'rentalAgency': 'SUV Specialists',
      'rating': 4.7,
      'reviewCount': 203,
      'distance': 1.2,
      'vehicleModel': 'Jeep Grand Cherokee',
      'fuelType': 'Gasolina',
      'passengerCapacity': 7,
      'transmission': 'Automática',
      'pricePerDay': 1500.0,
    },
  ];

  // Función para manejar la búsqueda
  void _onSearchSubmitted(String searchText) {
    print('Búsqueda ejecutada: $searchText');
    print('Buscando vehículos cerca de: $searchText');
    // Aquí iría la lógica real de búsqueda
  }

  // Función para manejar cambios en filtros
  void _onFiltersChanged(String type, String transmission, String price) {
    print('Filtros aplicados:');
    print('- Tipo: $type');
    print('- Transmisión: $transmission');
    print('- Precio: $price');

    // Aquí iría la lógica real de filtrado
    _filterVehicles(type, transmission, price);
  }

  // Función para limpiar búsqueda
  void _onSearchCleared() {
    print('Búsqueda limpiada - mostrando todos los vehículos');
    setState(() {
      // Restaurar lista completa de vehículos
    });
  }

  // Función para filtrar vehículos (simulada)
  void _filterVehicles(String type, String transmission, String price) {
    print('Aplicando filtros a la lista de vehículos...');
    // Lógica de filtrado real iría aquí
  }

  // Función cuando se presiona "Ver detalles" en una tarjeta
  void _onVehicleDetailsPressed(int index) {
    GoRouter.of(context).push('/auto-details');
  }

  // Función para manejar favoritos
  void _onVehicleFavoritePressed(int index) {
    final vehicle = _vehicles[index];
    print('Alternando favorito para: ${vehicle['vehicleModel']}');
    print('Índice: $index');

    // Aquí iría la lógica real para guardar en favoritos
  }

  // Función cuando se presiona toda la tarjeta
  void _onVehicleCardPressed(int index) {
    final vehicle = _vehicles[index];
    print('Tarjeta presionada: ${vehicle['vehicleModel']}');
    print('Abriendo vista rápida...');

    // Podría mostrar un modal con información rápida
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            VehicleSearchWidget(
              onSearchSubmitted: _onSearchSubmitted,
              onFiltersChanged: _onFiltersChanged,
              onSearchCleared: _onSearchCleared,
              initialSearchText: '',
              borderColor: const Color(0xFF0035FF),
              showAllFilters: true,
            ),

            // Lista de vehículos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // Header de resultados
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_vehicles.length} vehículos encontrados',
                          style:
                              FlutterFlowTheme.of(context).titleMedium.override(
                                    fontFamily: 'Lato',
                                    letterSpacing: 0.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                        // Botón para ordenar
                        FFButtonWidget(
                          onPressed: () {
                            print('Abrir modal de ordenamiento');
                          },
                          text: 'Ordenar',
                          icon: Icon(
                            Icons.sort,
                            size: 16,
                          ),
                          options: FFButtonOptions(
                            height: 36,
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                12, 0, 12, 0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                0, 0, 4, 0),
                            color: FlutterFlowTheme.of(context)
                                .secondaryBackground,
                            textStyle:
                                FlutterFlowTheme.of(context).bodySmall.override(
                                      fontFamily: 'Lato',
                                      letterSpacing: 0.0,
                                    ),
                            elevation: 0,
                            borderSide: BorderSide(
                              color: FlutterFlowTheme.of(context).alternate,
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 20
                  ),
                  // Lista de tarjetas de vehículos
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: _vehicles.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final vehicle = _vehicles[index];
                      return VehicleCardWidget(
                        imageUrl: vehicle['imageUrl'],
                        rentalAgency: vehicle['rentalAgency'],
                        rating: vehicle['rating'],
                        reviewCount: vehicle['reviewCount'],
                        distance: vehicle['distance'],
                        vehicleModel: vehicle['vehicleModel'],
                        fuelType: vehicle['fuelType'],
                        passengerCapacity: vehicle['passengerCapacity'],
                        transmission: vehicle['transmission'],
                        pricePerDay: vehicle['pricePerDay'],
                        onDetailsPressed: () => _onVehicleDetailsPressed(index),
                        onFavoritePressed: () =>
                            _onVehicleFavoritePressed(index),
                        onCardPressed: () => _onVehicleCardPressed(index),
                        accentColor: const Color(0xFF0035FF),
                        showDistance: true,
                      );
                    },
                  ),

                  // Espacio al final
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
