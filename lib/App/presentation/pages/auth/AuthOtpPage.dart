import 'package:camera/camera.dart';
import 'package:ezride/Core/sessions/session_manager.dart';
import 'package:ezride/Core/widgets/Modals/GlobalModal_widget.dart';
import 'package:ezride/Feature/AUTH/Auth_Header.dart';
import 'package:ezride/Feature/AUTH/OTP/OTPForm.dart';
import 'package:ezride/Feature/AUTH/Auht_Model/Auth_Model.dart';
import 'package:ezride/flutter_flow/flutter_flow_animations.dart';
import 'package:ezride/flutter_flow/flutter_flow_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../DOMAIN/usecases/Auth/Auth_UseCase.dart';

class AuthOtpPage extends StatefulWidget {
  final String email;
  final String password;
  final ProfileUserUseCaseGlobal profileUserUseCaseGlobal;

  const AuthOtpPage({
    super.key,
    required this.email,
    required this.password,
    required this.profileUserUseCaseGlobal,
  });

  @override
  State<AuthOtpPage> createState() => _AuthOtpPageState();
}

class _AuthOtpPageState extends State<AuthOtpPage>
    with TickerProviderStateMixin {
  late AuthModel _model;
  late Map<String, AnimationInfo> _animationsMap;
  bool _isResending = false;
  int _remainingTime = 600;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _model = AuthModel();
    _setupAnimations();
    _startTimer();
  }

  void _setupAnimations() {
    _animationsMap = {
      'columnOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(duration: 600.ms),
          MoveEffect(
            curve: Curves.easeInOut,
            duration: 600.ms,
            begin: const Offset(0, 20),
            end: Offset.zero,
          ),
        ],
      ),
    };
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_remainingTime > 0) {
          _remainingTime--;
          _startTimer();
        } else {
          _canResend = true;
        }
      });
    });
  }

  // ✅ Helper seguro para cerrar solo el modal
  void closeModal() {
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
  }

  Future<void> _onVerifyPressed(String otpCode) async {
    if (otpCode.length != 6) {
      await showGlobalStatusModal(
        context,
        title: 'Código incompleto',
        message: 'Por favor ingresa los 6 dígitos del código enviado.',
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
      );
      return;
    }

    // ⏳ Modal de carga
    showGlobalStatusModal(
      context,
      title: 'Verificando tu código...',
      message: 'Esto puede tardar unos segundos.',
      isLoading: true,
    );

    try {
      final profile =
          await widget.profileUserUseCaseGlobal.repository.verifyOtp(
        email: widget.email,
        inputOtp: otpCode,
      );

      if (!mounted) return;

      // ✅ Cerrar modal de carga
      closeModal();

      if (profile != null) {
        // 🎉 Modal éxito
        await showGlobalStatusModal(
          context,
          title: '¡Código verificado!',
          message: 'Tu cuenta ha sido activada correctamente 🎉',
          icon: Icons.verified_rounded,
          iconColor: Colors.green,
        );

        closeModal(); // Cierra modal de éxito

        await SessionManager.setProfile(profile);

        final cameras = await availableCameras();
        if (!mounted) return;

        // 🚀 Redirección correcta
        context.push('/capture-document', extra: {
          'perfilId': profile.id,
          'camera': cameras.first,
        });
      } else {
        await showGlobalStatusModal(
          context,
          title: 'Código incorrecto',
          message: 'El código ingresado no es válido. Intenta nuevamente.',
          icon: Icons.error_outline,
          iconColor: Colors.redAccent,
        );
        closeModal();
      }
    } catch (e) {
      if (!mounted) return;

      closeModal(); // cerrar modal carga

      String errorMessage = e.toString().contains('expirado')
          ? 'El código ha expirado. Solicita uno nuevo.'
          : 'Ocurrió un error al verificar el código.';

      await showGlobalStatusModal(
        context,
        title: 'Error de verificación',
        message: errorMessage,
        icon: Icons.error_outline,
        iconColor: Colors.redAccent,
      );

      closeModal();

      setState(() {
        _canResend = true;
        _remainingTime = 0;
      });
    }
  }

  Future<void> _onResendCodePressed() async {
    if (_isResending || !_canResend) return;
    setState(() {
      _isResending = true;
      _canResend = false;
      _remainingTime = 600;
    });

    try {
      await widget.profileUserUseCaseGlobal.registerPending(
        email: widget.email,
        password: widget.password,
      );
      _showSuccess('Código reenviado a ${widget.email}');
      setState(() => _isResending = false);
      _startTimer();
    } catch (e) {
      setState(() {
        _isResending = false;
        _canResend = true;
      });
      _showError('Error al reenviar código.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const AuthHeader(),
              _buildOTPContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOTPContent() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        children: [
          OTPForm(
            model: _model,
            animationsMap: _animationsMap,
            parentContext: context,
            onVerifyPressed: _onVerifyPressed,
            onResendCodePressed: _onResendCodePressed,
            onBackToLoginPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ).animateOnPageLoad(
        _animationsMap['columnOnPageLoadAnimation2']!,
      ),
    );
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }
}
