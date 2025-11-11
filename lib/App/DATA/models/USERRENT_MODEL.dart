// user_rentas_model.dart
import 'package:flutter/material.dart';

class UserRentaModel {
  final String rentaId;
  final String vehiculoId;
  final String empresaId;
  final String marca;
  final String modelo;
  final String placa;
  final String imagenVehiculo;
  final double precioPorDia;
  final double total;
  final String status;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final DateTime fechaReserva;
  final String tipo; // 'reserva' o 'renta'
  final String pickupMethod;
  final String? pickupAddress;
  final String? entregaAddress;
  final String? verificationCode;

  UserRentaModel({
    required this.rentaId,
    required this.vehiculoId,
    required this.empresaId,
    required this.marca,
    required this.modelo,
    required this.placa,
    required this.imagenVehiculo,
    required this.precioPorDia,
    required this.total,
    required this.status,
    required this.fechaInicio,
    required this.fechaFin,
    required this.fechaReserva,
    required this.tipo,
    required this.pickupMethod,
    this.pickupAddress,
    this.entregaAddress,
    this.verificationCode,
  });

  factory UserRentaModel.fromJson(Map<String, dynamic> json) {
    return UserRentaModel(
      rentaId: json['renta_id'] ?? '',
      vehiculoId: json['vehiculo_id'] ?? '',
      empresaId: json['empresa_id'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      placa: json['placa'] ?? '',
      imagenVehiculo: json['imagen_vehiculo'] ?? '',
      precioPorDia: _parseDouble(json['precio_por_dia']),
      total: _parseDouble(json['total']),
      status: json['status'] ?? '',
      fechaInicio: _parseDateTime(json['fecha_inicio']),
      fechaFin: _parseDateTime(json['fecha_fin']),
      fechaReserva: _parseDateTime(json['fecha_reserva']),
      tipo: json['tipo'] ?? 'renta',
      pickupMethod: json['pickup_method'] ?? 'agencia',
      pickupAddress: json['pickup_address'],
      entregaAddress: json['entrega_address'],
      verificationCode: json['verification_code'],
    );
  }

  // Métodos de parsing seguro
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }

  // Propiedades computadas
  bool get isActiva => status == 'en_curso' || status == 'confirmada';
  bool get isSolicitud => status == 'pendiente';
  bool get isHistorial => status == 'finalizada' || status == 'cancelada' || status == 'expirada';

  String get estadoTexto {
    switch (status) {
      case 'pendiente':
        return 'Pendiente';
      case 'confirmada':
        return 'Confirmada';
      case 'en_curso':
        return 'En Curso';
      case 'finalizada':
        return 'Finalizada';
      case 'cancelada':
        return 'Cancelada';
      case 'expirada':
        return 'Expirada';
      default:
        return status;
    }
  }

  Color get estadoColor {
    switch (status) {
      case 'pendiente':
        return Colors.orange;
      case 'confirmada':
        return Colors.blue;
      case 'en_curso':
        return Colors.green;
      case 'finalizada':
        return Colors.grey;
      case 'cancelada':
        return Colors.red;
      case 'expirada':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  String get diasRestantes {
    final now = DateTime.now();
    if (status == 'en_curso') {
      final diff = fechaFin.difference(now);
      return '${diff.inDays} días restantes';
    } else if (status == 'confirmada') {
      final diff = fechaInicio.difference(now);
      return 'Inicia en ${diff.inDays} días';
    }
    return '';
  }

  bool get puedeCancelar => status == 'pendiente' || status == 'confirmada';
  bool get puedeVerificar => status == 'confirmada' || status == 'en_curso';
  bool get puedeCalificar => status == 'finalizada';
}