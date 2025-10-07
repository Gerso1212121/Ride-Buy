import 'package:flutter/material.dart';

class CostSummaryCardRentVehicleWidgets extends StatelessWidget {
  const CostSummaryCardRentVehicleWidgets({
    Key? key,
    required this.costItems,
    required this.subtotal,
  }) : super(key: key);

  final List<CostItem> costItems;
  final String subtotal;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen de costos',
              style: TextStyle(
                color: Color(0xFF081535),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            ...costItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.label,
                    style: const TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    item.value,
                    style: const TextStyle(
                      color: Color(0xFF081535),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )),
            
            const Divider(color: Color(0xFFE5E7EB), height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(
                    color: Color(0xFF081535),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtotal,
                  style: const TextStyle(
                    color: Color(0xFF2563EB),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CostItem {
  final String label;
  final String value;

  const CostItem({
    required this.label,
    required this.value,
  });
}