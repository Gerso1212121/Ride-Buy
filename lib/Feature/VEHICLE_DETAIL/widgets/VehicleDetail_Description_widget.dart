import 'package:flutter/material.dart';

class DescriptionCarDetailWidgets extends StatefulWidget {
  const DescriptionCarDetailWidgets({
    Key? key,
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
    this.titleColor = Colors.black,
    this.contentColor = const Color(0xFF5A5C60),
    this.titleSize = 18,
    this.contentSize = 14,
    this.titleFontWeight = FontWeight.w600,
    this.contentFontWeight = FontWeight.normal,
    this.verticalSpacing = 12,
    this.iconColor = const Color(0xFF105DFB),
    this.iconSize = 20,
    this.backgroundColor = Colors.transparent,
    this.padding = EdgeInsets.zero,
    this.borderRadius = 12,
    this.elevation = 0,
    this.showCard = false,
  }) : super(key: key);

  final String title;
  final String content;
  final bool initiallyExpanded;
  final Color titleColor;
  final Color contentColor;
  final double titleSize;
  final double contentSize;
  final FontWeight titleFontWeight;
  final FontWeight contentFontWeight;
  final double verticalSpacing;
  final Color iconColor;
  final double iconSize;
  final Color backgroundColor;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double elevation;
  final bool showCard;

  @override
  State<DescriptionCarDetailWidgets> createState() => _DescriptionCarDetailWidgetsState();
}

class _DescriptionCarDetailWidgetsState extends State<DescriptionCarDetailWidgets> 
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
                    size: widget.iconSize,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenido animado
          SizeTransition(
            sizeFactor: _animation,
            child: Padding(
              padding: EdgeInsets.only(top: widget.verticalSpacing),
              child: Text(
                widget.content,
                style: TextStyle(
                  color: widget.contentColor,
                  fontSize: widget.contentSize,
                  fontWeight: widget.contentFontWeight,
                  letterSpacing: 0.0,
                  height: 1.5,
                ),
              ),
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
}