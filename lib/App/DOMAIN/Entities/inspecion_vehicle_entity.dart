class VehiculoInspeccion {
  final String id;
  final String vehiculoId;
  final String source;
  final String? inspectorId;
  final String? aiAnalysisId;
  final String resultado;
  final String? notas;
  final Map<String, dynamic>? evidencias;
  final DateTime createdAt;

  VehiculoInspeccion({
    required this.id,
    required this.vehiculoId,
    this.source = 'ia',
    this.inspectorId,
    this.aiAnalysisId,
    required this.resultado,
    this.notas,
    this.evidencias,
    required this.createdAt,
  });
}
