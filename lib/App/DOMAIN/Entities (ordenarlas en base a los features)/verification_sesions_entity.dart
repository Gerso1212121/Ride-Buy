import 'package:ezride/Core/enums/enums.dart';

class VerificationSession {
  final String id;
  final String userId;
  final SessionType sessionType;
  final SessionStatus status;
  final List<String>? gesturesRequired;
  final List<String>? gesturesCompleted;
  final String? azureSessionId;
  final int attempts;
  final DateTime expiresAt;
  final Map<String, dynamic>? resultData;
  final DateTime createdAt;

  VerificationSession({
    required this.id,
    required this.userId,
    required this.sessionType,
    this.status = SessionStatus.inProgress,
    this.gesturesRequired,
    this.gesturesCompleted,
    this.azureSessionId,
    this.attempts = 0,
    required this.expiresAt,
    this.resultData,
    required this.createdAt,
  });
}
