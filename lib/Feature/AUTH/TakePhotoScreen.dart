import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ezride/Feature/AUTH/controller/Auth_controller.dart';

class TakePhotoScreen extends StatefulWidget {
  const TakePhotoScreen({super.key});

  @override
  State<TakePhotoScreen> createState() => _TakePhotoScreenState();
}

class _TakePhotoScreenState extends State<TakePhotoScreen> {
  final AuthController _authController = AuthController();
  File? selfie;
  File? documentFront;
  bool _isLoading = false;

  Future<void> _pickSelfie() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => selfie = File(picked.path));
  }

  Future<void> _pickDocument() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.camera);
    if (picked != null) setState(() => documentFront = File(picked.path));
  }

  Future<void> _verifyIdentity() async {
    if (selfie == null || documentFront == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes tomar ambas fotos')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final result = await _authController.verifyIdentity(
        documentFront: documentFront!,
        selfie: selfie!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('✅ Verificación completada: ${result['profile_status']}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al verificar identidad: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificación de Identidad')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: _pickDocument,
              child: Text(documentFront == null
                  ? 'Tomar foto del documento'
                  : 'Documento listo ✅'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _pickSelfie,
              child: Text(selfie == null ? 'Tomar selfie' : 'Selfie lista ✅'),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: _isLoading ? null : _verifyIdentity,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Verificar identidad'),
            ),
          ],
        ),
      ),
    );
  }
}
