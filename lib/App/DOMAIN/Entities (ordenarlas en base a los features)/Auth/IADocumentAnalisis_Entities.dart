import 'package:ezride/App/DATA/models/Auth/IADocumentAnalisis_Model.dart';
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

  // Campos opcionales combinados para verificación
  final IAAnalisisResultEntities? frontAnalysis;
  final IAAnalisisResultEntities? backAnalysis;
  final Map<String, dynamic>? faceVerification;

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
    this.frontAnalysis,
    this.backAnalysis,
    this.faceVerification,
  });

  factory IAAnalisisResultEntities.fromModel(IADocumentAnalisisModel model) {
    return IAAnalisisResultEntities(
      id: model.id,
      analysisType: model.analysisType,
      sourceType: model.sourceType,
      sourceId: model.sourceId,
      provider: model.provider,
      providerRef: model.providerRef,
      confidenceScore: model.confidenceScore,
      isApproved: model.isApproved,
      primaryFinding: model.primaryFinding?.toString(),
      featuresUsed: model.featuresUsed,
      analysisDurationMs: model.analysisDurationMs,
      costUnits: model.costUnits,
      findings: model.findings,
      recommendations: model.recommendations,
      createdAt: model.createdAt,
    );
  }
}
