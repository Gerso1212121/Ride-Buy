// RentaClienteModel.dart
import 'package:flutter/material.dart';

class RentaClienteModel {
  final String rentaId;
  final String vehiculoId;
  final String clienteId;
  final String marca;
  final String modelo;
  final String placa;
  final String color;
  final int anio;
  final String imagenVehiculo;
  final double precioPorDia;
  final String nombreCliente;
  final String emailCliente;
  final String telefonoCliente;
  final String duiCliente;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final double total;
  final String status;
  final DateTime fechaReserva;

  RentaClienteModel({
    required this.rentaId,
    required this.vehiculoId,
    required this.clienteId,
    required this.marca,
    required this.modelo,
    required this.placa,
    required this.color,
    required this.anio,
    required this.imagenVehiculo,
    required this.precioPorDia,
    required this.nombreCliente,
    required this.emailCliente,
    required this.telefonoCliente,
    required this.duiCliente,
    required this.fechaInicio,
    required this.fechaFin,
    required this.total,
    required this.status,
    required this.fechaReserva,
  });

  factory RentaClienteModel.fromJson(Map<String, dynamic> json) {
    return RentaClienteModel(
      rentaId: json['renta_id'] ?? '',
      vehiculoId: json['vehiculo_id'] ?? '',
      clienteId: json['cliente_id'] ?? '',
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      placa: json['placa'] ?? '',
      color: json['color'] ?? '',
      anio: _parseInt(json['anio']) ?? 0,
      imagenVehiculo: json['imagen_vehiculo'] ?? '',
      precioPorDia: _parseDouble(json['precio_por_dia']),
      nombreCliente: json['nombre_cliente'] ?? 'Cliente no disponible',
      emailCliente: json['email_cliente'] ?? '',
      telefonoCliente: json['telefono_cliente'] ?? '',
      duiCliente: json['dui_cliente'] ?? '',
      fechaInicio: _parseDateTime(json['fecha_inicio']),
      fechaFin: _parseDateTime(json['fecha_fin']),
      total: _parseDouble(json['total']),
      status: json['status'] ?? '',
      fechaReserva: _parseDateTime(json['fecha_reserva']),
    );
  }

  // ✅ MÉTODOS DE PARSING SEGURO
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.tryParse(value) ?? 0.0;
      } catch (e) {
        print('⚠️ Error parsing double from string: "$value"');
        return 0.0;
      }
    }
    print('⚠️ Tipo no manejado en _parseDouble: ${value.runtimeType}');
    return 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.tryParse(value);
      } catch (e) {
        print('⚠️ Error parsing int from string: "$value"');
        return null;
      }
    }
    print('⚠️ Tipo no manejado en _parseInt: ${value.runtimeType}');
    return null;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        print('⚠️ Error parsing DateTime from string: "$value"');
        return DateTime.now();
      }
    }
    print('⚠️ Tipo no manejado en _parseDateTime: ${value.runtimeType}');
    return DateTime.now();
  }

  // Método para obtener el color según el estado
  Color get statusColor {
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
      default:
        return Colors.grey;
    }
  }

  // Método para obtener el texto del estado
  String get statusText {
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
      default:
        return status;
    }
  }
}