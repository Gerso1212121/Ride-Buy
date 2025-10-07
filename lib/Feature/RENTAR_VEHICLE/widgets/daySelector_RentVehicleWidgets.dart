import 'package:flutter/material.dart';

class OptimizedDaysDropdown extends StatefulWidget {
  const OptimizedDaysDropdown({
    Key? key,
    required this.onDaysSelected,
    this.initialValue,
  }) : super(key: key);

  final ValueChanged<String?> onDaysSelected;
  final String? initialValue;

  @override
  State<OptimizedDaysDropdown> createState() => _OptimizedDaysDropdownState();
}

class _OptimizedDaysDropdownState extends State<OptimizedDaysDropdown> {
  final List<String> _options = const [
    '1 día', '2 días', '3 días', '4 días', '5 días', 
    '7 días', '10 días', '14 días', '21 días'
  ];
  String? _selectedValue;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialValue;
  }

  void _showCustomMenu(BuildContext context) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);

    showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy + renderBox.size.height,
        offset.dx + renderBox.size.width,
        offset.dy + renderBox.size.height + 200,
      ),
      items: _options.map((option) {
        return PopupMenuItem<String>(
          value: option,
          child: Text(
            option,
            style: const TextStyle(
              color: Color(0xFF081535),
              fontSize: 14,
            ),
          ),
        );
      }).toList(),
    ).then((value) {
      if (value != null) {
        setState(() {
          _selectedValue = value;
        });
        widget.onDaysSelected(value);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Días de renta',
              style: TextStyle(
                color: Color(0xFF081535),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          GestureDetector(
            onTap: () => _showCustomMenu(context),
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedValue ?? 'Selecciona los días',
                        style: TextStyle(
                          color: _selectedValue != null 
                              ? const Color(0xFF081535)
                              : const Color(0xFF9CA3AF),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF6B7280),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}