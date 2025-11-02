class VehiculoObservacion {
  final String id;
  final String vehiculoId;
  final String? inspeccionId;
  final String severidad;
  final String categoria;
  final String detalle;
  final bool detectedByAi;
  final String? evidenciaUrl;
  final bool resuelto;
  final String? resueltoPor;
  final DateTime? resueltoAt;
  final DateTime createdAt;

  VehiculoObservacion({
    required this.id,
    required this.vehiculoId,
    this.inspeccionId,
    required this.severidad,
    required this.categoria,
    required this.detalle,
    this.detectedByAi = true,
    this.evidenciaUrl,
    this.resuelto = false,
    this.resueltoPor,
    this.resueltoAt,
    required this.createdAt,
  });
}
