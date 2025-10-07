import 'package:flutter/material.dart';

class OptimizedTimeSelectionRentVehicleWidgets extends StatefulWidget {
  const OptimizedTimeSelectionRentVehicleWidgets({
    Key? key,
    required this.onTimeSelected,
    this.initialSelection = 'Para ahora',
  }) : super(key: key);

  final ValueChanged<String> onTimeSelected;
  final String initialSelection;

  @override
  State<OptimizedTimeSelectionRentVehicleWidgets> createState() => _OptimizedTimeSelectionRentVehicleWidgetsState();
}

class _OptimizedTimeSelectionRentVehicleWidgetsState extends State<OptimizedTimeSelectionRentVehicleWidgets> {
  late String _selectedOption;

  @override
  void initState() {
    super.initState();
    _selectedOption = widget.initialSelection;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 12),
            child: Text(
              '¿Cuándo necesitas el vehículo?',
              style: TextStyle(
                color: Color(0xFF081535),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _TimeButton(
                option: 'Para ahora',
                isSelected: _selectedOption == 'Para ahora',
                onTap: () {
                  setState(() {
                    _selectedOption = 'Para ahora';
                  });
                  widget.onTimeSelected('Para ahora');
                },
              ),
              const SizedBox(width: 12),
              _TimeButton(
                option: 'Para mañana',
                isSelected: _selectedOption == 'Para mañana',
                onTap: () {
                  setState(() {
                    _selectedOption = 'Para mañana';
                  });
                  widget.onTimeSelected('Para mañana');
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final String option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF2563EB) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFD1D5DB),
            width: 1,
          ),
        ),
        child: Text(
          option,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF6B7280),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}