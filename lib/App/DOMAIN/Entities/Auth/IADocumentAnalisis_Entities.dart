import 'package:ezride/Core/enums/enums.dart';

class IAAnalisisResultEntities {
  final String id;
  final MLAnalysisType analysisType;
  final MLSourceType sourceType;
  final String sourceId;
  final String? provider;
  final String? providerRef;
  final double? confidenceScore;
  final bool isApproved;
  final String? primaryFinding;
  final List<String>? featuresUsed;
  final int? analysisDurationMs;
  final double? costUnits;
  final Map<String, dynamic> findings;
  final List<String>? recommendations;
  final DateTime createdAt;

  IAAnalisisResultEntities({
    required this.id,
    required this.analysisType,
    required this.sourceType,
    required this.sourceId,
    this.provider,
    this.providerRef,
    this.confidenceScore,
    this.isApproved = false,
    this.primaryFinding,
    this.featuresUsed,
    this.analysisDurationMs,
    this.costUnits,
    required this.findings,
    this.recommendations,
    required this.createdAt,
  });
}
