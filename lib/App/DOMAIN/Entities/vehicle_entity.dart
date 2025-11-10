import 'package:ezride/Core/enums/enums.dart';

class VehicleEntity {
  final String id;
  final String empresaId;
  final String titulo;
  final String marca;
  final String modelo;
  final int? anio;
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
  final String? soaNumber;
  final DateTime? circulacionVence;
  final DateTime? soaVence;
  final bool multasPendientes;
  final String? gpsDeviceId;
  final String? insuranceProvider;
  final bool telemetriaEnabled;
  final String? telemetriaTrackerId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imagen1;
  final String? imagen2;

  VehicleEntity({
    required this.id,
    required this.empresaId,
    required this.titulo,
    required this.marca,
    required this.modelo,
    this.anio,
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
    this.soaNumber,
    this.circulacionVence,
    this.soaVence,
    this.multasPendientes = false,
    this.gpsDeviceId,
    this.insuranceProvider,
    this.telemetriaEnabled = false,
    this.telemetriaTrackerId,
    required this.createdAt,
    required this.updatedAt,
    this.imagen1,
    this.imagen2,
  });
}
