import 'package:ezride/Core/widgets/Cards/Card_CarsDetails.dart';
import 'package:ezride/Core/widgets/Cards/CradBusiness.dart';
import 'package:ezride/Feature/Home/SEARCH/shared/Search_Header.dart';
import 'package:go_router/go_router.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart' hide SearchController;
import 'package:provider/provider.dart';
import 'package:ezride/Feature/Home/SEARCH/Search_model/Search_controller.dart'
    as EzrideSearch;
import 'package:geolocator/geolocator.dart';
import 'package:ezride/Services/utils/EmpresasService.dart';

class SearchAutos extends StatefulWidget {
  const SearchAutos({super.key});

  static String routeName = 'BUSQUEDAAUTOS';
  static String routePath = 'busquedaautos';

  @override
  State<SearchAutos> createState() => _SearchAutosState();
}

class _SearchAutosState extends State<SearchAutos> {
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  List<dynamic> _empresasResultados = [];
  List<dynamic> _vehiculosResultados = [];
  bool _isLoadingBusqueda = false;
  String _searchText = '';
  String _modoBusqueda = 'todos'; // 'todos', 'empresas', 'vehiculos'
  int _resultadosTotales = 0;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // ✅ OBTENER UBICACIÓN ACTUAL
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          print('❌ Permisos de ubicación denegados');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        print('❌ Permisos de ubicación denegados permanentemente');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      setState(() {
        _currentPosition = position;
        _isLoadingLocation = false;
      });

      print(
          '📍 Ubicación obtenida: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ Error obteniendo ubicación: $e');
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  // ✅ BÚSQUEDA UNIFICADA - SOLO POR TEXTO DEL INPUT
  Future<void> _realizarBusquedaUnificada(String searchText) async {
    if (searchText.isEmpty) {
      setState(() {
        _empresasResultados = [];
        _vehiculosResultados = [];
        _resultadosTotales = 0;
        _searchText = '';
      });
      return;
    }

    setState(() {
      _isLoadingBusqueda = true;
      _searchText = searchText;
    });

    try {
      // ✅ BUSCAR EMPRESAS Y VEHÍCULOS EN PARALELO SOLO POR TEXTO
      final resultados = await Future.wait([
        _buscarEmpresasPorTexto(searchText),
        _buscarVehiculosPorTexto(searchText),
      ], eagerError: false);

      final empresas = resultados[0] as List<dynamic>;
      final vehiculos = resultados[1] as List<dynamic>;

      setState(() {
        _empresasResultados = empresas;
        _vehiculosResultados = vehiculos;
        _resultadosTotales = empresas.length + vehiculos.length;
      });

      print(
          '🎯 Búsqueda por texto completada: ${empresas.length} empresas, ${vehiculos.length} vehículos');
    } catch (e) {
      print('❌ Error en búsqueda unificada: $e');
      setState(() {
        _empresasResultados = [];
        _vehiculosResultados = [];
        _resultadosTotales = 0;
      });
    } finally {
      setState(() {
        _isLoadingBusqueda = false;
      });
    }
  }

  // ✅ BUSCAR EMPRESAS SOLO POR TEXTO
  Future<List<dynamic>> _buscarEmpresasPorTexto(String searchText) async {
    try {
      print('🔍 Buscando empresas por texto: "$searchText"');
      final empresas = await EmpresasService.searchEmpresas(searchText);

      // Si tenemos ubicación, calcular distancias para mostrar (no para filtrar)
      if (_currentPosition != null) {
        return await _calcularDistancias(empresas);
      }

      return empresas;
    } catch (e) {
      print('❌ Error buscando empresas: $e');
      return [];
    }
  }

  // ✅ BUSCAR VEHÍCULOS SOLO POR TEXTO
  Future<List<dynamic>> _buscarVehiculosPorTexto(String searchText) async {
    try {
      print('🚗 Buscando vehículos por texto: "$searchText"');
      final searchController = context.read<EzrideSearch.SearchController>();
      await searchController.search(searchText);
      return searchController.vehicles;
    } catch (e) {
      print('❌ Error buscando vehículos: $e');
      return [];
    }
  }

