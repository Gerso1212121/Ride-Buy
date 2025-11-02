import 'package:ezride/Core/enums/enums.dart';

class GovernmentVerificationCache {
  final String id;
  final String? userId;
  final String? vehiculoId;
  final GovernmentEntity entityType;
  final GovVerificationType verificationType;
  final String requestHash;
  final Map<String, dynamic>? response;
  final String? responseStatus;
  final bool? isValid;
  final DateTime? verifiedAt;
  final DateTime expiresAt;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  GovernmentVerificationCache({
    required this.id,
    this.userId,
    this.vehiculoId,
    required this.entityType,
    required this.verificationType,
    required this.requestHash,
    this.response,
    this.responseStatus,
    this.isValid,
    this.verifiedAt,
    required this.expiresAt,
    this.metadata,
    required this.createdAt,
  });
}
