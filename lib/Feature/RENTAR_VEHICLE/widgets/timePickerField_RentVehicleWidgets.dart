import 'package:flutter/material.dart';

class OptimizedTimePickerField extends StatefulWidget {
  const OptimizedTimePickerField({
    Key? key,
    required this.onTimeSelected,
    this.initialTime = const TimeOfDay(hour: 14, minute: 0),
  }) : super(key: key);

  final ValueChanged<TimeOfDay> onTimeSelected;
  final TimeOfDay initialTime;

  @override
  State<OptimizedTimePickerField> createState() => _OptimizedTimePickerFieldState();
}

class _OptimizedTimePickerFieldState extends State<OptimizedTimePickerField> {
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  Future<void> _showTimePicker() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2563EB),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null && pickedTime != _selectedTime) {
      setState(() {
        _selectedTime = pickedTime;
      });
      widget.onTimeSelected(pickedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeText = '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')} hrs';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              'Hora de recogida',
              style: TextStyle(
                color: Color(0xFF081535),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          GestureDetector(
            onTap: _showTimePicker,
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      timeText,
                      style: const TextStyle(
                        color: Color(0xFF081535),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF6B7280),
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.only(left: 4),
            child: Text(
              'Mínimo 1 hora de anticipación',
              style: TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}