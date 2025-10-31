import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_AppBar_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_BackgroundImage_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_BottomBar_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_CardInfo_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_Description_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_Features_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_Info_widget.dart';
import 'package:ezride/Feature/VEHICLE_DETAIL/widgets/VehicleDetail_Title_widget.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VehicleDetailScreen extends StatefulWidget {
  final String vehicleId;

  const VehicleDetailScreen({
    Key? key,
    required this.vehicleId,
  }) : super(key: key);

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _parallaxOffset = 0.0;
  bool _isFavorite = false;

  // Datos de ejemplo del vehículo
  final Map<String, dynamic> _vehicleData = {
    'id': '1',
    'title': 'BMW X5 2024',
    'tag': 'SUV Premium',
    'year': '2024',
    'price': '\$89',
    'period': 'día',
    'imageUrl': 'https://images.unsplash.com/photo-1555215695-3004980ad54e',
    'description':
        'El BMW X5 2024 combina lujo y rendimiento en un SUV premium. Con su diseño elegante y tecnología de vanguardia, ofrece una experiencia de conducción excepcional. Equipado con un motor turbocharged de 6 cilindros y transmisión automática de 8 velocidades, proporciona un rendimiento suave y potente.',
    'features': [
      'Asientos de cuero ventilados',
      'Sistema de sonido Harman Kardon',
      'Pantalla táctil de 12.3"',
      'Control de crucero adaptativo',
      'Asistente de estacionamiento',
      'Cámara 360°',
      'Apple CarPlay & Android Auto',
      'Techo panorámico',
      'Climatizador de 4 zonas',
      'Llave inteligente',
    ],
  };

  // Especificaciones técnicas
  final List<VehicleFeature> _vehicleSpecs = [
    const VehicleFeature(
      icon: Icons.local_gas_station,
      text: 'Híbrido',
    ),
    const VehicleFeature(
      icon: Icons.settings,
      text: 'Automática',
    ),
    const VehicleFeature(
      icon: Icons.people,
      text: '5 Pasajeros',
    ),
    const VehicleFeature(
      icon: Icons.ac_unit,
      text: 'Aire Acond.',
    ),
  ];

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
    // Aquí iría la lógica para guardar en favoritos
    print('Favorite status: $_isFavorite');
  }

  void _onRentPressed() {
    // Navegar a pantalla de reserva
    GoRouter.of(context).push('/rent-vehicle');

    // Navigator.push(context, MaterialPageRoute(builder: (_) => RentScreen(vehicleId: widget.vehicleId)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Contenido principal con scroll
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // SliverAppBar con efecto parallax
              SliverAppBar(
                expandedHeight: 300,
                flexibleSpace: FlexibleSpaceBar(
                  background: ParallaxCarDetailWidget(
                    imageUrl: _vehicleData['imageUrl'],
                    height: 300,
                    parallaxOffset: _parallaxOffset,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: Container(), // Ocultar el leading por defecto
                // Usaremos nuestro AppBar personalizado en overlay
              ),

              // Contenido de detalles del vehículo
              SliverList(
                delegate: SliverChildListDelegate([
                  // Contenedor blanco para el contenido
                  Container(
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título y precio
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TitleCarDetailwidgets(
                                title: _vehicleData['title'],
                                tag: _vehicleData['tag'],
                                year: _vehicleData['year'],
                              ),
                              const SizedBox(height: 16),
                              Info_CarDetailwidgets(
                                price: _vehicleData['price'],
                                period: _vehicleData['period'],
                                isFavorite: _isFavorite,
                                onFavoritePressed: _onFavoritePressed,
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // Card de información técnica
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

                          // Características del vehículo
                          FeaturesCarDetailWidgets(
                            title: 'Características',
                            features: _vehicleData['features'],
                            initiallyExpanded: false,
                            showCard: true,
                            backgroundColor: Colors.white,
                            titleColor: const Color(0xFF1E293B),
                            featureColor: const Color(0xFF64748B),
                            iconColor: const Color(0xFF10B981),
                            borderRadius: 16,
                            elevation: 2,
                            maxVisibleFeatures: 4,
                          ),

                          const SizedBox(height: 24),

                          // Descripción del vehículo
                          DescriptionCarDetailWidgets(
                            title: 'Descripción',
                            content: _vehicleData['description'],
                            initiallyExpanded: false,
                            showCard: true,
                            backgroundColor: Colors.white,
                            titleColor: const Color(0xFF1E293B),
                            contentColor: const Color(0xFF64748B),
                            borderRadius: 16,
                            elevation: 2,
                          ),

                          // Espacio extra para evitar que el contenido quede detrás de la bottom bar
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ],
          ),

          // AppBar personalizado overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AppBarCarDetailwidgets(
              onBackPressed: _onBackPressed,
              onFavoritePressed: _onFavoritePressed,
              isFavorite: _isFavorite,
              backgroundColor: Colors.transparent,
              elevation: 0,
              backIconColor: Colors.white,
              favoriteIconColor: Colors.white,
              backButtonColor: Colors.black54,
              showShadow: false,
            ),
          ),

          // Bottom Bar fija
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomBarCardetailwidgets(
              price: _vehicleData['price'],
              period: _vehicleData['period'],
              onRentPressed: _onRentPressed,
              label: 'Total estimado',
              buttonText: 'Rentar Ahora',
              backgroundColor: Colors.white,
              shadowColor: const Color(0x1A000000),
              labelColor: const Color(0xFF64748B),
              priceColor: const Color(0xFF3B82F6),
              periodColor: const Color(0xFF64748B),
              buttonColor: const Color(0xFF3B82F6),
              buttonTextColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
