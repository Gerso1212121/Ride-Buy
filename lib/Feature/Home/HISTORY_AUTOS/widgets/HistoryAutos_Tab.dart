import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';

class LiquidTabBar extends StatefulWidget {
  final List<String> tabLabels;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final double height;
  final double tabWidth;
  final double tabHeight;

  const LiquidTabBar({
    Key? key,
    required this.tabLabels,
    required this.selectedIndex,
    required this.onTabSelected,
    this.height = 70, // Aumentado significativamente
    this.tabWidth = 100,
    this.tabHeight = 40, // Aumentado significativamente
  }) : super(key: key);

  @override
  _LiquidTabBarState createState() => _LiquidTabBarState();
}

class _LiquidTabBarState extends State<LiquidTabBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
      ),
      child: Padding(
        padding: EdgeInsets.all(10), // Aumentado el padding
        child: LayoutBuilder(
          builder: (context, constraints) {
            final availableWidth = constraints.maxWidth;
            final tabCount = widget.tabLabels.length;
            final tabWidth = availableWidth / tabCount;

            return Stack(
              children: [
                // Fondo líquido animado AZUL
                AnimatedPositioned(
                  duration: Duration(milliseconds: 300),
                  curve: Curves.fastOutSlowIn,
                  left: widget.selectedIndex * tabWidth,
                  child: Container(
                    width: tabWidth,
                    height: widget.tabHeight,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.blue.shade500,
                          Colors.blue.shade700,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.3),
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),

                // Tabs
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: List.generate(tabCount, (index) {
                    final bool isSelected = index == widget.selectedIndex;

                    return Expanded(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => widget.onTabSelected(index),
                          borderRadius: BorderRadius.circular(20),

                          // 🔧 Desactivar todos los efectos visuales:
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          focusColor: Colors.transparent,

                          child: Container(
                            height: widget.tabHeight,
                            alignment: Alignment.center,
                            child: AnimatedDefaultTextStyle(
                              duration: Duration(milliseconds: 200),
                              style: TextStyle(
                                fontFamily: 'Figtree',
                                fontSize: 16,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade600,
                              ),
                              child: Text(
                                widget.tabLabels[index],
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  double _calculateTabPosition(int index) {
    final totalTabsWidth = widget.tabWidth * widget.tabLabels.length;
    final availableWidth = MediaQuery.of(context).size.width - 16;
    final totalSpacing = availableWidth - totalTabsWidth;
    final spacingBetweenTabs = totalSpacing / (widget.tabLabels.length - 1);

    return index * (widget.tabWidth + spacingBetweenTabs);
  }
}

class SwipeableTabContent extends StatefulWidget {
  final List<Widget> tabContents;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  const SwipeableTabContent({
    Key? key,
    required this.tabContents,
    required this.currentIndex,
    required this.onIndexChanged,
  }) : super(key: key);

  @override
  _SwipeableTabContentState createState() => _SwipeableTabContentState();
}

class _SwipeableTabContentState extends State<SwipeableTabContent> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.currentIndex);
  }

  @override
  void didUpdateWidget(SwipeableTabContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _pageController.animateToPage(
        widget.currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: PageView(
        controller: _pageController,
        onPageChanged: widget.onIndexChanged,
        children: widget.tabContents,
      ),
    );
  }
}
