import 'package:ezride/Core/enums/enums.dart';

class Vehicle {
  final String id;
  final String empresaId;
  final String titulo;
  final String marca;
  final String modelo;
  final int year;
  final String placa;
  final double precioPorDia;
  final VehicleStatus status;
  final int capacidad;
  final String transmision;
  final String combustible;
  final int? kilometraje;
  final String? color;
  final int puertas;
  final String? duenoActual;
  final DateTime? circulacionVence;
  final DateTime? soaVence;
  final bool multasPendientes;
  final bool telemetriaEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  Vehicle({
    required this.id,
    required this.empresaId,
    required this.titulo,
    required this.marca,
    required this.modelo,
    required this.year,
    required this.placa,
    required this.precioPorDia,
    this.status = VehicleStatus.disponible,
    this.capacidad = 5,
    this.transmision = 'automatica',
    this.combustible = 'gasolina',
    this.kilometraje,
    this.color,
    this.puertas = 4,
    this.duenoActual,
    this.circulacionVence,
    this.soaVence,
    this.multasPendientes = false,
    this.telemetriaEnabled = false,
    required this.createdAt,
    required this.updatedAt,
  });
}
