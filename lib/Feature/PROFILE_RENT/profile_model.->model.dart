import 'package:flutter/material.dart';

class RentalPolicy {
  final String description;
  
  const RentalPolicy(this.description);
}

class AdditionalService {
  final String name;
  final IconData icon;
  final double width;
  
  const AdditionalService({
    required this.name,
    required this.icon,
    required this.width,
  });
}