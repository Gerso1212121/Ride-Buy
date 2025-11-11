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
  final bool showLocationButton;
  final VoidCallback? onLocationPressed;
  final bool isLocationLoading;

  const VehicleSearchWidget({
    super.key,
    this.onSearchSubmitted,
    this.onFiltersChanged,
    this.onSearchCleared,
    this.initialSearchText = '',
    this.borderColor = const Color(0xFF0035FF),
    this.showAllFilters = true,
    this.showLocationButton = false,
    this.onLocationPressed,
    this.isLocationLoading = false,
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
  void didUpdateWidget(covariant VehicleSearchWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSearchText != widget.initialSearchText) {
      _searchController.text = widget.initialSearchText;
    }
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

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedTransmission = null;
      _selectedPriceRange = null;
    });
    _notifyFiltersChanged();
  }

  bool get _hasActiveFilters {
    return _selectedType != null || 
           _selectedTransmission != null || 
           _selectedPriceRange != null;
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
            const SizedBox(height: 16),
            
            // ✅ BOTÓN DE UBICACIÓN (si está habilitado)
            if (widget.showLocationButton) _buildLocationButton(theme),
            
            if (widget.showLocationButton && widget.showAllFilters) 
              const SizedBox(height: 12),
            
            if (widget.showAllFilters) _buildFilterSection(theme),
          ],
        ),
      ),
    );
  }

  // ✅ BOTÓN DE UBICACIÓN
  Widget _buildLocationButton(dynamic theme) {
    return SizedBox(
      height: 48,
      child: ElevatedButton.icon(
        onPressed: widget.isLocationLoading ? null : widget.onLocationPressed,
        icon: widget.isLocationLoading
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.primaryText),
                ),
              )
            : const Icon(Icons.location_on_rounded, size: 20),
        label: widget.isLocationLoading
            ? const Text('Obteniendo ubicación...')
            : const Text('Buscar empresas cercanas'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue[50],
          foregroundColor: Colors.blue[700],
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.blue[300]!),
          ),
        ),
      ),
    );
  }

  // ✅ BARRA DE BÚSQUEDA
  Widget _buildSearchBar(dynamic theme) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.alternate.withOpacity(0.5)),
        color: theme.primaryBackground,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: "Buscar empresas, vehículos...",
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
          ),
          if (_hasActiveFilters) ...[
            const SizedBox(width: 8),
            _buildClearFiltersButton(theme),
          ],
        ],
      ),
    );
  }

  // ✅ BOTÓN PARA LIMPIAR FILTROS
  Widget _buildClearFiltersButton(dynamic theme) {
    return GestureDetector(
      onTap: _clearFilters,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red[300]!),
        ),
        child: Icon(
          Icons.filter_alt_off_rounded,
          size: 20,
          color: Colors.red[600],
        ),
      ),
    );
  }

  // ✅ SECCIÓN DE FILTROS
  Widget _buildFilterSection(dynamic theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header de filtros
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: theme.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              if (_hasActiveFilters)
                GestureDetector(
                  onTap: _clearFilters,
                  child: Text(
                    'Limpiar',
                    style: theme.bodySmall.copyWith(
                      color: Colors.blue[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Botones de filtro
        _buildFilterButtons(theme),
      ],
    );
  }

  // ✅ BOTONERA DE FILTROS
  Widget _buildFilterButtons(dynamic theme) {
    return Row(
      children: [
        Expanded(
          child: _buildFilterButton(
            label: "Tipo",
            value: _selectedType,
            icon: Icons.directions_car_filled_rounded,
            options: const ["Automóvil", "Camioneta", "SUV", "Van"],
            onSelected: (v) => setState(() => _selectedType = v),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFilterButton(
            label: "Transmisión",
            value: _selectedTransmission,
            icon: Icons.settings_rounded,
            options: const ["Manual", "Automática"],
            onSelected: (v) => setState(() => _selectedTransmission = v),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFilterButton(
            label: "Precio",
            value: _selectedPriceRange,
            icon: Icons.attach_money_rounded,
            options: const ["\$", "\$\$", "\$\$\$"],
            onSelected: (v) => setState(() => _selectedPriceRange = v),
          ),
        ),
      ],
    );
  }

  // ✅ BOTÓN INDIVIDUAL DE FILTRO
  Widget _buildFilterButton({
    required String label,
    required String? value,
    required IconData icon,
    required List<String> options,
    required Function(String) onSelected,
  }) {
    final bool selected = value != null && value.isNotEmpty;

    return GestureDetector(
      onTap: () => _showBottomSelector(label, options, onSelected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
              size: 16,
              color: selected ? Colors.white : Colors.black87,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                value ?? label,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.lato(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ SELECTOR INFERIOR
  void _showBottomSelector(
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
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.lato(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Opciones
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
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
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

              const SizedBox(height: 20),
              
              // Botón para limpiar selección
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    onSelected('');
                    _notifyFiltersChanged();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Limpiar selección'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}