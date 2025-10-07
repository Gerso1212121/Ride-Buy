import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ResumeCardPaycWidgets extends StatelessWidget {
  const ResumeCardPaycWidgets({
    Key? key,
    required this.vehicleImageUrl,
    required this.vehicleName,
    required this.vehicleType,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.paymentMethod,
    required this.totalAmount,
    this.title = 'Resumen de la transacción',
    this.backgroundColor = Colors.white,
    this.borderRadius = 24,
    this.padding = const EdgeInsets.all(8),
    this.contentPadding = const EdgeInsets.all(16),
    this.verticalSpacing = 16,
    this.infoSpacing = 12,
    this.horizontalSpacing = 16,
    this.imageWidth = 80,
    this.imageHeight = 60,
    this.imageBorderRadius = 8,
    this.dividerColor = const Color(0xFFE5E7EB),
    this.titleColor = const Color(0xFF1F2937),
    this.vehicleNameColor = const Color(0xFF1F2937),
    this.vehicleTypeColor = const Color(0xFF6B7280),
    this.labelColor = const Color(0xFF6B7280),
    this.valueColor = const Color(0xFF1F2937),
    this.paymentMethodColor = const Color(0xFF1F2937),
    this.totalLabelColor = const Color(0xFF1F2937),
    this.totalAmountColor = const Color(0xFF10B981),
    this.titleSize = 20,
    this.vehicleNameSize = 18,
    this.vehicleTypeSize = 14,
    this.labelSize = 14,
    this.valueSize = 14,
    this.totalSize = 20,
    this.titleFontWeight = FontWeight.w600,
    this.vehicleNameFontWeight = FontWeight.w600,
    this.vehicleTypeFontWeight = FontWeight.normal,
    this.labelFontWeight = FontWeight.normal,
    this.valueFontWeight = FontWeight.w500,
    this.totalFontWeight = FontWeight.bold,
    this.paymentIcon = Icons.credit_card,
    this.paymentIconSize = 20,
    this.paymentIconColor = const Color(0xFF1F2937),
    this.showShadow = true,
    this.shadowColor = const Color(0x1A000000),
    this.shadowBlurRadius = 10,
    this.shadowOffset = const Offset(0, 2),
  }) : super(key: key);

  final String vehicleImageUrl;
  final String vehicleName;
  final String vehicleType;
  final String startDate;
  final String endDate;
  final String duration;
  final String paymentMethod;
  final String totalAmount;
  final String title;
  final Color backgroundColor;
  final double borderRadius;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry contentPadding;
  final double verticalSpacing;
  final double infoSpacing;
  final double horizontalSpacing;
  final double imageWidth;
  final double imageHeight;
  final double imageBorderRadius;
  final Color dividerColor;
  final Color titleColor;
  final Color vehicleNameColor;
  final Color vehicleTypeColor;
  final Color labelColor;
  final Color valueColor;
  final Color paymentMethodColor;
  final Color totalLabelColor;
  final Color totalAmountColor;
  final double titleSize;
  final double vehicleNameSize;
  final double vehicleTypeSize;
  final double labelSize;
  final double valueSize;
  final double totalSize;
  final FontWeight titleFontWeight;
  final FontWeight vehicleNameFontWeight;
  final FontWeight vehicleTypeFontWeight;
  final FontWeight labelFontWeight;
  final FontWeight valueFontWeight;
  final FontWeight totalFontWeight;
  final IconData paymentIcon;
  final double paymentIconSize;
  final Color paymentIconColor;
  final bool showShadow;
  final Color shadowColor;
  final double shadowBlurRadius;
  final Offset shadowOffset;

  // Método factory para crear instancia con datos de muestra
  factory ResumeCardPaycWidgets.sample() {
    return ResumeCardPaycWidgets(
      vehicleImageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e',
      vehicleName: 'BMW Serie 3 2024',
      vehicleType: 'Sedán Premium',
      startDate: '15 Dic 2024, 10:00 AM',
      endDate: '18 Dic 2024, 10:00 AM',
      duration: '3 días',
      paymentMethod: 'Visa **** 4242',
      totalAmount: '\$2,850.00 MXN',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: backgroundColor,
          boxShadow: showShadow
              ? [
                  BoxShadow(
                    blurRadius: shadowBlurRadius,
                    color: shadowColor,
                    offset: shadowOffset,
                  ),
                ]
              : null,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              _buildTitle(),
              
              SizedBox(height: verticalSpacing),
              
              // Información del vehículo
              _buildVehicleInfo(),
              
              SizedBox(height: verticalSpacing),
              
              // Divider
              _buildDivider(),
              
              SizedBox(height: verticalSpacing),
              
              // Información de fechas y duración
              _buildDateInfo(),
              
              SizedBox(height: verticalSpacing),
              
              // Divider
              _buildDivider(),
              
              SizedBox(height: verticalSpacing),
              
              // Método de pago
              _buildPaymentMethod(),
              
              SizedBox(height: verticalSpacing),
              
              // Total
              _buildTotal(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      title,
      style: TextStyle(
        color: titleColor,
        fontSize: titleSize,
        fontWeight: titleFontWeight,
        letterSpacing: 0.0,
      ),
    );
  }

  Widget _buildVehicleInfo() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        // Imagen del vehículo
        ClipRRect(
          borderRadius: BorderRadius.circular(imageBorderRadius),
          child: CachedNetworkImage(
            fadeInDuration: const Duration(milliseconds: 0),
            fadeOutDuration: const Duration(milliseconds: 0),
            imageUrl: vehicleImageUrl,
            width: imageWidth,
            height: imageHeight,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              width: imageWidth,
              height: imageHeight,
              color: Colors.grey[300],
              child: const Icon(Icons.directions_car, color: Colors.grey),
            ),
            errorWidget: (context, url, error) => Container(
              width: imageWidth,
              height: imageHeight,
              color: Colors.grey[300],
              child: const Icon(Icons.error_outline, color: Colors.grey),
            ),
          ),
        ),
        
        SizedBox(width: horizontalSpacing),
        
        // Información del vehículo - USANDO EXPANDED
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vehicleName,
                style: TextStyle(
                  color: vehicleNameColor,
                  fontSize: vehicleNameSize,
                  fontWeight: vehicleNameFontWeight,
                  letterSpacing: 0.0,
                ),
                maxLines: 2, // Permitir máximo 2 líneas
                overflow: TextOverflow.ellipsis, // Puntos suspensivos si es muy largo
              ),
              const SizedBox(height: 4),
              Text(
                vehicleType,
                style: TextStyle(
                  color: vehicleTypeColor,
                  fontSize: vehicleTypeSize,
                  fontWeight: vehicleTypeFontWeight,
                  letterSpacing: 0.0,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: dividerColor,
    );
  }

  Widget _buildDateInfo() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow(
          label: 'Fecha de inicio',
          value: startDate,
        ),
        SizedBox(height: infoSpacing),
        _buildInfoRow(
          label: 'Fecha de devolución',
          value: endDate,
        ),
        SizedBox(height: infoSpacing),
        _buildInfoRow(
          label: 'Duración',
          value: duration,
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              color: labelColor,
              fontSize: labelSize,
              fontWeight: labelFontWeight,
              letterSpacing: 0.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: valueSize,
              fontWeight: valueFontWeight,
              letterSpacing: 0.0,
            ),
            textAlign: TextAlign.right,
            maxLines: 2, // Permitir 2 líneas para fechas largas
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'Método de pago',
            style: TextStyle(
              color: labelColor,
              fontSize: labelSize,
              fontWeight: labelFontWeight,
              letterSpacing: 0.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                paymentIcon,
                color: paymentIconColor,
                size: paymentIconSize,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  paymentMethod,
                  style: TextStyle(
                    color: paymentMethodColor,
                    fontSize: valueSize,
                    fontWeight: valueFontWeight,
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
    );
  }

  Widget _buildTotal() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            'Total pagado',
            style: TextStyle(
              color: totalLabelColor,
              fontSize: totalSize,
              fontWeight: totalFontWeight,
              letterSpacing: 0.0,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            totalAmount,
            style: TextStyle(
              color: totalAmountColor,
              fontSize: totalSize,
              fontWeight: totalFontWeight,
              letterSpacing: 0.0,
            ),
            textAlign: TextAlign.right,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}