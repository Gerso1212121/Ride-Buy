import 'package:ezride/Core/enums/enums.dart';

class Documento {
  final String id;
  final DocumentoScope scope;
  final String? empresaId;
  final String? vehiculoId;
  final String? perfilId;
  final DocumentType? tipoVehiculo;
  final DocumentType? tipoEmpresa;
  final DocumentType? tipoPerfil;
  final String filePath;
  final DateTime? venceEn;
  final DocumentStatus verificationStatus;
  final bool visibleParaCliente;
  final Map<String, dynamic>? ocrData;
  final String? aiAnalysisId;
  final String? createdBy;
  final DateTime createdAt;

  Documento({
    required this.id,
    required this.scope,
    this.empresaId,
    this.vehiculoId,
    this.perfilId,
    this.tipoVehiculo,
    this.tipoEmpresa,
    this.tipoPerfil,
    required this.filePath,
    this.venceEn,
    this.verificationStatus = DocumentStatus.pending,
    this.visibleParaCliente = false,
    this.ocrData,
    this.aiAnalysisId,
    this.createdBy,
    required this.createdAt,
  });
}