  // ✅ CALCULAR DISTANCIAS SOLO PARA MOSTRAR (NO PARA FILTRAR)
  Future<List<dynamic>> _calcularDistancias(List<dynamic> empresas) async {
    final empresasConDistancia = <dynamic>[];

    for (var empresa in empresas) {
      try {
        final lat = empresa['latitud'] as double?;
        final lng = empresa['longitud'] as double?;

        if (lat != null && lng != null && _currentPosition != null) {
          final distancia = await Geolocator.distanceBetween(
            _currentPosition!.latitude,
            _currentPosition!.longitude,
            lat,
            lng,
          );

          final distanciaKm = distancia / 1000;

          empresasConDistancia.add({
            ...empresa,
            'distancia': distanciaKm,
          });
        } else {
          empresasConDistancia.add({
            ...empresa,
            'distancia': null,
          });
        }
      } catch (e) {
        print(
            '❌ Error calculando distancia para empresa ${empresa['nombre']}: $e');
        empresasConDistancia.add({
          ...empresa,
          'distancia': null,
        });
      }
    }

    // Ordenar por distancia solo para visualización
    empresasConDistancia.sort((a, b) {
      final distA = a['distancia'] ?? double.infinity;
      final distB = b['distancia'] ?? double.infinity;
      return distA.compareTo(distB);
    });

    return empresasConDistancia;
  }

  // ✅ BUSCAR EMPRESAS CERCANAS (SOLO CUANDO SE PRESIONA EL BOTÓN EXPLÍCITAMENTE)
  Future<void> _buscarEmpresasCercanas() async {
    if (_currentPosition == null) {
      print('❌ No hay ubicación disponible');
      _mostrarSnackbar('No se pudo obtener la ubicación');
      return;
    }

    setState(() {
      _isLoadingBusqueda = true;
      _searchText = 'Empresas cercanas';
      _modoBusqueda = 'empresas';
    });

    try {
      final empresas = await EmpresasService.getEmpresasCercanas(
          _currentPosition!.latitude, _currentPosition!.longitude,
          radioKm: 30.0); // Cambiado a 30km

      setState(() {
        _empresasResultados = empresas;
        _vehiculosResultados = [];
        _resultadosTotales = empresas.length;
      });

      print(
          '📍 Búsqueda por ubicación completada: ${empresas.length} empresas');
    } catch (e) {
      print('❌ Error buscando empresas cercanas: $e');
      _mostrarSnackbar('Error buscando empresas cercanas');
      setState(() {
        _empresasResultados = [];
        _resultadosTotales = 0;
      });
    } finally {
      setState(() {
        _isLoadingBusqueda = false;
      });
    }
  }

