import 'package:flutter/material.dart';

class InfocardRentVehiclewidgets extends StatelessWidget {
  const InfocardRentVehiclewidgets({
    Key? key,
    required this.returnDate,
    required this.returnTime,
    required this.mainInstruction,
    required this.additionalInfo,
  }) : super(key: key);

  final String returnDate;
  final String returnTime;
  final String mainInstruction;
  final String additionalInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFDBEAFE),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: Color(0xFF2563EB),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Fecha y hora de devolución estimada',
                  style: TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '$returnDate, $returnTime',
              style: const TextStyle(
                color: Color(0xFF1E40AF),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mainInstruction,
              style: const TextStyle(
                color: Color(0xFF081535),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              additionalInfo,
              style: const TextStyle(
                color: Color(0xFF6B7280),
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}