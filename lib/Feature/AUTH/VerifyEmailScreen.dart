import 'package:flutter/material.dart';
import 'TakePhotoScreen.dart';
import 'package:ezride/Feature/AUTH/controller/Auth_controller.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  final AuthController _authController = AuthController();
  bool _isVerifying = false;
  String _message = '';

  Future<void> _checkVerification() async {
    setState(() => _isVerifying = true);
    final result = await _authController.checkEmailVerification();

    if (result.ok && result.verified == true) {
      setState(() => _message = '✅ Correo verificado correctamente');

      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const TakePhotoScreen()),
      );
    } else {
      setState(() => _message = '⚠️ Verifica tu correo antes de continuar');
    }

    setState(() => _isVerifying = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación de Correo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Revisa tu correo y haz clic en el enlace de verificación.',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isVerifying ? null : _checkVerification,
              child: _isVerifying
                  ? const CircularProgressIndicator()
                  : const Text('He verificado mi correo'),
            ),
            const SizedBox(height: 24),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
