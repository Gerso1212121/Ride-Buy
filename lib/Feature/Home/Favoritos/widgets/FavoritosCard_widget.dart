import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleFavCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String description;
  final String price;
  final VoidCallback onFavoritePressed;
  final VoidCallback onDetailsPressed;
  final bool isFavorite;
  final double imageWidth;
  final double imageHeight;
  final EdgeInsets padding;

  const VehicleFavCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.onFavoritePressed,
    required this.onDetailsPressed,
    this.isFavorite = false,
    this.imageWidth = 120,
    this.imageHeight = 90,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 375;
    final isLargeScreen = screenWidth > 600;

    return Padding(
      padding: padding,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF014ECF).withOpacity(0.15),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onDetailsPressed,
          child: Padding(
            padding: isSmallScreen 
                ? const EdgeInsets.all(12)
                : const EdgeInsets.all(14),
            child: isSmallScreen 
                ? _buildSmallLayout(context, isSmallScreen)
                : _buildNormalLayout(context, isLargeScreen),
          ),
        ),
      ),
    );
  }

  Widget _buildNormalLayout(BuildContext context, bool isLargeScreen) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _buildVehicleImage(context, isLargeScreen),
        SizedBox(width: isLargeScreen ? 16 : 12),
        Expanded(
          child: _buildVehicleInfo(context, isLargeScreen),
        ),
      ],
    );
  }

  Widget _buildSmallLayout(BuildContext context, bool isSmallScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVehicleImage(context, isSmallScreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTitleRow(context),
                  const SizedBox(height: 4),
                  _buildSubtitle(context),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildDescription(context),
        const SizedBox(height: 12),
        _buildBottomRow(context),
      ],
    );
  }

  Widget _buildVehicleImage(BuildContext context, bool isLarge) {
    final screenWidth = MediaQuery.of(context).size.width;
    final size = isLarge ? 140.0 : screenWidth < 340 ? 90.0 : 110.0;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        width: size,
        height: size * 0.75,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: size,
          height: size * 0.75,
          decoration: BoxDecoration(
            color: const Color(0xFF014ECF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.directions_car_rounded,
            color: const Color(0xFF014ECF).withOpacity(0.6),
            size: 28,
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: size,
          height: size * 0.75,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.error_outline_rounded,
            color: Colors.grey.shade400,
            size: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleInfo(BuildContext context, bool isLargeScreen) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTitleRow(context),
        const SizedBox(height: 4),
        _buildSubtitle(context),
        const SizedBox(height: 8),
        _buildDescription(context),
        const SizedBox(height: 12),
        _buildBottomRow(context),
      ],
    );
  }

  Widget _buildTitleRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.figtree(
              fontSize: screenWidth < 340 ? 14 : 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A1A),
              letterSpacing: 0.0,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        _buildFavoriteButton(),
      ],
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Text(
      subtitle,
      style: GoogleFonts.figtree(
        fontSize: screenWidth < 340 ? 11 : 13,
        color: const Color(0xFF014ECF).withOpacity(0.8),
        fontWeight: FontWeight.w500,
        letterSpacing: 0.0,
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Text(
      description,
      style: GoogleFonts.figtree(
        fontSize: screenWidth < 340 ? 11 : 13,
        color: const Color(0xFF666666),
        letterSpacing: 0.0,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildBottomRow(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 340;
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          price,
          style: GoogleFonts.figtree(
            fontSize: isVerySmall ? 13 : 15,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF014ECF),
            letterSpacing: 0.0,
          ),
        ),
        _buildDetailsButton(context),
      ],
    );
  }

  Widget _buildFavoriteButton() {
    return InkWell(
      onTap: onFavoritePressed,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: isFavorite
              ? const Color(0xFF014ECF).withOpacity(0.15)
              : const Color(0xFFF5F5F5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isFavorite ? const Color(0xFF014ECF) : const Color(0xFF999999),
          size: 18,
        ),
      ),
    );
  }

  Widget _buildDetailsButton(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isVerySmall = screenWidth < 340;
    
    return ElevatedButton(
      onPressed: onDetailsPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF014ECF),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: isVerySmall ? 10 : 14,
          vertical: isVerySmall ? 6 : 8,
        ),
        textStyle: GoogleFonts.figtree(
          fontSize: isVerySmall ? 11 : 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.0,
        ),
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(isVerySmall ? 'Ver' : 'Detalles'),
    );
  }
}