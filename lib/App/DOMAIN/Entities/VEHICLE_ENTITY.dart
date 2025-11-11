class VehicleEntity {
  final String id;
  final String empresaId;
  final String marca;
  final String modelo;
  final int? anio; // Año del vehículo
  final String placa;
  final String? color;
  final String? tipo;
  final String estado; // 'disponible', 'en_renta', 'mantenimiento', 'inactivo'
  final String? imagen1;
  final String? imagen2;
  final String? titulo; // Nuevo campo para el título
  final double precioPorDia; // Precio por día
  final int capacidad; // Capacidad del vehículo
  final String transmision; // Tipo de transmisión
  final String combustible; // Tipo de combustible
  final int puertas; // Número de puertas
  final String? soaNumber; // SOA Number
  final DateTime? circulacionVence; // Fecha de vencimiento de la circulación
  final DateTime? soaVence; // Fecha de vencimiento del SOA
  final DateTime createdAt;
  final DateTime updatedAt;

  // Constructor
  VehicleEntity({
    required this.id,
    required this.empresaId,
    required this.marca,
    required this.modelo,
    this.anio,
    required this.placa,
    this.color,
    this.tipo,
    this.estado = 'disponible', // Valor por defecto
    this.imagen1,
    this.imagen2,
    this.titulo, // Campo título
    required this.precioPorDia,
    this.capacidad = 5,
    this.transmision = 'automatica',
    this.combustible = 'gasolina',
    this.puertas = 4,
    this.soaNumber,
    this.circulacionVence,
    this.soaVence,
    required this.createdAt,
    required this.updatedAt,
  });

  // Getter para el año
  int? get year => anio;

  // Getter para verificar si el vehículo está en renta
  bool get isRented => estado == 'en_renta';
}
