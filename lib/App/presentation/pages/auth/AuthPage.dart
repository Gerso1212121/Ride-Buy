import 'package:dio/dio.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:ezride/Feature/AUTH/Auth_Header.dart';
import 'package:ezride/Feature/AUTH/Auth_Tabs.dart';
import 'package:ezride/Feature/AUTH/controller/Auth_controller.dart';
import 'package:ezride/flutter_flow/flutter_flow_animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Agrega estos imports
import '../../../DOMAIN/usecases/Auth/Auth_UseCase.dart';
import '../../../DATA/repositories/Auth/ProfileUser_RepositoryData.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => AuthPageState();
}

class AuthPageState extends State<AuthPage> with TickerProviderStateMixin {
  late AuthModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};
  bool _isLoading = false;

  // ✅ INICIALIZAR CASOS DE USO
  late final ProfileUserUseCaseGlobal profileUserUseCaseGlobal;

  @override
  void initState() {
    super.initState();
    _model = AuthModel();
    _initializeTabController();
    _initializeUseCases();
  }

  void _initializeUseCases() {
    final dio = Dio();
    final userRepository = ProfileUserRepositoryData(
      dio: dio,
      emailJsServiceId: 'tu_service_id',
      emailJsTemplateId: 'tu_template_id',
      emailJsPublicKey: 'tu_public_key',
    );
    profileUserUseCaseGlobal = ProfileUserUseCaseGlobal(userRepository);
  }

  void _initializeTabController() {
    _model.tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    )..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
        body: SafeArea(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 8,
                child: _buildAuthContent(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthContent(BuildContext context) {
    return Container(
      width: 100.0,
      height: double.infinity,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
      ),
      alignment: const AlignmentDirectional(0.0, -1.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AuthHeader(),
            AuthTabs(
              model: _model,
              animationsMap: animationsMap,
              parentContext: context,
              onSignInPressed: () => _handleSignIn(context),
              onForgotPasswordPressed: () => _handleForgotPassword(context),
              onRegisterLinkPressed: _switchToRegisterTab,
              onGoogleAuthLoginPressed: () => _handleGoogleAuthLogin(context),
              onRegisterPressed: () => _handleRegister(context),
              onLoginLinkPressed: _switchToLoginTab,
              onGoogleAuthRegisterPressed: () =>
                  _handleGoogleAuthRegister(context),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- LOGIN ----------------
  void _handleSignIn(BuildContext context) async {
    final email = _model.emailAddressTextController.text.trim();
    final password = _model.passwordTextController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Por favor completa todos los campos');
      return;
    }

    _showLoadingDialog(context, 'Iniciando sesión...');

    try {
      final profile = await profileUserUseCaseGlobal.login(
        email: email,
        password: password,
      );

      if (mounted) Navigator.of(context).pop();
      _navigateToAuthComplete(context);
    } catch (e) {
      if (mounted) Navigator.of(context).pop();
      _showErrorDialog(
        context,
        'Error al iniciar sesión',
        _getErrorMessage(e),
      );
    }
  }

  // ---------------- REGISTRO ----------------
void _handleRegister(BuildContext context) async {
  final email = _model.emailAddressCreateTextController.text.trim();
  final password = _model.passwordCreateTextController.text.trim();
  final confirmPassword = _model.passwordConfirmTextController.text.trim();

  if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    _showSnackBar(context, 'Por favor completa todos los campos');
    return;
  }

  if (password != confirmPassword) {
    _showSnackBar(context, 'Las contraseñas no coinciden');
    return;
  }

  if (password.length < 6) {
    _showSnackBar(context, 'La contraseña debe tener al menos 6 caracteres');
    return;
  }

  _showLoadingDialog(context, 'Creando tu cuenta...');

  try {
    print('📌 Intentando registrar usuario: $email');

    final profile = await profileUserUseCaseGlobal.register(
      email: email,
      password: password,
    );

    print('✅ Registro exitoso: ${profile.id}');

    if (!mounted) return;
    Navigator.of(context).pop(); // cerrar diálogo de carga
    _showOtpDialog(context, email);
  } catch (e, st) {
    if (mounted) Navigator.of(context).pop();
    print('❌ Error en _handleRegister: $e');
    print(st);
    _showErrorDialog(
      context,
      'Error al registrar',
      e.toString(),
    );
  }
}


  // ---------------- OTP ----------------
  void _showOtpDialog(BuildContext context, String email) {
    final otpController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Verificación OTP'),
          content: TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Ingresa el código OTP',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final inputOtp = otpController.text.trim();
                final isValid =
                    await profileUserUseCaseGlobal.repository.verifyOtp(
                  email: email, // << parámetro nombrado
                  inputOtp: inputOtp, // << parámetro nombrado
                );

                if (isValid) {
                  Navigator.of(ctx).pop();
                  _showSnackBar(context, 'OTP verificado correctamente');
                  _navigateToAuthComplete(context);
                } else {
                  _showSnackBar(context, 'OTP incorrecto');
                }
              },
              child: const Text('Verificar'),
            ),
          ],
        );
      },
    );
  }

  // ---------------- DIALOGOS ----------------
  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(width: 20),
                    Text(message),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString();
    if (errorString.contains('Invalid login credentials')) {
      return 'Correo electrónico o contraseña incorrectos';
    } else if (errorString.contains('Email not confirmed')) {
      return 'Por favor verifica tu correo electrónico';
    } else if (errorString.contains('User already registered')) {
      return 'Este correo electrónico ya está registrado';
    } else if (errorString.contains('Failed to register user')) {
      return 'Error al crear la cuenta. Intenta nuevamente';
    } else if (errorString.contains('Error iniciando sesión')) {
      return 'Error al iniciar sesión. Verifica tus credenciales';
    } else {
      return 'Ha ocurrido un error inesperado. Intenta nuevamente';
    }
  }

  // ---------------- NAVEGACION ----------------
  void _navigateToAuthComplete(BuildContext context) {
    try {
      GoRouter.of(context).go('/main');
    } catch (e) {
      print('GoRouter error: $e');
      Navigator.of(context).pushNamed('/main');
    }
  }

  // ---------------- TAB SWITCH ----------------
  void _switchToRegisterTab() {
    _model.tabBarController?.animateTo(1);
  }

  void _switchToLoginTab() {
    _model.tabBarController?.animateTo(0);
  }

  // ---------------- SNACKBAR ----------------
  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  // ---------------- GOOGLE AUTH ----------------
  void _handleGoogleAuthLogin(BuildContext context) {
    _showSnackBar(context, 'Iniciando sesión con Google');
  }

  void _handleGoogleAuthRegister(BuildContext context) {
    _showSnackBar(context, 'Registrando con Google');
  }

  // ---------------- FORGOT PASSWORD ----------------
  void _handleForgotPassword(BuildContext context) {
    _showSnackBar(context, 'Funcionalidad de recuperación de contraseña');
  }
}
