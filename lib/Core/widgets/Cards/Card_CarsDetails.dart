import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:ezride/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleCardWidget extends StatefulWidget {
  final String imageUrl;
  final String rentalAgency;
  final double rating;
  final int reviewCount;
  final double distance;
  final String vehicleModel;
  final String fuelType;
  final int passengerCapacity;
  final String transmission;
  final double pricePerDay;
  final Function()? onDetailsPressed;
  final Function()? onFavoritePressed;
  final Function()? onCardPressed;
  final bool isFavorite;
  final Color accentColor;
  final bool showDistance;

  const VehicleCardWidget({
    super.key,
    required this.imageUrl,
    required this.rentalAgency,
    this.rating = 4.5,
    this.reviewCount = 150,
    this.distance = 2.0,
    required this.vehicleModel,
    required this.fuelType,
    required this.passengerCapacity,
    required this.transmission,
    required this.pricePerDay,
    this.onDetailsPressed,
    this.onFavoritePressed,
    this.onCardPressed,
    this.isFavorite = false,
    this.accentColor = const Color(0xFF0035FF),
    this.showDistance = true,
  });

  @override
  State<VehicleCardWidget> createState() => _VehicleCardWidgetState();
}

class _VehicleCardWidgetState extends State<VehicleCardWidget> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  void _onDetailsPressed() {
    print('Ver detalles del vehículo: ${widget.vehicleModel}');
    widget.onDetailsPressed?.call();
  }

  void _onFavoritePressed() {
    print('Alternando favorito para: ${widget.vehicleModel}');
    setState(() {
      _isFavorite = !_isFavorite;
    });
    widget.onFavoritePressed?.call();
  }

  void _onCardPressed() {
    print('Tarjeta presionada: ${widget.vehicleModel}');
    widget.onCardPressed?.call();
  }

  List<Widget> _buildRatingStars(double rating) {
    List<Widget> stars = [];
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;

    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(
        Icons.star_rounded,
        color: const Color(0xFFFFD700),
        size: 16,
      ));
    }

    if (hasHalfStar) {
      stars.add(Icon(
        Icons.star_half_rounded,
        color: const Color(0xFFFFD700),
        size: 16,
      ));
    }

    int remainingStars = 5 - stars.length;
    for (int i = 0; i < remainingStars; i++) {
      stars.add(Icon(
        Icons.star_border_rounded,
        color: const Color(0xFFFFD700),
        size: 16,
      ));
    }

    return stars;
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0)}';
  }

  String _formatDistance(double distance) {
    return '${distance.toStringAsFixed(0)} km';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return GestureDetector(
      onTap: _onCardPressed,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              blurRadius: 4,
              color: Color(0x1A000000),
              offset: Offset(0, 2),
            )
          ],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Imagen del vehículo
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      widget.imageUrl,
                      width: double.infinity,
                      height: isSmallScreen ? 160 : 200,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: isSmallScreen ? 160 : 200,
                          color: Colors.grey[300],
                          child: Icon(
                            Icons.car_rental,
                            color: Colors.grey[600],
                            size: 40,
                          ),
                        );
                      },
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _onFavoritePressed,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: _isFavorite ? Colors.red : Colors.grey,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              // Contenido de la tarjeta
              Padding(
                padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header con agencia, rating y distancia
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.rentalAgency,
                                style: FlutterFlowTheme.of(context)
                                    .titleMedium
                                    .override(
                                      fontFamily: 'Lato',
                                      fontSize: isSmallScreen ? 14 : 16,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(
                                    0, 4, 0, 0),
                                child: Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    ..._buildRatingStars(widget.rating),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        '${widget.rating} (${widget.reviewCount}+)',
                                        style: FlutterFlowTheme.of(context)
                                            .bodySmall
                                            .override(
                                              fontFamily: 'Lato',
                                              fontSize: isSmallScreen ? 10 : 12,
                                              color:
                                                  FlutterFlowTheme.of(context)
                                                      .secondaryText,
                                              letterSpacing: 0.0,
                                            ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.showDistance) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: isSmallScreen ? 50 : 60,
                            height: isSmallScreen ? 32 : 37.2,
                            decoration: BoxDecoration(
                              color: const Color(0xFF00CB58),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Align(
                              alignment: AlignmentDirectional.center,
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: Text(
                                  _formatDistance(widget.distance),
                                  textAlign: TextAlign.center,
                                  style: FlutterFlowTheme.of(context)
                                      .bodySmall
                                      .override(
                                        fontFamily: 'Lato',
                                        fontSize: isSmallScreen ? 10 : 12,
                                        color: Colors.white,
                                        letterSpacing: 0.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? 6 : 8),

                    // Modelo del vehículo
                    Text(
                      widget.vehicleModel,
                      style: FlutterFlowTheme.of(context).titleLarge.override(
                            fontFamily: 'Lato',
                            fontSize: isSmallScreen ? 16 : 18,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: isSmallScreen ? 6 : 8),

// Fila con características del vehículo y precio
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Características del vehículo (ocupando el espacio disponible)
                        Expanded(
                          child: Wrap(
                            spacing: 2,
                            runSpacing: 8,
                            children: [
                              _buildFeatureItem(
                                Icons.local_gas_station_rounded,
                                widget.fuelType,
                                isSmallScreen,
                              ),
                              _buildFeatureItem(
                                Icons.people_rounded,
                                '${widget.passengerCapacity} pasajeros',
                                isSmallScreen,
                              ),
                              _buildFeatureItem(
                                Icons.settings_rounded,
                                widget.transmission,
                                isSmallScreen,
                              ),
                            ],
                          ),
                        ),

                        SizedBox(width: isSmallScreen ? 8 : 12),

                        // Precio al lado de las características
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatPrice(widget.pricePerDay),
                                style: FlutterFlowTheme.of(context)
                                    .displaySmall
                                    .override(
                                      fontFamily: 'Lato',
                                      fontSize: isSmallScreen ? 20 : 24,
                                      color: widget.accentColor,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'por día',
                                style: FlutterFlowTheme.of(context)
                                    .bodySmall
                                    .override(
                                      fontFamily: 'Lato',
                                      fontSize: isSmallScreen ? 10 : 12,
                                      color: FlutterFlowTheme.of(context)
                                          .secondaryText,
                                      letterSpacing: 0.0,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // Botón de detalles que ocupa todo el ancho
                    FFButtonWidget(
                      onPressed: _onDetailsPressed,
                      text: 'Ver detalles',
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: isSmallScreen ? 44 : 48,
                        padding: EdgeInsetsDirectional.fromSTEB(
                            isSmallScreen ? 16 : 24,
                            0,
                            isSmallScreen ? 16 : 24,
                            0),
                        iconPadding:
                            const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 0),
                        color: widget.accentColor,
                        textStyle:
                            FlutterFlowTheme.of(context).titleSmall.override(
                                  fontFamily: 'Lato',
                                  fontSize: isSmallScreen ? 14 : 16,
                                  color: Colors.white,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w600,
                                ),
                        elevation: 2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para características
  Widget _buildFeatureItem(IconData icon, String text, bool isSmallScreen) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: FlutterFlowTheme.of(context).secondaryText,
            size: isSmallScreen ? 14 : 16,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              text,
              style: FlutterFlowTheme.of(context).bodySmall.override(
                    fontFamily: 'Lato',
                    fontSize: isSmallScreen ? 10 : 12,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    letterSpacing: 0.0,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
