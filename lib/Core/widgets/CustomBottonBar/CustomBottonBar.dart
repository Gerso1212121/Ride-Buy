import 'package:flutter/material.dart';

class BottomBarItem {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final bool showBadge;
  final String? badgeCount;

  BottomBarItem({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.showBadge = false,
    this.badgeCount,
  });
}

class CustomBottomBar extends StatefulWidget {
  const CustomBottomBar({
    Key? key,
    required this.items,
    this.currentIndex = 0,
    this.backgroundColor = Colors.white,
    this.selectedColor = const Color(0xFF3B82F6),
    this.unselectedColor = const Color(0xFF64748B),
    this.height = 90,
    this.buttonSize = 40,
    this.elevation = 8.0,
    this.animationDuration = const Duration(milliseconds: 300),
    this.badgeColor = Colors.red,
    this.badgeTextColor = Colors.white,
  }) : super(key: key);

  final List<BottomBarItem> items;
  final int currentIndex;
  final Color backgroundColor;
  final Color selectedColor;
  final Color unselectedColor;
  final double height;
  final double buttonSize;
  final double elevation;
  final Duration animationDuration;
  final Color badgeColor;
  final Color badgeTextColor;

  @override
  State<CustomBottomBar> createState() => _CustomBottomBarState();
}

class _CustomBottomBarState extends State<CustomBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        boxShadow: [
          BoxShadow(
            blurRadius: widget.elevation,
            color: const Color(0x0F000000),
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(widget.items.length, (index) {
            return _buildTabItem(
              item: widget.items[index],
              index: index,
            );
          }),
        ),
      ),
    );
  }

  Widget _buildTabItem({
    required BottomBarItem item,
    required int index,
  }) {
    final bool isSelected = widget.currentIndex == index;
    final Color color = isSelected ? widget.selectedColor : widget.unselectedColor;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: item.onPressed,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                AnimatedContainer(
                  duration: widget.animationDuration,
                  width: widget.buttonSize,
                  height: widget.buttonSize,
                  decoration: BoxDecoration(
                    color: isSelected ? widget.selectedColor : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected
                        ? Border.all(
                            color: widget.selectedColor.withOpacity(0.2),
                            width: 2,
                          )
                        : null,
                  ),
                  child: Icon(
                    item.icon,
                    color: isSelected ? Colors.white : widget.unselectedColor,
                    size: 24,
                  ),
                ),
                if (item.showBadge)
                  Positioned(
                    top: -4,
                    right: -4,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: widget.badgeColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: widget.backgroundColor,
                          width: 2,
                        ),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        item.badgeCount ?? '',
                        style: TextStyle(
                          color: widget.badgeTextColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: widget.animationDuration,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              child: Text(
                item.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}