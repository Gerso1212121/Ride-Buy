class VehiculoTelemetriaAlerta {
  final String id;
  final String vehiculoId;
  final String tipo;
  final DateTime ts;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  VehiculoTelemetriaAlerta({
    required this.id,
    required this.vehiculoId,
    required this.tipo,
    required this.ts,
    this.metadata,
    required this.createdAt,
  });
}
