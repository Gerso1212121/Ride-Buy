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
  final String vehicleTitle;
  final String vehicleImage;
  final double dailyPrice;
  final String year;
  final String isRented;

  const VehicleDetailScreen({
    Key? key,
    required this.vehicleId,
    required this.vehicleTitle,
    required this.vehicleImage,
    required this.dailyPrice,
    required this.year,
    required this.isRented,
  }) : super(key: key);

  @override
  State<VehicleDetailScreen> createState() => _VehicleDetailScreenState();
}

class _VehicleDetailScreenState extends State<VehicleDetailScreen> {
  final ScrollController _scrollController = ScrollController();
  double _parallaxOffset = 0.0;
  bool _isFavorite = false;

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

  void _onRentPressed() {
    if (widget.isRented == 'en_renta') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Este vehículo ya está rentado 🚫')),
      );
      return;
    }

    GoRouter.of(context).push(
      '/rent-vehicle',
      extra: {
        'vehicleId': widget.vehicleId,
        'vehicleName': widget.vehicleTitle,
        'vehicleType': 'Auto',
        'vehicleImageUrl': widget.vehicleImage,
        'dailyPrice': widget.dailyPrice,
      },
    );
  }

  final List<VehicleFeature> _vehicleSpecs = const [
    VehicleFeature(icon: Icons.local_gas_station, text: 'Gasolina'),
    VehicleFeature(icon: Icons.settings, text: 'Automática'),
    VehicleFeature(icon: Icons.people, text: '5 Pasajeros'),
    VehicleFeature(icon: Icons.car_rental, text: 'A/C'),
  ];

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
                                : "Disponible",
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
                            features: [
                              "Bluetooth",
                              "Pantalla táctil",
                              "Sensores de parqueo",
                              "Cámara de reversa",
                              "Apple CarPlay / Android Auto",
                            ],
                            showCard: true,
                            borderRadius: 16,
                            elevation: 2,
                            maxVisibleFeatures: 4,
                          ),
                          const SizedBox(height: 24),
                          DescriptionCarDetailWidgets(
                            title: 'Descripción',
                            content:
                                "Vehículo en excelente estado, perfecto para viajes y ciudad.",
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
              onRentPressed: _onRentPressed,
              buttonText: widget.isRented == 'en_renta'
                  ? "No disponible"
                  : "Rentar Ahora",
            ),
          ),
        ],
      ),
    );
  }
}