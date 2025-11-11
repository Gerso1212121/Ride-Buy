// lib/Core/widgets/Cards/Card_EmpresaDetails.dart
import 'package:flutter/material.dart';
import 'package:ezride/Core/widgets/Cards/Card_CarsDetails.dart';

class EmpresaCardWidget extends StatelessWidget {
  final String empresaId;
  final String nombre;
  final String direccion;
  final String? telefono;
  final String? email;
  final String imagenUrl;
  final double? distancia;
  final double rating;
  final int totalResenas;
  final int totalVehiculos;
  final int vehiculosDisponibles;
  final VoidCallback onTap;
  final Color accentColor;
  final bool showDistance;

  const EmpresaCardWidget({
    Key? key,
    required this.empresaId,
    required this.nombre,
    required this.direccion,
    required this.imagenUrl,
    required this.onTap,
    this.telefono,
    this.email,
    this.distancia,
    this.rating = 4.5,
    this.totalResenas = 0,
    this.totalVehiculos = 0,
    this.vehiculosDisponibles = 0,
    this.accentColor = const Color(0xFF0035FF),
    this.showDistance = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con imagen y info básica
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Imagen de la empresa
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      image: DecorationImage(
                        image: NetworkImage(imagenUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Información principal
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nombre,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        
                        // Dirección
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                direccion,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 4),
                        
                        // Rating y reseñas
                        Row(
                          children: [
                            Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              rating.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[800],
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '($totalResenas reseñas)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Distancia
                  if (showDistance && distancia != null)
                    Column(
                      children: [
                        Icon(Icons.location_on, size: 20, color: accentColor),
                        const SizedBox(height: 4),
                        Text(
                          '${distancia!.toStringAsFixed(1)} km',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Estadísticas de vehículos
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.directions_car,
                      value: totalVehiculos.toString(),
                      label: 'Vehículos',
                    ),
                    _buildStatItem(
                      icon: Icons.check_circle,
                      value: vehiculosDisponibles.toString(),
                      label: 'Disponibles',
                      color: Colors.green,
                    ),
                    _buildStatItem(
                      icon: Icons.car_rental,
                      value: '${((vehiculosDisponibles / (totalVehiculos == 0 ? 1 : totalVehiculos)) * 100).toInt()}%',
                      label: 'Disponibilidad',
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Información de contacto
              if (telefono != null || email != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.contact_phone, size: 16, color: accentColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (telefono != null)
                              Text(
                                '📞 $telefono',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                              ),
                            if (email != null)
                              Text(
                                '📧 $email',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[700],
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 8),
              
              // Botón de acción
              Container(
                width: double.infinity,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accentColor, accentColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Center(
                      child: Text(
                        'Ver Empresa y Vehículos',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color ?? accentColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color ?? Colors.grey[800],
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

// Widget compacto para lista
class EmpresaCardCompact extends StatelessWidget {
  final String nombre;
  final String direccion;
  final String imagenUrl;
  final double? distancia;
  final double rating;
  final int totalVehiculos;
  final VoidCallback onTap;

  const EmpresaCardCompact({
    Key? key,
    required this.nombre,
    required this.direccion,
    required this.imagenUrl,
    required this.onTap,
    this.distancia,
    this.rating = 4.5,
    this.totalVehiculos = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Imagen
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                    image: NetworkImage(imagenUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              
              // Información
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nombre,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      direccion,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star, size: 14, color: Colors.amber),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.directions_car, size: 14, color: Colors.grey),
                        const SizedBox(width: 2),
                        Text(
                          '$totalVehiculos vehículos',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Distancia
              if (distancia != null)
                Column(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.blue),
                    const SizedBox(height: 2),
                    Text(
                      '${distancia!.toStringAsFixed(1)} km',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}