import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ParallaxCarDetailWidget extends StatelessWidget {
  final String imageUrl;
  final double height;
  final double parallaxOffset;
  final BoxFit fit;
  final Alignment alignment;
  final bool showOverlay;
  final Gradient? overlayGradient;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;

  const ParallaxCarDetailWidget({
    Key? key,
    required this.imageUrl,
    this.height = 250,
    this.parallaxOffset = 0.0,
    this.fit = BoxFit.cover,
    this.alignment = Alignment.center,
    this.showOverlay = true,
    this.overlayGradient,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _buildParallaxImage(),
            if (showOverlay) _buildOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildParallaxImage() {
    // Usamos AnimatedPositioned para evitar re-renders completos
    return Positioned.fill(
      top: parallaxOffset * 0.25,
      bottom: -parallaxOffset * 0.25,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        alignment: alignment,
        placeholder: (context, url) => placeholder ?? _defaultPlaceholder(),
        errorWidget: (context, url, error) => errorWidget ?? _defaultErrorWidget(),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: BoxDecoration(
        gradient: overlayGradient ??
            const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(0, 0, 0, 0),
                Color.fromARGB(80, 0, 0, 0),
              ],
              stops: [0.6, 1.0],
            ),
      ),
    );
  }

  Widget _defaultPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.directions_car_filled_rounded,
          color: Colors.grey,
          size: 60,
        ),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.error_outline_rounded,
          color: Colors.redAccent,
          size: 50,
        ),
      ),
    );
  }
}
