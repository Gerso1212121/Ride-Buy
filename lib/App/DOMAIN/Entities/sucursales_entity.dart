class Sucursales {
  final String id;
  final String empresaId;
  final String nombre;
  final String? direccion;
  final double? lat;
  final double? lng;
  final String? telefono;
  final Map<String, dynamic>? horarios;
  final DateTime createdAt;

  Sucursales({
    required this.id,
    required this.empresaId,
    required this.nombre,
    this.direccion,
    this.lat,
    this.lng,
    this.telefono,
    this.horarios,
    required this.createdAt,
  });
}
