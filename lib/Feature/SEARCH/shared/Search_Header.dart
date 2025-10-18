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
    
    // Configurar listener para el campo de búsqueda
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  // Función llamada cuando cambia el texto de búsqueda
  void _onSearchTextChanged() {
    print('Texto de búsqueda cambiado: ${_searchController.text}');
    
    // Lógica de búsqueda en tiempo real podría ir aquí
    if (_searchController.text.isEmpty) {
      _clearSearch();
    }
  }

  // Función para enviar la búsqueda
  void _submitSearch() {
    final searchText = _searchController.text.trim();
    print('Búsqueda enviada: $searchText');
    print('Filtros aplicados:');
    print('- Tipo: $_selectedType');
    print('- Transmisión: $_selectedTransmission');
    print('- Rango de precio: $_selectedPriceRange');
    
    widget.onSearchSubmitted?.call(searchText);
    _notifyFiltersChanged();
  }

  // Función para limpiar la búsqueda
  void _clearSearch() {
    print('Limpiando búsqueda');
    _searchController.clear();
    _searchFocusNode.unfocus();
    
    widget.onSearchCleared?.call();
  }

  // Función cuando cambian los filtros
  void _onFilterChanged() {
    print('Filtros actualizados:');
    print('- Tipo de vehículo: $_selectedType');
    print('- Transmisión: $_selectedTransmission');
    print('- Rango de precio: $_selectedPriceRange');
    
    _notifyFiltersChanged();
  }

  // Notificar cambios en todos los filtros
  void _notifyFiltersChanged() {
    widget.onFiltersChanged?.call(
      _selectedType ?? '',
      _selectedTransmission ?? '',
      _selectedPriceRange ?? '',
    );
  }

  // Función para resetear todos los filtros
  void _resetAllFilters() {
    print('Reseteando todos los filtros');
    setState(() {
      _selectedType = null;
      _selectedTransmission = null;
      _selectedPriceRange = null;
    });
    _clearSearch();
    _onFilterChanged();
  }

  // Función para aplicar filtros predefinidos
  void _applyQuickFilter(String filterType, String value) {
    print('Aplicando filtro rápido: $filterType = $value');
    
    setState(() {
      switch (filterType) {
        case 'type':
          _selectedType = value;
          break;
        case 'transmission':
          _selectedTransmission = value;
          break;
        case 'price':
          _selectedPriceRange = value;
          break;
      }
    });
    
    _onFilterChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 20),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              // Campo de búsqueda
              TextFormField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                autofocus: false,
                obscureText: false,
                decoration: InputDecoration(
                  hintText: '¿A dónde quieres ir?',
                  hintStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lato(
                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
                    letterSpacing: 0.0,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.borderColor,
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: widget.borderColor.withOpacity(0.8),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color(0x00000000),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                  contentPadding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 12),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: FlutterFlowTheme.of(context).secondaryText,
                    size: 20,
                  ),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.clear,
                            color: FlutterFlowTheme.of(context).secondaryText,
                            size: 20,
                          ),
                          onPressed: _clearSearch,
                        )
                      : null,
                ),
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lato(
                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  letterSpacing: 0.0,
                ),
                onFieldSubmitted: (value) => _submitSearch(),
              ),

              // Filtros (solo si showAllFilters es true)
              if (widget.showAllFilters) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    // Filtro de tipo de vehículo
                    Expanded(
                      child: FlutterFlowDropDown<String>(
                        controller: _selectedType != null 
                            ? FormFieldController<String>(_selectedType)
                            : FormFieldController<String>(null),
                        options: const ['Automóvil', 'Camioneta', 'SUV', 'Van'],
                        onChanged: (val) {
                          setState(() => _selectedType = val);
                          _onFilterChanged();
                        },
                        height: 40,
                        textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.lato(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Tipo',
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 18,
                        ),
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                        elevation: 1,
                        borderColor: widget.borderColor,
                        borderWidth: 1,
                        borderRadius: 20,
                        margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                        hidesUnderline: true,
                        isSearchable: false,
                        isMultiSelect: false,
                      ),
                    ),

                    // Filtro de transmisión
                    Expanded(
                      child: FlutterFlowDropDown<String>(
                        controller: _selectedTransmission != null 
                            ? FormFieldController<String>(_selectedTransmission)
                            : FormFieldController<String>(null),
                        options: const ['Manual', 'Automática'],
                        onChanged: (val) {
                          setState(() => _selectedTransmission = val);
                          _onFilterChanged();
                        },
                        height: 40,
                        textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.lato(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Transmisión',
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 18,
                        ),
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                        elevation: 1,
                        borderColor: widget.borderColor,
                        borderWidth: 1,
                        borderRadius: 20,
                        margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                        hidesUnderline: true,
                        isSearchable: false,
                        isMultiSelect: false,
                      ),
                    ),

                    // Filtro de precio
                    Expanded(
                      child: FlutterFlowDropDown<String>(
                        controller: _selectedPriceRange != null 
                            ? FormFieldController<String>(_selectedPriceRange)
                            : FormFieldController<String>(null),
                        options: const [
                          '\$0 - \$500',
                          '\$500 - \$1000',
                          '\$1000 - \$2000',
                          '\$2000+'
                        ],
                        onChanged: (val) {
                          setState(() => _selectedPriceRange = val);
                          _onFilterChanged();
                        },
                        height: 40,
                        textStyle: FlutterFlowTheme.of(context).bodySmall.override(
                          font: GoogleFonts.lato(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                          ),
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                        ),
                        hintText: 'Precio',
                        icon: Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: FlutterFlowTheme.of(context).primaryText,
                          size: 18,
                        ),
                        fillColor: FlutterFlowTheme.of(context).secondaryBackground,
                        elevation: 1,
                        borderColor: widget.borderColor,
                        borderWidth: 1,
                        borderRadius: 20,
                        margin: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 0),
                        hidesUnderline: true,
                        isSearchable: false,
                        isMultiSelect: false,
                      ),
                    ),
                  ].divide(const SizedBox(width: 8)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}