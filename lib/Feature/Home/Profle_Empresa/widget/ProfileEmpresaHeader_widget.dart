import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PerfilHeader extends StatelessWidget {
  final String nombreEmpresa;
  final String descripcion;
  final String? bannerUrl;
  final String? logoUrl;
  final String ubicacion;
  final String? ncr;
  final VoidCallback? onRefreshImages; // ✅ Opcional: recargar imágenes

  const PerfilHeader({
    super.key,
    required this.nombreEmpresa,
    required this.descripcion,
    required this.bannerUrl,
    required this.logoUrl,
    required this.ubicacion,
    this.ncr,
    this.onRefreshImages,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // ✅ BANNER OPTIMIZADO
          _buildBanner(),
          
          const SizedBox(height: 16),

          // ✅ LOGO OPTIMIZADO
          _buildLogo(),

          const SizedBox(height: 16),

          // ✅ INFORMACIÓN DE LA EMPRESA
          _buildCompanyInfo(),

          const SizedBox(height: 20),

          // ✅ UBICACIÓN
          _buildLocationCard(),

          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ✅ BANNER OPTIMIZADO
  Widget _buildBanner() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      child: Stack(
        children: [
          // Banner image or placeholder
          bannerUrl != null && bannerUrl!.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: bannerUrl!,
                  height: 160,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _bannerPlaceholder(),
                  errorWidget: (context, url, error) {
                    print('❌ Error cargando banner: $error');
                    return _bannerPlaceholder();
                  },
                )
              : _bannerPlaceholder(),
          
          // ✅ BOTÓN DE REFRESCAR (solo si hay imágenes y callback)
          if (onRefreshImages != null && (bannerUrl != null || logoUrl != null))
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 18),
                  onPressed: onRefreshImages,
                  tooltip: 'Recargar imágenes',
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ LOGO OPTIMIZADO
  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xFFEFF6FF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: const Color(0xFFE2E8F0),
            width: 3,
          ),
        ),
        child: logoUrl != null && logoUrl!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(17), // 20 - 3 border
                child: CachedNetworkImage(
                  imageUrl: logoUrl!,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _logoPlaceholder(nombreEmpresa),
                  errorWidget: (context, url, error) {
                    print('❌ Error cargando logo: $error');
                    return _logoPlaceholder(nombreEmpresa);
                  },
                ),
              )
            : _logoPlaceholder(nombreEmpresa),
      ),
    );
  }

  // ✅ INFORMACIÓN DE LA EMPRESA
  Widget _buildCompanyInfo() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Nombre de la empresa
          Text(
            nombreEmpresa,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1E293B),
            ),
          ),

          const SizedBox(height: 6),

          // Descripción
          Text(
            descripcion,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: const Color(0xFF64748B),
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          // NCR (si existe)
          if (ncr != null && ncr!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF0F9FF),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFBAE6FD),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.badge, size: 14, color: const Color(0xFF0C4A6E)),
                  const SizedBox(width: 6),
                  Text(
                    'NCR: $ncr',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF0C4A6E),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ✅ TARJETA DE UBICACIÓN MEJORADA
  Widget _buildLocationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: Color(0xFFDBEAFE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_on_rounded,
                color: Color(0xFF2563EB),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ubicación',
                    style: GoogleFonts.manrope(
                      fontSize: 12,
                      color: const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ubicacion,
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      color: const Color(0xFF1E293B),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ BANNER PLACEHOLDER MEJORADO
  Widget _bannerPlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF2563EB), Color(0xFF1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.photo_library_rounded,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Banner de la empresa',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ LOGO PLACEHOLDER MEJORADO
  Widget _logoPlaceholder(String nombre) {
    final iniciales = _getInitials(nombre);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          iniciales,
          style: GoogleFonts.outfit(
            color: const Color(0xFF2563EB),
            fontSize: 32,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Icon(
          Icons.business_rounded,
          color: Color(0xFF2563EB),
          size: 16,
        ),
      ],
    );
  }

  // ✅ OBTENER INICIALES OPTIMIZADO
  String _getInitials(String name) {
    if (name.isEmpty) return "E";
    
    final parts = name.trim().split(" ").where((part) => part.isNotEmpty).toList();
    
    if (parts.isEmpty) return "E";
    if (parts.length == 1) return parts.first[0].toUpperCase();
    
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}