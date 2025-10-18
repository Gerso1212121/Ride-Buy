import 'package:flutter/material.dart';

class SucessPaycWidgets extends StatefulWidget {
  const SucessPaycWidgets({
    Key? key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.check_rounded,
    this.circleColor = const Color(0xFF10B981),
    this.iconColor = Colors.white,
    this.titleColor = const Color(0xFF1F2937),
    this.subtitleColor = const Color(0xFF6B7280),
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.elasticOut,
  }) : super(key: key);

  final String title;
  final String subtitle;
  final IconData icon;
  final Color circleColor;
  final Color iconColor;
  final Color titleColor;
  final Color subtitleColor;
  final Duration animationDuration;
  final Curve animationCurve;

  @override
  State<SucessPaycWidgets> createState() => _SucessPaycWidgetsState();
}

class _SucessPaycWidgetsState extends State<SucessPaycWidgets>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: widget.animationCurve,
      ),
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // Iniciar animación después de que el widget se construya
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 5),
        
        // Círculo con animación
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _opacityAnimation.value,
                child: child,
              ),
            );
          },
          child: _SuccessCircle(
            circleColor: widget.circleColor,
            icon: widget.icon,
            iconColor: widget.iconColor,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Título con animación de fade in
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            );
          },
          child: _SuccessTitle(
            title: widget.title,
            titleColor: widget.titleColor,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Subtítulo con animación de fade in
        AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            );
          },
          child: _SuccessSubtitle(
            subtitle: widget.subtitle,
            subtitleColor: widget.subtitleColor,
          ),
        ),
      ],
    );
  }
}

// Widget separado para el círculo
class _SuccessCircle extends StatelessWidget {
  const _SuccessCircle({
    required this.circleColor,
    required this.icon,
    required this.iconColor,
  });

  final Color circleColor;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: circleColor,
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            color: Color(0x0010B981),
            offset: Offset(0, 4),
          ),
        ],
        shape: BoxShape.circle,
      ),
      child: Align(
        alignment: AlignmentDirectional.center,
        child: Icon(
          icon,
          color: iconColor,
          size: 60,
        ),
      ),
    );
  }
}

// Widget separado para el título
class _SuccessTitle extends StatelessWidget {
  const _SuccessTitle({
    required this.title,
    required this.titleColor,
  });

  final String title;
  final Color titleColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: titleColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.0,
      ),
    );
  }
}

// Widget separado para el subtítulo
class _SuccessSubtitle extends StatelessWidget {
  const _SuccessSubtitle({
    required this.subtitle,
    required this.subtitleColor,
  });

  final String subtitle;
  final Color subtitleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        subtitle,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: subtitleColor,
          fontSize: 16,
          fontWeight: FontWeight.normal,
          letterSpacing: 0.0,
          height: 1.5,
        ),
      ),
    );
  }
}