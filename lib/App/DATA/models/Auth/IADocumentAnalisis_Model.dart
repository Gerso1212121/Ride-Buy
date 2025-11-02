import 'package:ezride/App/DOMAIN/Entities/Auth/IADocumentAnalisis_Entities.dart';
import 'package:ezride/Core/enums/enums.dart';

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
      id: DateTime.now().millisecondsSinceEpoch.toString(), // Genera un ID temporal
      analysisType: MLAnalysisType.documentOcr,
      sourceType: MLSourceType.documento,
      sourceId: json["documentNumber"] ?? "unknown",

      provider: "azure",
      providerRef: json["docType"],

      confidenceScore: 0.98, // Azure no manda confidence general, puedes poner promedio
      isApproved: true,

      primaryFinding: json["fullName"] ?? "Sin nombre detectado",

      findings: {
        "docType": json["docType"],
        "fullName": json["fullName"],
        "firstName": json["firstName"],
        "lastName": json["lastName"],
        "documentNumber": json["documentNumber"],
        "dateOfBirth": json["dateOfBirth"],
        "nationality": json["nationality"],
        "dateOfExpiration": json["dateOfExpiration"],
        "allFields": json["allFields"],
      },

      createdAt: DateTime.now(),
    );
  }
}
