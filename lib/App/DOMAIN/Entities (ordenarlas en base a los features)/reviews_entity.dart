class Review {
  final String id;
  final String rentaId;
  final String vehiculoId;
  final String clienteId;
  final int rating;
  final String? comentario;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.rentaId,
    required this.vehiculoId,
    required this.clienteId,
    required this.rating,
    this.comentario,
    required this.createdAt,
  });
}
