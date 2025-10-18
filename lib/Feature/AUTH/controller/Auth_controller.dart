import 'dart:io';

import 'package:dio/dio.dart';
import 'package:ezride/App/DATA/datasources/Auth/IADocument_DataSourcers.dart';
import 'package:ezride/App/DATA/repositories/Auth/IADocumentAnalisis_Repository.dart';
import 'package:ezride/App/DOMAIN/Entities%20(ordenarlas%20en%20base%20a%20los%20features)/Auth/AuthResult.dart';
import 'package:ezride/App/DOMAIN/repositories/Auth/IADocument_RepositoryDomain.dart';
import 'package:ezride/App/DOMAIN/usecases/Auth/IADocumentAnalisis_UseCases.dart';
import 'package:ezride/Core/errors/failure.dart';
import 'package:ezride/Feature/AUTH/TakePhotoScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../../App/DATA/repositories/Auth/ProfileUser_RepositoryData.dart';
import '../../../App/DOMAIN/usecases/Auth/Register_UseCases.dart';
import 'package:app_links/app_links.dart';

class AuthModel extends ChangeNotifier {
  // State field(s) for TabBar widget.
  TabController? tabBarController;

  // State field(s) for emailAddress widget.
  late FocusNode emailAddressFocusNode;
  late TextEditingController emailAddressTextController;
  String? Function(String?)? emailAddressTextControllerValidator;

  // State field(s) for password widget.
  late FocusNode passwordFocusNode;
  late TextEditingController passwordTextController;
  late bool passwordVisibility;
  String? Function(String?)? passwordTextControllerValidator;

  // State field(s) for emailAddress_Create widget.
  late FocusNode emailAddressCreateFocusNode;
  late TextEditingController emailAddressCreateTextController;
  String? Function(String?)? emailAddressCreateTextControllerValidator;

  // State field(s) for password_Create widget.
  late FocusNode passwordCreateFocusNode;
  late TextEditingController passwordCreateTextController;
  late bool passwordCreateVisibility;
  String? Function(String?)? passwordCreateTextControllerValidator;

  // State field(s) for passwordConfirm widget.
  late FocusNode passwordConfirmFocusNode;
  late TextEditingController passwordConfirmTextController;
  late bool passwordConfirmVisibility;
  String? Function(String?)? passwordConfirmTextControllerValidator;

  AuthModel() {
    // Inicializar en el constructor
    passwordVisibility = false;
    passwordCreateVisibility = false;
    passwordConfirmVisibility = false;

    // Inicializar controllers y focus nodes
    _initializeControllers();
  }

  void _initializeControllers() {
    //Controladores de login
    emailAddressTextController = TextEditingController();
    emailAddressFocusNode = FocusNode();

    passwordTextController = TextEditingController();
    passwordFocusNode = FocusNode();

    //Controlador de registro.
    emailAddressCreateTextController = TextEditingController();
    emailAddressCreateFocusNode = FocusNode();

    passwordCreateTextController = TextEditingController();
    passwordCreateFocusNode = FocusNode();

    passwordConfirmTextController = TextEditingController();
    passwordConfirmFocusNode = FocusNode();
  }

  // Métodos para cambiar visibilidad
  void togglePasswordVisibility() {
    passwordVisibility = !passwordVisibility;
    notifyListeners();
  }

  void togglePasswordCreateVisibility() {
    passwordCreateVisibility = !passwordCreateVisibility;
    notifyListeners();
  }

  void togglePasswordConfirmVisibility() {
    passwordConfirmVisibility = !passwordConfirmVisibility;
    notifyListeners();
  }

  @override
  void dispose() {
    tabBarController?.dispose();
    emailAddressFocusNode.dispose();
    emailAddressTextController.dispose();

    passwordFocusNode.dispose();
    passwordTextController.dispose();

    emailAddressCreateFocusNode.dispose();
    emailAddressCreateTextController.dispose();

    passwordCreateFocusNode.dispose();
    passwordCreateTextController.dispose();

    passwordConfirmFocusNode.dispose();
    passwordConfirmTextController.dispose();

    super.dispose();
  }
}

// Dentro de AuthController:
class AuthController {
  final SupabaseClient supabase = Supabase.instance.client;

  late final IADocumentDataSourcers iadocumentDatasource;
  late final IADocumentRepository iadocumentRepository;
  late final IADocumentAnalisisUseCases iadocumentUseCase;

