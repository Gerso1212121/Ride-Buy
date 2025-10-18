import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ParajaxCardetailwidgets extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double parallaxOffset;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Alignment imageAlignment;

  const ParajaxCardetailwidgets({
    Key? key,
    required this.imageUrl,
    this.height = 250,
    this.parallaxOffset = 0.0,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.imageAlignment = Alignment.center,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Imagen de fondo con efecto parallax suavizado
          _buildParallaxImage(),
          
          // Overlay oscuro gradiente (opcional, para mejorar legibilidad si luego agregas contenido)
          _buildDarkOverlay(),
        ],
      ),
    );
  }

  Widget _buildParallaxImage() {
    return Transform.translate(
      offset: Offset(0, parallaxOffset * 0.3), // Efecto parallax suavizado
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: fit,
              alignment: imageAlignment,
              placeholder: (context, url) => 
                  placeholder ?? _buildDefaultPlaceholder(),
              errorWidget: (context, url, error) => 
                  errorWidget ?? _buildDefaultErrorWidget(),
            )
          : _buildDefaultPlaceholder(),
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
            Color.fromARGB(60, 0, 0, 0), // Overlay muy suave
          ],
          stops: [0.6, 1.0],
        ),
      ),
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.blueGrey[100],
      child: const Icon(
        Icons.directions_car_rounded,
        color: Colors.blueGrey,
        size: 60,
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Icon(
        Icons.error_outline,
        color: Colors.grey,
        size: 50,
      ),
    );
  }
}