  void _mostrarSnackbar(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // ✅ NAVEGAR A PERFIL DE EMPRESA
// ✅ NAVEGAR A PERFIL DE EMPRESA CON TODOS LOS DATOS
  void _navigateToEmpresaProfile(Map<String, dynamic> empresa) {
    print('🚀 Navegando al perfil de empresa: ${empresa['nombre']}');

    GoRouter.of(context).push(
      '/empresa-profile',
      extra: {
        'empresaId': empresa['id']?.toString() ?? '',
        'empresaData': empresa, // ✅ Pasar todos los datos
      },
    );
  }

  // ✅ CAMBIAR MODO DE BÚSQUEDA
  void _cambiarModoBusqueda(String modo) {
    setState(() {
      _modoBusqueda = modo;
    });
  }

  // ✅ LIMPIAR BÚSQUEDA
  void _limpiarBusqueda() {
    setState(() {
      _searchText = '';
      _empresasResultados = [];
      _vehiculosResultados = [];
      _resultadosTotales = 0;
      _modoBusqueda = 'todos';
    });
    context.read<EzrideSearch.SearchController>().clear();
  }

  @override
  Widget build(BuildContext context) {
    final searchController = context.watch<EzrideSearch.SearchController>();
    final isLoadingVehiculos = searchController.isLoading;

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // ✅ HEADER DE BÚSQUEDA - SOLO TEXTO
            VehicleSearchWidget(
              onSearchSubmitted: _realizarBusquedaUnificada,
              onFiltersChanged: (type, trans, price) {
                if (_searchText.isNotEmpty) {
                  _realizarBusquedaUnificada(_searchText);
                }
              },
              onSearchCleared: _limpiarBusqueda,
              initialSearchText: _searchText,
              borderColor: const Color(0xFF0035FF),
              showAllFilters: true,
              showLocationButton: true,
              onLocationPressed: _buscarEmpresasCercanas,
              isLocationLoading: _isLoadingLocation || _isLoadingBusqueda,
            ),

            // 📍 INDICADOR DE UBICACIÓN (solo informativo)
            if (_isLoadingLocation)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator()),
                    SizedBox(width: 8),
                    Text('Obteniendo ubicación...'),
                  ],
                ),
              ),

            if (_currentPosition != null && !_isLoadingLocation)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(
                      'Ubicación disponible',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

            // ✅ FILTROS DE TIPO DE RESULTADO
            if (_resultadosTotales > 0) _buildFiltrosTipo(),

            // ✅ RESULTADOS DE BÚSQUEDA
            if (_isLoadingBusqueda || isLoadingVehiculos)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (!_isLoadingBusqueda &&
                _resultadosTotales == 0 &&
                _searchText.isNotEmpty)
              _buildSinResultados(),

            if (!_isLoadingBusqueda && _resultadosTotales > 0)
              _buildResultadosCombinados(),

            // ✅ ESTADO INICIAL (sin búsqueda)
            if (!_isLoadingBusqueda && _searchText.isEmpty)
              _buildEstadoInicial(),
          ],
        ),
      ),
    );
  }

  // ✅ ESTADO INICIAL - SIN BÚSQUEDA
  Widget _buildEstadoInicial() {
    return Padding(
      padding: const EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(
            Icons.search_rounded,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Busca empresas o vehículos',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Escribe en la barra de búsqueda para encontrar\nempresas de renta de vehículos o vehículos específicos',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          if (_currentPosition != null)
            ElevatedButton.icon(
              onPressed: _buscarEmpresasCercanas,
              icon: const Icon(Icons.location_on_rounded),
              label: const Text('Buscar empresas cercanas (30km)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[50],
                foregroundColor: Colors.blue[700],
              ),
            ),
        ],
      ),
    );
  }

  // ✅ FILTROS PARA TIPO DE RESULTADO
  Widget _buildFiltrosTipo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          _FiltroTipo(
            texto: 'Todos (${_resultadosTotales})',
            activo: _modoBusqueda == 'todos',
            onTap: () => _cambiarModoBusqueda('todos'),
          ),
          const SizedBox(width: 8),
          _FiltroTipo(
            texto: 'Empresas (${_empresasResultados.length})',
            activo: _modoBusqueda == 'empresas',
            onTap: () => _cambiarModoBusqueda('empresas'),
          ),
          const SizedBox(width: 8),
          _FiltroTipo(
            texto: 'Vehículos (${_vehiculosResultados.length})',
            activo: _modoBusqueda == 'vehiculos',
            onTap: () => _cambiarModoBusqueda('vehiculos'),
          ),
        ],
      ),
    );
  }

  // ✅ SIN RESULTADOS
  Widget _buildSinResultados() {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Column(
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No se encontraron resultados',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta con otros términos de búsqueda',
            style: TextStyle(fontSize: 14, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ✅ RESULTADOS COMBINADOS
  Widget _buildResultadosCombinados() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          // Header de resultados
          Padding(
            padding: const EdgeInsets.only(bottom: 16, top: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$_resultadosTotales resultados para "$_searchText"',
                  style: FlutterFlowTheme.of(context)
                      .titleMedium
                      .copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),

          // ✅ EMPRESAS (si corresponde)
          if ((_modoBusqueda == 'todos' || _modoBusqueda == 'empresas') &&
              _empresasResultados.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_modoBusqueda == 'todos')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Empresas',
                      style: FlutterFlowTheme.of(context)
                          .titleSmall
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ..._empresasResultados
                    .map((empresa) => EmpresaCardCompact(
                          nombre: empresa['nombre'] ?? 'Empresa',
                          direccion:
                              empresa['direccion'] ?? 'Dirección no disponible',
                          imagenUrl: empresa['imagen_perfil'] ??
                              'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=150&h=150&fit=crop&crop=center',
                          distancia: empresa['distancia'],
                          rating: 4.5,
                          totalVehiculos: 0,
                          onTap: () => _navigateToEmpresaProfile(empresa),
                        ))
                    .toList(),
                if (_modoBusqueda == 'todos') const SizedBox(height: 20),
              ],
            ),

          // ✅ VEHÍCULOS (si corresponde)
          if ((_modoBusqueda == 'todos' || _modoBusqueda == 'vehiculos') &&
              _vehiculosResultados.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_modoBusqueda == 'todos')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Vehículos',
                      style: FlutterFlowTheme.of(context)
                          .titleSmall
                          .copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: _vehiculosResultados.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final v = _vehiculosResultados[index];
                    return _buildVehicleCard(v);
                  },
                ),
              ],
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ TARJETA DE VEHÍCULO
  Widget _buildVehicleCard(dynamic v) {
    final imageUrl = v.imagen1?.isNotEmpty == true
        ? v.imagen1!
        : 'https://picsum.photos/800/600?random=${v.id}';

    final vehicleModel = v.titulo ?? '${v.marca} ${v.modelo}';
    final fuelType = v.combustible ?? 'No especificado';
    final transmission = v.transmision ?? 'No especificado';
    final passengerCapacity = v.capacidad ?? 5;
    final year = v.anio?.toString() ?? 'N/A';
    final isRented = v.estado == 'en_renta' ? 'en_renta' : 'disponible';
    final empresaId = v.empresaId ?? '';

    return VehicleCardWidget(
      imageUrl: imageUrl,
      rentalAgency: 'RentaMax',
      rating: 4.5,
      reviewCount: 50,
      distance: 1.2,
      vehicleModel: vehicleModel,
      fuelType: fuelType,
      passengerCapacity: passengerCapacity,
      transmission: transmission,
      pricePerDay: v.precioPorDia,
      onDetailsPressed: () {
        _navigateToVehicleDetails(
          v,
          imageUrl,
          vehicleModel,
          year,
          isRented,
          fuelType,
          transmission,
          passengerCapacity,
          empresaId,
        );
      },
      onCardPressed: () {
        _navigateToVehicleDetails(
          v,
          imageUrl,
          vehicleModel,
          year,
          isRented,
          fuelType,
          transmission,
          passengerCapacity,
          empresaId,
        );
      },
      onFavoritePressed: () {
        print("❤️ Agregar a favoritos: $vehicleModel");
      },
      accentColor: const Color(0xFF0035FF),
      showDistance: true,
    );
  }

  void _navigateToVehicleDetails(
    dynamic v,
    String imageUrl,
    String vehicleModel,
    String year,
    String isRented,
    String fuelType,
    String transmission,
    int passengerCapacity,
    String empresaId,
  ) {
    GoRouter.of(context).push(
      '/auto-details',
      extra: {
        'vehicleId': v.id,
        'vehicleTitle': vehicleModel,
        'vehicleImage': imageUrl,
        'dailyPrice': v.precioPorDia,
        'year': year,
        'isRented': isRented,
        'empresaId': empresaId,
        'brand': v.marca,
        'model': v.modelo,
        'plate': v.placa,
        'color': v.color,
        'fuelType': fuelType,
        'transmission': transmission,
        'passengerCapacity': passengerCapacity,
      },
    );
  }
}

// ✅ WIDGET PARA FILTRO DE TIPO
class _FiltroTipo extends StatelessWidget {
  final String texto;
  final bool activo;
  final VoidCallback onTap;

  const _FiltroTipo({
    required this.texto,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: activo ? const Color(0xFF0035FF) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: activo ? const Color(0xFF0035FF) : Colors.grey[300]!,
          ),
        ),
        child: Text(
          texto,
          style: TextStyle(
            color: activo ? Colors.white : Colors.grey[700],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
