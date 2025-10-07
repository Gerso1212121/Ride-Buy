class BiometricVerification {
  final String id;
  final String? userId;
  final String? provider;
  final String? providerRef;
  final int attempts;
  final DateTime? lastVerificationAt;
  final Map<String, dynamic>? livenessDetectionData;
  final double? confidenceScore;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  BiometricVerification({
    required this.id,
    this.userId,
    this.provider,
    this.providerRef,
    this.attempts = 0,
    this.lastVerificationAt,
    this.livenessDetectionData,
    this.confidenceScore,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
  });
}
