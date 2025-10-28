import 'package:flutter/material.dart';
import '../../../DOMAIN/usecases/Auth/Auth_UseCase.dart';

class AuthOtpSuccessPage extends StatelessWidget {
  final String email;
  final ProfileUserUseCaseGlobal profileUserUseCaseGlobal;

  const AuthOtpSuccessPage({
    super.key,
    required this.email,
    required this.profileUserUseCaseGlobal,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('OTP Verificado')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 100),
            const SizedBox(height: 20),
            const Text(
              'OTP verificado con éxito',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Aquí podrías navegar a /main o /chat si quieres probar la redirección
                Navigator.of(context).pop();
              },
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
