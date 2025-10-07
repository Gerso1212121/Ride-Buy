import 'package:flutter/material.dart';

class FeaturesCarDetailWidgets extends StatefulWidget {
  const FeaturesCarDetailWidgets({
    Key? key,
    required this.title,
    required this.features,
    this.initiallyExpanded = false,
    this.titleColor = Colors.black,
    this.featureColor = const Color(0xFF5A5C60),
    this.iconColor = const Color(0xFF02CA79),
    this.titleSize = 18,
    this.featureSize = 14,
    this.titleFontWeight = FontWeight.w600,
    this.featureFontWeight = FontWeight.normal,
    this.verticalSpacing = 12,
    this.featureSpacing = 8,
    this.iconSize = 16,
    this.backgroundColor = Colors.transparent,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 12,
    this.elevation = 0,
    this.showCard = false,
    this.maxVisibleFeatures = 3, // Número de features visibles cuando está contraído
  }) : super(key: key);

  final String title;
  final List<String> features;
  final bool initiallyExpanded;
  final Color titleColor;
  final Color featureColor;
  final Color iconColor;
  final double titleSize;
  final double featureSize;
  final FontWeight titleFontWeight;
  final FontWeight featureFontWeight;
  final double verticalSpacing;
  final double featureSpacing;
  final double iconSize;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final bool showCard;
  final int maxVisibleFeatures;

  @override
  State<FeaturesCarDetailWidgets> createState() => _FeaturesCarDetailWidgetsState();
}

class _FeaturesCarDetailWidgetsState extends State<FeaturesCarDetailWidgets> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
    
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    
    if (_isExpanded) {
      _controller.value = 1.0;
    }
  }

  void _toggleExpansion() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visibleFeatures = _isExpanded 
        ? widget.features 
        : widget.features.take(widget.maxVisibleFeatures).toList();

    final content = Container(
      decoration: widget.showCard
          ? BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(widget.borderRadius),
              boxShadow: [
                BoxShadow(
                  blurRadius: widget.elevation,
                  color: Colors.black.withOpacity(0.1),
                  offset: const Offset(0, 2),
                ),
              ],
            )
          : null,
      padding: widget.showCard ? const EdgeInsets.all(16) : widget.padding,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado
          GestureDetector(
            onTap: _toggleExpansion,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    color: widget.titleColor,
                    fontSize: widget.titleSize,
                    fontWeight: widget.titleFontWeight,
                    letterSpacing: 0.0,
                  ),
                ),
                RotationTransition(
                  turns: Tween(begin: 0.0, end: 0.5).animate(_animation),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: widget.iconColor,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
          
          SizedBox(height: widget.verticalSpacing),
          
          // Lista de características animada
          SizeTransition(
            sizeFactor: _animation,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Features visibles
                ..._buildFeatureList(visibleFeatures),
                
                // Indicador de features adicionales (cuando está contraído)
                if (!_isExpanded && widget.features.length > widget.maxVisibleFeatures) ...[
                  SizedBox(height: widget.featureSpacing),
                  Text(
                    '+${widget.features.length - widget.maxVisibleFeatures} características más',
                    style: TextStyle(
                      color: widget.featureColor.withOpacity(0.7),
                      fontSize: widget.featureSize - 1,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return widget.showCard ? content : Container(
      color: widget.backgroundColor,
      child: content,
    );
  }

  List<Widget> _buildFeatureList(List<String> features) {
    return features.asMap().entries.map((entry) {
      final index = entry.key;
      final feature = entry.value;
      
      return Padding(
        padding: EdgeInsets.only(bottom: index < features.length - 1 ? widget.featureSpacing : 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: widget.iconColor,
              size: widget.iconSize,
            ),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                feature,
                style: TextStyle(
                  color: widget.featureColor,
                  fontSize: widget.featureSize,
                  fontWeight: widget.featureFontWeight,
                  letterSpacing: 0.0,
                ),
              ),
            ),
          ],
        ),
      );
    }).toList();
  }
}