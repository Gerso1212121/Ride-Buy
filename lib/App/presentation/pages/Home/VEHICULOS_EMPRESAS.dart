// lib/Feature/Empresa_Vehiculos/EmpresaVehiculosScreen.dart
import 'package:ezride/App/DATA/datasources/Auth/vehicle_remote_datasource.dart';
import 'package:ezride/App/DATA/models/Vehiculo_model.dart';
import 'package:ezride/App/DATA/repositories/vehicle_repository_data.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Core/utils/VehicleCacheService.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmpresaVehiculosScreen extends StatefulWidget {
  const EmpresaVehiculosScreen({Key? key}) : super(key: key);

  @override
  State<EmpresaVehiculosScreen> createState() => _EmpresaVehiculosScreenState();
}

class _EmpresaVehiculosScreenState extends State<EmpresaVehiculosScreen> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true;

  List<VehicleModel> _vehicles = [];
  List<VehicleModel> _filteredVehicles = [];
  bool _isLoading = true;
  String _errorMessage = '';

  String _selectedStatus = 'todos';

  final List<Map<String, String>> _statusOptions = [
    {'value': 'todos', 'label': 'Todos los vehículos'},
    {'value': 'disponible', 'label': 'Disponibles'},
    {'value': 'en_renta', 'label': 'En renta'},
    {'value': 'mantenimiento', 'label': 'En mantenimiento'},
    {'value': 'inactivo', 'label': 'Inactivos'},
  ];

  final Map<String, String> _vehicleRealStatus = {};

  @override
  void initState() {
    super.initState();
    _loadDataFromCache();
  }

  Future<void> _loadDataFromCache() async {
    try {
      print('🔄 Cargando datos desde cache global...');
      
      final vehicleData = await VehicleCacheService().getVehicles();
      
      setState(() {
        _vehicles = vehicleData.vehicles;
        _vehicleRealStatus.clear();
        _vehicleRealStatus.addAll(vehicleData.status);
        _applyFilter();
        _isLoading = false;
      });
      
      print('✅ Datos cargados desde cache: ${_vehicles.length} vehículos');
      
    } catch (e) {
      print('❌ Error cargando desde cache: $e');
      _loadEmpresaVehiclesFallback();
    }
  }

  Future<void> _refreshData() async {
    print('🔄 Forzando actualización de datos...');
    
    try {
      setState(() {
        _isLoading = true;
      });

      VehicleCacheService().invalidateCache();
      final vehicleData = await VehicleCacheService().getVehicles();
      
      setState(() {
        _vehicles = vehicleData.vehicles;
        _vehicleRealStatus.clear();
        _vehicleRealStatus.addAll(vehicleData.status);
        _applyFilter();
        _isLoading = false;
      });
      
      print('✅ Datos actualizados: ${_vehicles.length} vehículos');
      
    } catch (e) {
      print('❌ Error actualizando datos: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al actualizar los datos: ${e.toString()}';
      });
    }
  }

  Future<void> _loadEmpresaVehiclesFallback() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final currentEmpresa = SessionManager.currentEmpresa;

      if (currentEmpresa == null) {
        throw Exception('No se encontró información de la empresa');
      }

      print('🏢 Cargando datos directamente (fallback)...');

      final repository = VehicleRepositoryData(VehicleRemoteDataSource());
      final vehicles = await repository.getVehiclesByEmpresa(currentEmpresa.id);

      setState(() {
        _vehicles = vehicles;
      });

      for (final vehicle in _vehicles) {
        final realStatus = await _getVehicleRealStatus(vehicle, repository);
        _vehicleRealStatus[vehicle.id!] = realStatus;
      }

      setState(() {
        _applyFilter();
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar los vehículos: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<String> _getVehicleRealStatus(VehicleModel vehicle, VehicleRepositoryData repository) async {
    try {
      if (vehicle.estado == 'mantenimiento' || vehicle.estado == 'inactivo') {
        return vehicle.estado!;
      }

      final hasActiveRent = await repository.hasActiveRent(vehicle.id!);
      
      final realStatus = hasActiveRent ? 'en_renta' : 'disponible';
      print('🎯 Estado real para ${vehicle.placa}: $realStatus');
      
      return realStatus;
    } catch (e) {
      print('❌ Error verificando estado real para ${vehicle.placa}: $e');
      return vehicle.estado ?? 'disponible';
    }
  }

  void _applyFilter() {
    if (_selectedStatus == 'todos') {
      _filteredVehicles = _vehicles;
    } else {
      _filteredVehicles = _vehicles.where((vehicle) {
        final realStatus = _vehicleRealStatus[vehicle.id!] ?? vehicle.estado;
        return realStatus == _selectedStatus;
      }).toList();
    }
  }

  void _onStatusFilterChanged(String? newValue) {
    if (newValue != null) {
      setState(() {
        _selectedStatus = newValue;
        _applyFilter();
      });
    }
  }

  String _getSelectedFilterLabel() {
    return _statusOptions.firstWhere(
            (option) => option['value'] == _selectedStatus)['label'] ??
        'Todos los vehículos';
  }

  String _getVehicleDisplayStatus(VehicleModel vehicle) {
    return _vehicleRealStatus[vehicle.id!] ?? vehicle.estado ?? 'disponible';
  }

  Widget _buildVehicleCard(VehicleModel vehicle) {
    final displayStatus = _getVehicleDisplayStatus(vehicle);
    final statusColor = _getStatusColor(displayStatus);
    final statusText = _getStatusText(displayStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Stack(
              children: [
                vehicle.imagen1 != null && vehicle.imagen1!.isNotEmpty
                    ? Image.network(
                        vehicle.imagen1!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 200,
                            color: const Color(0xFFF8F9FA),
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                                color: const Color(0xFF007BFF),
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return _buildImagePlaceholder();
                        },
                      )
                    : _buildImagePlaceholder(),

                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),

                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '\$${vehicle.precioPorDia.toStringAsFixed(0)}/día',
                      style: GoogleFonts.lato(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            (vehicle.titulo?.isNotEmpty ?? false)
                                ? vehicle.titulo!
                                : '${vehicle.marca} ${vehicle.modelo}',
                            style: GoogleFonts.lato(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A1A1A),
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (vehicle.anio != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Año ${vehicle.anio}',
                              style: GoogleFonts.lato(
                                fontSize: 14,
                                color: const Color(0xFF666666),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFFE9ECEF),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        vehicle.placa,
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF495057),
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                if (displayStatus != vehicle.estado)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3CD),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFFFEAA7),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: const Color(0xFF856404),
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Estado en sistema: ${_getStatusText(displayStatus)}',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              color: const Color(0xFF856404),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    if (vehicle.capacidad != null) ...[
                      _buildFeatureChip(
                        icon: Icons.people_outlined,
                        text: '${vehicle.capacidad} pers.',
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (vehicle.transmision != null) ...[
                      _buildFeatureChip(
                        icon: Icons.settings_outlined,
                        text: _getTransmissionText(vehicle.transmision!),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (vehicle.puertas != null) ...[
                      _buildFeatureChip(
                        icon: Icons.door_front_door_outlined,
                        text: '${vehicle.puertas} puertas',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureChip({required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: const Color(0xFF6C757D),
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: const Color(0xFF6C757D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      color: const Color(0xFFF8F9FA),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.car_rental,
            size: 48,
            color: const Color(0xFFADB5BD),
          ),
          const SizedBox(height: 8),
          Text(
            'Imagen no disponible',
            style: GoogleFonts.lato(
              fontSize: 12,
              color: const Color(0xFF6C757D),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        'Gestión de Vehículos',
        style: GoogleFonts.lato(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A1A1A),
        ),
      ),
      backgroundColor: Colors.white,
      foregroundColor: const Color(0xFF1A1A1A),
      elevation: 0,
      centerTitle: false,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE9ECEF),
              width: 1,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedStatus,
              onChanged: _onStatusFilterChanged,
              icon: Icon(
                Icons.filter_list_rounded,
                color: const Color(0xFF6C757D),
              ),
              items: _statusOptions.map((option) {
                return DropdownMenuItem<String>(
                  value: option['value'],
                  child: Row(
                    children: [
                      if (option['value'] != 'todos') ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(option['value']),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        option['label']!,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF495057),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              style: GoogleFonts.lato(
                color: const Color(0xFF495057),
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFE9ECEF),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${_filteredVehicles.length} vehículo${_filteredVehicles.length != 1 ? 's' : ''}',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A1A1A),
            ),
          ),
          if (_selectedStatus != 'todos') ...[
            const SizedBox(height: 4),
            Text(
              _getSelectedFilterLabel(),
              style: GoogleFonts.lato(
                fontSize: 14,
                color: const Color(0xFF6C757D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                FlutterFlowTheme.of(context).primary ?? const Color(0xFF007BFF),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Cargando vehículos...',
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF6C757D),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = 'No hay vehículos registrados';
    String subtitle = 'Comienza agregando tu primer vehículo';

    if (_selectedStatus != 'todos' && _vehicles.isNotEmpty) {
      message = 'No hay vehículos con este filtro';
      subtitle = 'Intenta con otro estado o verifica todos los vehículos';
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.car_rental_outlined,
              size: 80,
              color: const Color(0xFFADB5BD),
            ),
            const SizedBox(height: 20),
            Text(
              message,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF495057),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: const Color(0xFF6C757D),
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedStatus != 'todos' && _vehicles.isNotEmpty) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = 'todos';
                    _applyFilter();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF007BFF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Ver todos los vehículos',
                  style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 80,
              color: const Color(0xFFDC3545),
            ),
            const SizedBox(height: 20),
            Text(
              'Error al cargar los vehículos',
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFDC3545),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: const Color(0xFF6C757D),
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshData,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC3545),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Reintentar',
                style: GoogleFonts.lato(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _filteredVehicles.length,
      itemBuilder: (context, index) {
        final vehicle = _filteredVehicles[index];
        return _buildVehicleCard(vehicle);
      },
    );
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'disponible':
        return const Color(0xFF28A745);
      case 'en_renta':
        return const Color(0xFFFFC107);
      case 'mantenimiento':
        return const Color(0xFFDC3545);
      case 'inactivo':
        return const Color(0xFF6C757D);
      default:
        return const Color(0xFF6C757D);
    }
  }

  String _getStatusText(String? status) {
    switch (status) {
      case 'disponible':
        return 'Disponible';
      case 'en_renta':
        return 'En renta';
      case 'mantenimiento':
        return 'Mantenimiento';
      case 'inactivo':
        return 'Inactivo';
      default:
        return 'Desconocido';
    }
  }

  String _getTransmissionText(String transmission) {
    switch (transmission.toLowerCase()) {
      case 'automatica':
        return 'Automática';
      case 'manual':
        return 'Manual';
      default:
        return transmission;
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.white,
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _filteredVehicles.isEmpty
                  ? _buildEmptyState()
                  : RefreshIndicator(
                      onRefresh: _refreshData,
                      backgroundColor: Colors.white,
                      color: const Color(0xFF007BFF),
                      child: Column(
                        children: [
                          _buildCounterHeader(),
                          Expanded(
                            child: _buildVehicleList(),
                          ),
                        ],
                      ),
                    ),
    );
  }
}