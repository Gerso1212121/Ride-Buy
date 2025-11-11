import 'package:ezride/App/DOMAIN/Entities/VEHICLE_ENTITY.dart';

class VehicleModel extends VehicleEntity {
  VehicleModel({
    required super.id,
    required super.empresaId,
    required super.marca,
    required super.modelo,
    super.anio,
    required super.placa,
    super.color,
    super.tipo,
    super.estado = 'disponible',
    super.imagen1,
    super.imagen2,
    super.titulo,
    required super.precioPorDia,
    super.capacidad = 5,
    super.transmision = 'automatica',
    super.combustible = 'gasolina',
    super.puertas = 4,
    super.soaNumber,
    super.circulacionVence,
    super.soaVence,
    required super.createdAt,
    required super.updatedAt,
  });

  // Factory constructor para crear instancia desde JSON
  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] ?? '',
      empresaId: json['empresa_id'] ?? json['empresaId'] ?? '', // ✅ Compatible con ambos
      marca: json['marca'] ?? '',
      modelo: json['modelo'] ?? '',
      anio: _parseInt(json['anio']),
      placa: json['placa'] ?? '',
      color: json['color'],
      tipo: json['tipo'],
      estado: json['estado'] ?? 'disponible',
      imagen1: json['imagen1'],
      imagen2: json['imagen2'],
      titulo: json['titulo'],
      
      // ✅ CORREGIDO: Manejo seguro de double
      precioPorDia: _parseDouble(json['precio_por_dia'] ?? json['precioPorDia']),
      
      capacidad: _parseInt(json['capacidad']) ?? 5,
      transmision: json['transmision'] ?? 'automatica',
      combustible: json['combustible'] ?? 'gasolina',
      puertas: _parseInt(json['puertas']) ?? 4,
      soaNumber: json['soa_number'] ?? json['soaNumber'],
      circulacionVence: _parseDateTime(json['circulacion_vence'] ?? json['circulacionVence']),
      soaVence: _parseDateTime(json['soa_vence'] ?? json['soaVence']),
      createdAt: _parseDateTime(json['created_at'] ?? json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDateTime(json['updated_at'] ?? json['updatedAt']) ?? DateTime.now(),
    );
  }

  // ✅ Métodos auxiliares para parsing seguro
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'empresa_id': empresaId, // ✅ Usar snake_case para PostgreSQL
      'marca': marca,
      'modelo': modelo,
      'anio': anio,
      'placa': placa,
      'color': color,
      'tipo': tipo,
      'estado': estado,
      'imagen1': imagen1,
      'imagen2': imagen2,
      'titulo': titulo,
      'precio_por_dia': precioPorDia, // ✅ snake_case
      'capacidad': capacidad,
      'transmision': transmision,
      'combustible': combustible,
      'puertas': puertas,
      'soa_number': soaNumber, // ✅ snake_case
      'circulacion_vence': circulacionVence?.toIso8601String(), // ✅ snake_case
      'soa_vence': soaVence?.toIso8601String(), // ✅ snake_case
      'created_at': createdAt.toIso8601String(), // ✅ snake_case
      'updated_at': updatedAt.toIso8601String(), // ✅ snake_case
    };
  }

  // Método para crear desde la entidad
  factory VehicleModel.fromEntity(VehicleEntity entity) {
    return VehicleModel(
      id: entity.id,
      empresaId: entity.empresaId,
      marca: entity.marca,
      modelo: entity.modelo,
      anio: entity.anio,
      placa: entity.placa,
      color: entity.color,
      tipo: entity.tipo,
      estado: entity.estado,
      imagen1: entity.imagen1,
      imagen2: entity.imagen2,
      titulo: entity.titulo,
      precioPorDia: entity.precioPorDia,
      capacidad: entity.capacidad,
      transmision: entity.transmision,
      combustible: entity.combustible,
      puertas: entity.puertas,
      soaNumber: entity.soaNumber,
      circulacionVence: entity.circulacionVence,
      soaVence: entity.soaVence,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  // Método copyWith para crear copias modificadas
  VehicleModel copyWith({
    String? id,
    String? empresaId,
    String? marca,
    String? modelo,
    int? anio,
    String? placa,
    String? color,
    String? tipo,
    String? estado,
    String? imagen1,
    String? imagen2,
    String? titulo,
    double? precioPorDia,
    int? capacidad,
    String? transmision,
    String? combustible,
    int? puertas,
    String? soaNumber,
    DateTime? circulacionVence,
    DateTime? soaVence,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      empresaId: empresaId ?? this.empresaId,
      marca: marca ?? this.marca,
      modelo: modelo ?? this.modelo,
      anio: anio ?? this.anio,
      placa: placa ?? this.placa,
      color: color ?? this.color,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      imagen1: imagen1 ?? this.imagen1,
      imagen2: imagen2 ?? this.imagen2,
      titulo: titulo ?? this.titulo,
      precioPorDia: precioPorDia ?? this.precioPorDia,
      capacidad: capacidad ?? this.capacidad,
      transmision: transmision ?? this.transmision,
      combustible: combustible ?? this.combustible,
      puertas: puertas ?? this.puertas,
      soaNumber: soaNumber ?? this.soaNumber,
      circulacionVence: circulacionVence ?? this.circulacionVence,
      soaVence: soaVence ?? this.soaVence,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Getter para verificar si el vehículo está en renta
  bool get isRented => estado == 'en_renta';

  @override
  String toString() {
    return 'VehicleModel(id: $id, marca: $marca, modelo: $modelo, placa: $placa, estado: $estado, precioPorDia: $precioPorDia)';
  }
}