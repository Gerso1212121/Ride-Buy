class AuditLog {
  final int id;
  final String? actor;
  final String action;
  final String entity;
  final String? entityId;
  final Map<String, dynamic>? detail;
  final DateTime createdAt;

  AuditLog({
    required this.id,
    this.actor,
    required this.action,
    required this.entity,
    this.entityId,
    this.detail,
    required this.createdAt,
  });
}
