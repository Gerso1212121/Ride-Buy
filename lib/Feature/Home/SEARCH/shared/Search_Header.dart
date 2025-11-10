import 'dart:ui';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VehicleSearchWidget extends StatefulWidget {
  final Function(String)? onSearchSubmitted;
  final Function(String, String, String)? onFiltersChanged;
  final Function()? onSearchCleared;
  final String initialSearchText;
  final Color borderColor;
  final bool showAllFilters;

  const VehicleSearchWidget({
    super.key,
    this.onSearchSubmitted,
    this.onFiltersChanged,
    this.onSearchCleared,
    this.initialSearchText = '',
    this.borderColor = const Color(0xFF0035FF),
    this.showAllFilters = true,
  });

  @override
  State<VehicleSearchWidget> createState() => _VehicleSearchWidgetState();
}

class _VehicleSearchWidgetState extends State<VehicleSearchWidget> {
  late TextEditingController _searchController;
  late FocusNode _searchFocusNode;

  String? _selectedType;
  String? _selectedTransmission;
  String? _selectedPriceRange;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialSearchText);
    _searchFocusNode = FocusNode();
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    if (_searchController.text.isEmpty) {
      _clearSearch();
    }
  }

  void _submitSearch() {
    final searchText = _searchController.text.trim();
    widget.onSearchSubmitted?.call(searchText);
    _notifyFiltersChanged();
  }

  void _clearSearch() {
    _searchController.clear();
    _searchFocusNode.unfocus();
    widget.onSearchCleared?.call();
  }

  void _notifyFiltersChanged() {
    widget.onFiltersChanged?.call(
      _selectedType ?? '',
      _selectedTransmission ?? '',
      _selectedPriceRange ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.secondaryBackground.withOpacity(0.90),
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSearchBar(theme),
            const SizedBox(height: 20),
            if (widget.showAllFilters) _buildFilterButtons(theme),
          ],
        ),
      ),
    );
  }

  // ✅ ELEGANTE SEARCH BAR
  Widget _buildSearchBar(dynamic theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate.withOpacity(0.5)),
        color: theme.primaryBackground,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: TextFormField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: "¿A dónde quieres ir?",
          border: InputBorder.none,
          prefixIcon: Icon(Icons.search_rounded, color: theme.primaryText),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close_rounded, color: theme.secondaryText),
                  onPressed: _clearSearch,
                )
              : null,
        ),
        onFieldSubmitted: (_) => _submitSearch(),
        style: theme.bodyMedium,
      ),
    );
  }

  // ✅ NUEVOS BOTONES DE FILTRO — estilo tarjeta compacta
// ✅ NUEVA BOTONERA: 3 botones horizontales
Widget _buildFilterButtons(dynamic theme) {
  return Row(
    children: [
      Expanded(
        child: _buildFilterButton(
          label: "Tipo",
          value: _selectedType,
          icon: Icons.directions_car_filled_rounded,
          options: ["Automóvil", "Camioneta", "SUV", "Van"],
          onSelected: (v) => setState(() => _selectedType = v),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _buildFilterButton(
          label: "Transmisión",
          value: _selectedTransmission,
          icon: Icons.settings_rounded,
          options: ["Manual", "Automática"],
          onSelected: (v) => setState(() => _selectedTransmission = v),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: _buildFilterButton(
          label: "Precio",
          value: _selectedPriceRange,
          icon: Icons.attach_money_rounded,
          options: ["\$", "\$\$", "\$\$\$"],
          onSelected: (v) => setState(() => _selectedPriceRange = v),
        ),
      ),
    ],
  );
}

// ✅ NUEVO BOTÓN con selección azul/blanco
Widget _buildFilterButton({
  required String label,
  required String? value,
  required IconData icon,
  required List<String> options,
  required Function(String) onSelected,
}) {
  final bool selected = value != null && value.isNotEmpty;

  return GestureDetector(
    onTap: () => _showNewBottomSelector(label, options, onSelected),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: selected ? const Color(0xFF0035FF) : Colors.white,
        border: Border.all(
          color: selected
              ? const Color(0xFF0035FF)
              : Colors.grey.withOpacity(0.3),
        ),
        boxShadow: [
          if (selected)
            BoxShadow(
              color: const Color(0xFF0035FF).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? Colors.white : Colors.black87,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              value ?? label,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}


  // ✅ NUEVO PANEL INFERIOR — estilo Airbnb / Booking
  void _showNewBottomSelector(
    String title,
    List<String> options,
    Function(String) onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // ✅ Botones redondeados tipo selector moderno
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: options.map((opt) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(opt);
                      _notifyFiltersChanged();
                    },
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.blue.shade300,
                        ),
                      ),
                      child: Text(
                        opt,
                        style: GoogleFonts.lato(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),
            ],
          ),
        );
      },
    );
  }
}
