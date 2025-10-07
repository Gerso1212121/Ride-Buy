import 'package:ezride/flutter_flow/flutter_flow_drop_down.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/flutter_flow/flutter_flow_util.dart';
import 'package:ezride/flutter_flow/form_field_controller.dart';
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

  void _onFilterChanged() => _notifyFiltersChanged();

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final width = MediaQuery.of(context).size.width;

    final bool isSmallScreen = width < 400;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(color: widget.borderColor.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔍 Campo de búsqueda
            TextFormField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: '¿A dónde quieres ir?',
                hintStyle: theme.bodyMedium.copyWith(
                  color: theme.secondaryText,
                  fontFamily: GoogleFonts.lato().fontFamily,
                ),
                prefixIcon: Icon(Icons.search_rounded, color: theme.primaryText),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.clear, color: theme.secondaryText),
                        onPressed: _clearSearch,
                      )
                    : null,
                filled: true,
                fillColor: theme.primaryBackground,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: widget.borderColor.withOpacity(0.4)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: widget.borderColor, width: 1.5),
                ),
              ),
              style: theme.bodyMedium.copyWith(
                fontFamily: GoogleFonts.lato().fontFamily,
              ),
              onFieldSubmitted: (_) => _submitSearch(),
            ),

            if (widget.showAllFilters) ...[
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: isSmallScreen
                    ? Column(
                        children: _buildFilterWidgets(context)
                            .map((e) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: e,
                                ))
                            .toList(),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: _buildFilterWidgets(context)
                            .map((e) => Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    child: e,
                                  ),
                                ))
                            .toList(),
                      ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildFilterWidgets(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);

    return [
      // 🚗 Tipo de vehículo
      FlutterFlowDropDown<String>(
        margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
        controller: FormFieldController<String>(_selectedType),
        options: const ['Automóvil', 'Camioneta', 'SUV', 'Van'],
        onChanged: (val) {
          setState(() => _selectedType = val);
          _onFilterChanged();
        },
        height: 45,
        textStyle: theme.bodySmall.copyWith(
          fontFamily: GoogleFonts.lato().fontFamily,
          fontWeight: FontWeight.w500,
        ),
        hintText: 'Tipo',
        icon: Icon(Icons.directions_car_rounded,
            color: theme.primaryText, size: 18),
        fillColor: theme.primaryBackground,
        elevation: 2,
        borderColor: widget.borderColor.withOpacity(0.4),
        borderWidth: 1,
        borderRadius: 16,
        hidesUnderline: true,
      ),

      // ⚙️ Transmisión
      FlutterFlowDropDown<String>(
        margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
        controller: FormFieldController<String>(_selectedTransmission),
        options: const ['Manual', 'Automática'],
        onChanged: (val) {
          setState(() => _selectedTransmission = val);
          _onFilterChanged();
        },
        height: 45,
        textStyle: theme.bodySmall.copyWith(
          fontFamily: GoogleFonts.lato().fontFamily,
          fontWeight: FontWeight.w500,
        ),
        hintText: 'Transmisión',
        icon:
            Icon(Icons.settings_rounded, color: theme.primaryText, size: 18),
        fillColor: theme.primaryBackground,
        elevation: 2,
        borderColor: widget.borderColor.withOpacity(0.4),
        borderWidth: 1,
        borderRadius: 16,
        hidesUnderline: true,
      ),

      // 💲 Precio
      FlutterFlowDropDown<String>(
        margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
        controller: FormFieldController<String>(_selectedPriceRange),
        options: const [
          '\$',
          '\$\$',
          '\$\$\$',
        ],
        onChanged: (val) {
          setState(() => _selectedPriceRange = val);
          _onFilterChanged();
        },
        height: 45,
        textStyle: theme.bodySmall.copyWith(
          fontFamily: GoogleFonts.lato().fontFamily,
          fontWeight: FontWeight.w500,
        ),
        hintText: 'Precio',
        icon: Icon(Icons.attach_money_rounded,
            color: theme.primaryText, size: 18),
        fillColor: theme.primaryBackground,
        elevation: 2,
        borderColor: widget.borderColor.withOpacity(0.4),
        borderWidth: 1,
        borderRadius: 16,
        hidesUnderline: true,
      ),
    ];
  }
}