  final AppLinks _appLinks = AppLinks();

  AuthController() {
    iadocumentDatasource = IADocumentDataSourcers();
    iadocumentRepository = IADocumentRepository(iadocumentDatasource);
    iadocumentUseCase = IADocumentAnalisisUseCases(iadocumentRepository);
  }

  /// Registro de usuario con creación de profile
  Future<AuthResult> registerUser({
    required String email,
    required String password,
    String? emailRedirectTo,
  }) async {
    try {
      final useCase = RegisterUseCases(ProfileUserRepositoryData(supabase));
      final profile = await useCase.call(
        email: email,
        password: password,
        emailRedirectTo: emailRedirectTo,
      );

      return AuthResult.success(profile,
          'Usuario registrado correctamente, por favor verifica tu correo.');
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// Flujo posterior al registro para verificación de identidad
  Future<void> continueAfterRegister(File selfie, File documentFront) async {
    final result = await checkEmailVerification();

    if (result.ok) {
      print('Email verificado ✅, continuar con verificación de identidad');
      await verifyIdentity(documentFront: documentFront, selfie: selfie);
    } else {
      print(result.message ?? result.error ?? 'Error al verificar correo.');
    }
  }

  /// Verifica si el correo del usuario actual está confirmado
  Future<AuthResult> checkEmailVerification() async {
    try {
      await supabase.auth.refreshSession();
      final user = await supabase.auth.getUser();
      final isVerified = user.user?.emailConfirmedAt != null;
      if (isVerified) {
        return AuthResult.success(null, 'Correo verificado correctamente.');
      } else {
        return AuthResult.failure('Verifica tu correo antes de continuar.');
      }
    } catch (e) {
      return AuthResult.failure(e.toString());
    }
  }

  /// Verificación completa de identidad con IA y biometría
  Future<Map<String, dynamic>> verifyIdentity({
    required File documentFront,
    File? documentBack,
    required File selfie,
    double acceptConfidenceThreshold = 0.75,
  }) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw Exception('Usuario no autenticado');

    final userId = user.id;
    final storage = supabase.storage.from('identidad');
    final uuid = const Uuid();

    final frontPath = 'docs/$userId/${uuid.v4()}_front.jpg';
    final backPath =
        documentBack != null ? 'docs/$userId/${uuid.v4()}_back.jpg' : null;
    final selfiePath = 'docs/$userId/${uuid.v4()}_selfie.jpg';

    try {
      // -------------------------
      // 1) Subir archivos a Storage
      // -------------------------
      await storage.upload(frontPath, documentFront);
      if (documentBack != null) await storage.upload(backPath!, documentBack);
      await storage.upload(selfiePath, selfie);

      final frontPublicUrl = storage.getPublicUrl(frontPath);
      final selfiePublicUrl = storage.getPublicUrl(selfiePath);
      final backPublicUrl =
          documentBack != null ? storage.getPublicUrl(backPath!) : null;

      // -------------------------
      // 2) Análisis OCR con IA
      // -------------------------
      final frontAnalysisEither =
          await iadocumentRepository.analyzeDocument(documentFront);
      Map<String, dynamic>? frontAnalysis;
      if (frontAnalysisEither.isRight()) {
        final frontEntity = frontAnalysisEither
            .getOrElse(() => throw Exception('Front analysis empty'));
        frontAnalysis = (frontEntity as dynamic).toMap?.call() ??
            {'id': (frontEntity as dynamic).id};
      } else {
        final failure =
            frontAnalysisEither.fold((l) => l, (_) => null) as Failure?;
        frontAnalysis = {
          'error': failure?.message ?? 'Error al analizar frontal'
        };
      }

      Map<String, dynamic>? backAnalysis;
      if (documentBack != null) {
        final backAnalysisEither =
            await iadocumentRepository.analyzeDocument(documentBack);
        if (backAnalysisEither.isRight()) {
          final backEntity = backAnalysisEither
              .getOrElse(() => throw Exception('Back analysis empty'));
          backAnalysis = (backEntity as dynamic).toMap?.call() ??
              {'id': (backEntity as dynamic).id};
        } else {
          final failure =
              backAnalysisEither.fold((l) => l, (_) => null) as Failure?;
          backAnalysis = {
            'error': failure?.message ?? 'Error al analizar reverso'
          };
        }
      }

      // -------------------------
      // 3) Verificación facial
      // -------------------------
      final faceEither = await iadocumentRepository.verifyFace(
        selfie: selfie,
        duiFront: documentFront,
      );

      Map<String, dynamic> faceResult;
      if (faceEither.isRight()) {
        faceResult = faceEither.getOrElse(() => <String, dynamic>{});
      } else {
        final failure = faceEither.fold((l) => l, (_) => null) as Failure?;
        faceResult = {
          'error': failure?.message ?? 'Error en verificación facial'
        };
      }

      final bool isIdentical = (faceResult['isIdentical'] == true) ||
          (faceResult['isIdentical']?.toString() == 'true');
      final double confidence = faceResult['confidence'] is num
          ? (faceResult['confidence'] as num).toDouble()
          : double.tryParse(faceResult['confidence']?.toString() ?? '') ?? 0.0;

      // -------------------------
      // 4) Insertar en ai_analysis_results
      // -------------------------
      final aiAnalysisInsert = {
        'analysis_type': 'document_ocr',
        'source_type': 'perfil',
        'source_id': userId,
        'provider': 'azure',
        'provider_ref': uuid.v4(),
        'confidence_score': confidence,
        'is_approved': (confidence >= acceptConfidenceThreshold) && isIdentical,
        'primary_finding': frontAnalysis?['primaryFinding'],
        'features_used':
            (frontAnalysis?['features_used'] as List?)?.cast<String>() ?? [],
        'findings': {
          'front': frontAnalysis,
          'back': backAnalysis,
          'face': faceResult,
        },
      };

      final aiInsertRes = await supabase
          .from('ai_analysis_results')
          .insert(aiAnalysisInsert)
          .select()
          .single();
      final aiId = aiInsertRes != null ? aiInsertRes['id'] as String : null;

      // -------------------------
      // 5) Insertar documento en documentos
      // -------------------------
      final documentoInsert = {
        'scope': 'perfil',
        'perfil_id': userId,
        'file_path': frontPath,
        'verification_status': 'pending',
        'visible_para_cliente': true,
        'ocr_data': frontAnalysis,
        'ai_analysis_id': aiId,
        'created_by': userId,
      };

      final docInsertRes = await supabase
          .from('documentos')
          .insert(documentoInsert)
          .select()
          .single();

      // -------------------------
      // 6) Registrar verificación biométrica
      // -------------------------
      final bioInsert = {
        'user_id': userId,
        'provider': 'azure',
        'provider_ref': (aiId ?? uuid.v4()),
        'attempts': 1,
        'last_verification_at': DateTime.now().toIso8601String(),
        'liveness_detection_data': faceResult,
        'confidence_score': confidence,
        'is_verified': (confidence >= acceptConfidenceThreshold) && isIdentical,
      };

      final bioInsertRes = await supabase
          .from('biometric_verifications')
          .insert(bioInsert)
          .select()
          .single();

      // -------------------------
      // 7) Actualizar perfil
      // -------------------------
      final bool overallVerified =
          (confidence >= acceptConfidenceThreshold) && isIdentical;
      await supabase.from('profiles').update({
        'verification_status': overallVerified ? 'verificado' : 'en_revision',
        'verification_score': confidence,
      }).eq('id', userId);

      return {
        'ok': true,
        'ai_analysis_id': aiId,
        'documento_row': docInsertRes,
        'biometric_row': bioInsertRes,
        'face_result': faceResult,
        'confidence': confidence,
        'is_identical': isIdentical,
        'profile_status': overallVerified ? 'verificado' : 'en_revision',
        'storage_paths': {
          'front': frontPath,
          'back': backPath,
          'selfie': selfiePath,
        },
      };
    } catch (e) {
      // Registro de error opcional
      await supabase.from('audit_log').insert({
        'actor': userId,
        'action': 'identity_verification_failed',
        'entity': 'profiles',
        'entity_id': userId,
        'detail': {'error': e.toString()},
      });

      rethrow;
    }
  }

// -------------------------
// Esto lo moves despues en una carpeta controlador aparte despues
// -------------------------
  void initDeepLinkListener(BuildContext context) {
    _appLinks.uriLinkStream.listen((Uri? uri) {
      if (uri != null && uri.path == '/verified') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const TakePhotoScreen()),
        );
      }
    });
  }
}
