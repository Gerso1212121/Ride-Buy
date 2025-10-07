import 'package:flutter/material.dart';

class AppbarRentVehicleDetails extends StatelessWidget implements PreferredSizeWidget {
  const AppbarRentVehicleDetails({
    Key? key,
    required this.onBackPressed,
    this.title = 'Rentar Vehículo',
  }) : super(key: key);

  final VoidCallback onBackPressed;
  final String title;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF081535)),
        onPressed: onBackPressed,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF081535),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      centerTitle: true,
    );
  }
}