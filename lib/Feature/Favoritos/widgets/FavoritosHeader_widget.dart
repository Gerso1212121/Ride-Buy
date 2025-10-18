import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showSearchButton;
  final bool showFilterButton;
  final VoidCallback? onSearchPressed;
  final VoidCallback? onFilterPressed;
  final bool automaticallyImplyLeading;
  final bool centerTitle;
  final double elevation;
  final Color? backgroundColor;
  final Color? iconColor;
  final bool responsiveVisibility;
  final bool hideOnTabletLandscape;
  final bool hideOnDesktop;

  const CustomAppBar({
    Key? key,
    required this.title,
    this.showSearchButton = true,
    this.showFilterButton = true,
    this.onSearchPressed,
    this.onFilterPressed,
    this.automaticallyImplyLeading = false,
    this.centerTitle = false,
    this.elevation = 0,
    this.backgroundColor,
    this.iconColor,
    this.responsiveVisibility = true,
    this.hideOnTabletLandscape = true,
    this.hideOnDesktop = true,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  bool _shouldShowAppBar(BuildContext context) {
    if (!responsiveVisibility) return true;

    final mediaQuery = MediaQuery.of(context);
    final isTabletLandscape = mediaQuery.orientation == Orientation.landscape && 
        mediaQuery.size.shortestSide >= 600;
    final isDesktop = mediaQuery.size.width >= 1200;

    if (hideOnTabletLandscape && isTabletLandscape) return false;
    if (hideOnDesktop && isDesktop) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    if (!_shouldShowAppBar(context)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AppBar(
      backgroundColor: backgroundColor ?? colorScheme.primaryContainer,
      automaticallyImplyLeading: automaticallyImplyLeading,
      title: _buildTitle(context, theme),
      actions: _buildActions(context),
      centerTitle: centerTitle,
      elevation: elevation,
    );
  }

  Widget _buildTitle(BuildContext context, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleLarge?.copyWith(
        fontFamily: GoogleFonts.outfit().fontFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
      ) ?? const TextStyle(),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    if (!showSearchButton && !showFilterButton) {
      return [];
    }

    final theme = Theme.of(context);
    final iconColor = this.iconColor ?? theme.colorScheme.onPrimaryContainer;

    return [
      Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            if (showSearchButton)
              _buildIconButton(
                icon: Icons.search_rounded,
                color: iconColor,
                onPressed: onSearchPressed ?? _defaultSearchAction,
              ),
            if (showSearchButton && showFilterButton)
              const SizedBox(width: 8),
            if (showFilterButton)
              _buildIconButton(
                icon: Icons.filter_list_rounded,
                color: iconColor,
                onPressed: onFilterPressed ?? _defaultFilterAction,
              ),
          ],
        ),
      ),
    ];
  }

  Widget _buildIconButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: IconButton(
        icon: Icon(icon, size: 24),
        color: color,
        onPressed: onPressed,
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(),
      ),
    );
  }

  void _defaultSearchAction() {
    print('Search button pressed');
  }

  void _defaultFilterAction() {
    print('Filter button pressed');
  }
}