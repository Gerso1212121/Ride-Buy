import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ParallaxProfileHeader extends StatelessWidget {
  final String backgroundImageUrl;
  final String profileImageUrl;
  final String businessName;
  final String businessType;
  final VoidCallback onBackPressed;
  final double height;
  final double parallaxOffset;
  final double avatarSize;

  const ParallaxProfileHeader({
    Key? key,
    required this.backgroundImageUrl,
    required this.profileImageUrl,
    required this.businessName,
    required this.businessType,
    required this.onBackPressed,
    this.height = 250,
    this.parallaxOffset = 0.0,
    this.avatarSize = 80,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Fondo con imagen - PARALLAX SUAVIZADO
          _buildBackgroundWithParallax(),
          
          // Overlay oscuro (SIN PARALLAX - optimizado)
          _buildDarkOverlay(),
          
          // Contenido (Avatar + Texto) - PARALLAX SUAVIZADO
          _buildProfileContentWithParallax(context),
          
          // Botón de volver (SIN PARALLAX - fijo)
          _buildBackButton(context),
        ],
      ),
    );
  }

  Widget _buildBackgroundWithParallax() {
    return Transform.translate(
      offset: Offset(0, parallaxOffset * 0.3), // ✅ REDUCIDO de 0.5 a 0.3
      child: backgroundImageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: backgroundImageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildPlaceholder(),
              errorWidget: (context, url, error) => _buildPlaceholder(),
            )
          : _buildPlaceholder(),
    );
  }

  Widget _buildDarkOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(0, 0, 0, 0),
            Color.fromARGB(188, 0, 0, 0),
          ],
          stops: [0.3, 1.0],
        ),
      ),
    );
  }

  Widget _buildProfileContentWithParallax(BuildContext context) {
    // ✅ CALCULO SIMPLIFICADO - menos operaciones matemáticas
    final double contentOffset = (parallaxOffset * 0.5).clamp(-30.0, 0.0);
    
    return Positioned(
      bottom: 20 + contentOffset, // ✅ UN solo cálculo
      left: 16,
      right: 16,
      child: _buildProfileContent(context),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 16,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.5),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 20,
          ),
          onPressed: onBackPressed,
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Avatar
        Container(
          width: avatarSize,
          height: avatarSize,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(avatarSize / 2),
            child: profileImageUrl.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: profileImageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildAvatarPlaceholder(),
                    errorWidget: (context, url, error) => _buildAvatarPlaceholder(),
                  )
                : _buildAvatarPlaceholder(),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Texto
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                businessName,
                style: GoogleFonts.lato(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                businessType,
                style: GoogleFonts.lato(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  shadows: [
                    Shadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 4,
                      offset: const Offset(1, 1),
                    ),
                  ],
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

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.blueGrey[800],
      child: const Icon(
        Icons.directions_car_rounded,
        color: Colors.white,
        size: 80,
      ),
    );
  }

  Widget _buildAvatarPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        color: Colors.grey[600],
        size: avatarSize * 0.5,
      ),
    );
  }
}