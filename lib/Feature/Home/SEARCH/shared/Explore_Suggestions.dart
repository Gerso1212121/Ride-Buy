import 'package:flutter/material.dart';

class ExploreSuggestions extends StatelessWidget {
  const ExploreSuggestions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _section("🔥 Más rentados"),
        _horizontalScrollDummy(["BMW 3", "Corolla", "Kia Rio"]),
        _section("🏆 Populares"),
        _horizontalScrollDummy(["Mazda CX5", "Hyundai Tucson"]),
        _section("💸 Promociones"),
        _horizontalScrollDummy(["Nissan Sentra", "Chevy Spark"]),
      ],
    );
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(left: 16, top: 24, bottom: 8),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      );

  Widget _horizontalScrollDummy(List<String> items) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, i) => Container(
          width: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(child: Text(items[i])),
        ),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: items.length,
      ),
    );
  }
}
