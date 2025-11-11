import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_AppBar_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_BackgroundImage_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_BottomBar_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_CardInfo_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_Description_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_Features_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_Info_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_Title_widget.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;
  final String vehicleTitle;
  final String vehicleImage;
  final double dailyPrice;
  final String year;
  final String isRented;
  final String empresaId;
  final String brand;
  final String model;
  final String plate;
  final String color;
  final String fuelType;
  final String transmission;
  final int passengerCapacity;

  const VehicleDetailScreen({
    Key? key,
    required this.vehicleId,
    required this.vehicleTitle,
    required this.vehicleImage,
    required this.dailyPrice,
    required this.year,
    required this.isRented,
    required this.empresaId,
    required this.brand,
    required this.model,
    required this.plate,
    required this.color,
    required this.fuelType,
    required this.transmission,
    required this.passengerCapacity,
  }) : super(key: key);

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _parallaxOffset = 0.0;
  bool _isFavorite = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateParallax);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateParallax);
    _scrollController.dispose();
    super.dispose();
  }

  void _updateParallax() {
    setState(() {
      _parallaxOffset = -_scrollController.offset * 0.4;
    });
  }

  void _onBackPressed() {
    Navigator.of(context).pop();
  }

  void _onFavoritePressed() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
  }

  // ✅ MÉTODO MODIFICADO: Usar empresaId directamente si está disponible
  void _onRentPressed() {
    // ✅ VERIFICAR ESTADO ACTUAL DEL VEHÍCULO
    if (widget.isRented != 'disponible') {
      String mensaje = '';
      switch (widget.isRented) {
        case 'en_renta':
          mensaje = 'Este vehículo está actualmente rentado 🚗';
          break;
        case 'mantenimiento':
          mensaje = 'Este vehículo está en mantenimiento 🔧';
          break;
        case 'reservado':
          mensaje = 'Este vehículo está reservado 📅';
          break;
        default:
          mensaje = 'Este vehículo no está disponible 🚫';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    // ✅ VERIFICAR SI YA TENEMOS EMPRESA_ID
    if (widget.empresaId.isNotEmpty) {
      _navegarARenta(widget.empresaId);
    } else {
      _obtenerEmpresaIdDelVehiculo(widget.vehicleId);
    }
  }

  // ✅ NUEVO MÉTODO: Navegar directamente si ya tenemos empresaId
  void _navegarARenta(String empresaId) {
    GoRouter.of(context).push(
      '/rent-vehicle',
      extra: {
        'vehicleId': widget.vehicleId,
        'vehicleName': widget.vehicleTitle,
        'vehicleType': 'Auto',
        'vehicleImageUrl': widget.vehicleImage,
        'dailyPrice': widget.dailyPrice,
        'empresaId': empresaId,
      },
    );
  }

  // ✅ MÉTODO MODIFICADO: Manejar mejor el estado de carga
  void _obtenerEmpresaIdDelVehiculo(String vehicleId) async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('🔍 Buscando empresa_id para vehículo: $vehicleId');

      const sql = '''
        SELECT empresa_id 
        FROM public.vehiculos 
        WHERE id = @vehicle_id;
      ''';

      final result = await RenderDbClient.query(sql, parameters: {
        'vehicle_id': vehicleId,
      });

      print('📊 Resultado de consulta: ${result.length} registros');

      if (result.isEmpty) {
        throw Exception('No se pudo encontrar información del vehículo');
      }

      final empresaId = result.first['empresa_id'] as String?;
      
      if (empresaId == null || empresaId.isEmpty) {
        throw Exception('El vehículo no tiene una empresa asociada');
      }

      print('✅ Empresa ID encontrado: $empresaId');

      // ✅ NAVEGAR CON EL EMPRESA_ID OBTENIDO
      _navegarARenta(empresaId);

    } catch (e) {
      print('❌ Error obteniendo empresa_id: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al obtener datos del vehículo: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // ✅ MÉTODO AUXILIAR: Función que no hace nada (para cuando está cargando)
  void _doNothing() {
    // No hacer nada - usado cuando el botón está deshabilitado
  }

  // ✅ MÉTODO PARA CONSTRUIR ESPECIFICACIONES DINÁMICAS
  List<VehicleFeature> get _vehicleSpecs {
    return [
      VehicleFeature(
        icon: Icons.local_gas_station, 
        text: _capitalizeFirst(widget.fuelType) ?? 'Gasolina'
      ),
      VehicleFeature(
        icon: Icons.settings, 
        text: _capitalizeFirst(widget.transmission) ?? 'Automática'
      ),
      VehicleFeature(
        icon: Icons.people, 
        text: '${widget.passengerCapacity} Pasajeros'
      ),
      VehicleFeature(
        icon: Icons.color_lens, 
        text: _capitalizeFirst(widget.color) ?? 'Gris'
      ),
      VehicleFeature(
        icon: Icons.confirmation_number, 
        text: 'Placa: ${widget.plate}'
      ),
    ];
  }

  // ✅ MÉTODO PARA CAPITALIZAR TEXTO
  String? _capitalizeFirst(String? text) {
    if (text == null || text.isEmpty) return null;
    return text[0].toUpperCase() + text.substring(1);
  }

  // ✅ MÉTODO PARA CONSTRUIR CARACTERÍSTICAS DINÁMICAS
  List<String> get _vehicleFeatures {
    final features = <String>[];
    
    // Agregar características basadas en los datos reales
    if (widget.brand.isNotEmpty && widget.model.isNotEmpty) {
      features.add('${_capitalizeFirst(widget.brand)} ${_capitalizeFirst(widget.model)}');
    }
    
    if (widget.year != 'N/A') {
      features.add('Año ${widget.year}');
    }
    
    features.add('Transmisión ${_capitalizeFirst(widget.transmission) ?? 'Automática'}');
    features.add('Combustible ${_capitalizeFirst(widget.fuelType) ?? 'Gasolina'}');
    features.add('${widget.passengerCapacity} Pasajeros');
    features.add('Color ${_capitalizeFirst(widget.color) ?? 'Gris'}');
    
    // Características adicionales (puedes obtenerlas de tu modelo si están disponibles)
    features.addAll([
      "Aire Acondicionado",
      "Bluetooth",
      "Seguro incluido",
    ]);
    
    return features;
  }

  // ✅ MÉTODO PARA CONSTRUIR DESCRIPCIÓN DINÁMICA
  String get _vehicleDescription {
    final desc = StringBuffer();
    
    desc.write('Vehículo ${_capitalizeFirst(widget.brand) ?? ''} ${_capitalizeFirst(widget.model) ?? ''} ');
    desc.write('en excelente estado. ');
    
    if (widget.year != 'N/A') {
      desc.write('Modelo ${widget.year}. ');
    }
    
    desc.write('Transmisión ${_capitalizeFirst(widget.transmission) ?? 'automática'}. ');
    desc.write('Combustible: ${_capitalizeFirst(widget.fuelType) ?? 'gasolina'}. ');
    desc.write('Capacidad para ${widget.passengerCapacity} pasajeros. ');
    desc.write('Color ${_capitalizeFirst(widget.color) ?? 'gris'}. ');
    desc.write('Perfecto para viajes familiares y uso en ciudad.');
    
    return desc.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: ParallaxCarDetailWidget(
                    imageUrl: widget.vehicleImage,
                    height: 300,
                    parallaxOffset: _parallaxOffset,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TitleCarDetailwidgets(
                            title: widget.vehicleTitle,
                            tag: widget.isRented == 'en_renta'
                                ? "Rentado"
                                : (widget.isRented == 'reservado' 
                                    ? "Reservado" 
                                    : "Disponible"),
                            year: widget.year,
                          ),
                          const SizedBox(height: 16),
                          Info_CarDetailwidgets(
                            price: '\$${widget.dailyPrice.toStringAsFixed(2)}',
                            period: 'día',
                            isFavorite: _isFavorite,
                            onFavoritePressed: _onFavoritePressed,
                          ),
                          const SizedBox(height: 24),
                          InfoCard(
                            title: 'Especificaciones',
                            features: _vehicleSpecs,
                            backgroundColor: const Color(0xFFF8FAFC),
                            titleColor: const Color(0xFF1E293B),
                            iconColor: const Color(0xFF3B82F6),
                            textColor: const Color(0xFF64748B),
                            borderRadius: 16,
                            padding: const EdgeInsets.all(20),
                            verticalSpacing: 16,
                          ),
                          const SizedBox(height: 24),
                          FeaturesCarDetailWidgets(
                            title: 'Características',
                            features: _vehicleFeatures,
                            showCard: true,
                            borderRadius: 16,
                            elevation: 2,
                            maxVisibleFeatures: 6,
                          ),
                          const SizedBox(height: 24),
                          DescriptionCarDetailWidgets(
                            title: 'Descripción',
                            content: _vehicleDescription,
                            showCard: true,
                            borderRadius: 16,
                            elevation: 2,
                          ),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarCarDetailwidgets(
              onBackPressed: _onBackPressed,
              onFavoritePressed: _onFavoritePressed,
              isFavorite: _isFavorite,
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomBarCardetailwidgets(
              price: '\$${widget.dailyPrice.toStringAsFixed(2)}',
              period: 'día',
              onRentPressed: _isLoading ? _doNothing : _onRentPressed,
              buttonText: _isLoading 
                  ? "Cargando..." 
                  : (widget.isRented != 'disponible'
                      ? "No disponible"
                      : "Rentar Ahora"),
            ),
          ),
          
          // ✅ Mostrar indicador de carga
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}