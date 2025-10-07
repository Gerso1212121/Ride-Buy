import '../../../DOMAIN/Entities (ordenarlas en base a los features)/Auth/IADocumentAnalisis_Entities.dart';
import '../../../../Core/enums/enums.dart';

class IADocumentAnalisisModel extends IAAnalisisResultEntities {
  IADocumentAnalisisModel({
    required super.id,
    required super.analysisType,
    required super.sourceType,
    required super.sourceId,
    super.provider,
    super.providerRef,
    super.confidenceScore,
    super.isApproved,
    super.primaryFinding,
    super.featuresUsed,
    super.analysisDurationMs,
    super.costUnits,
    required super.findings,
    super.recommendations,
    required super.createdAt,
  });

  factory IADocumentAnalisisModel.fromJson(Map<String, dynamic> json) {
    return IADocumentAnalisisModel(
      id: json['id'],
      analysisType: MLAnalysisType.values.firstWhere(
          (e) => e.toString() == 'MLAnalysisType.${json['analysisType']}'),
      sourceType: MLSourceType.values.firstWhere(
          (e) => e.toString() == 'MLSourceType.${json['sourceType']}'),
      sourceId: json['sourceId'],
      provider: json['provider'],
      providerRef: json['providerRef'],
      confidenceScore: (json['confidenceScore'] != null)
          ? double.tryParse(json['confidenceScore'].toString())
          : null,
      isApproved: json['isApproved'] ?? false,
      primaryFinding: json['primaryFinding'],
      featuresUsed: (json['featuresUsed'] != null)
          ? List<String>.from(json['featuresUsed'])
          : null,
      analysisDurationMs: json['analysisDurationMs'],
      costUnits: (json['costUnits'] != null)
          ? double.tryParse(json['costUnits'].toString())
          : null,
      findings: json['findings'] ?? {},
      recommendations: (json['recommendations'] != null)
          ? List<String>.from(json['recommendations'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'analysisType': analysisType.toString().split('.').last,
        'sourceType': sourceType.toString().split('.').last,
        'sourceId': sourceId,
        'provider': provider,
        'providerRef': providerRef,
        'confidenceScore': confidenceScore,
        'isApproved': isApproved,
        'primaryFinding': primaryFinding,
        'featuresUsed': featuresUsed,
        'analysisDurationMs': analysisDurationMs,
        'costUnits': costUnits,
        'findings': findings,
        'recommendations': recommendations,
        'createdAt': createdAt.toIso8601String(),
      };
}
