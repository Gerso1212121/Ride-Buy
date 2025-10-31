import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Mock de consulta a DB, reemplazar por tu implementación real
Future<List<String>> getUploadedDocuments(String perfilId) async {
  // Simulamos que ya se subió el DUI frente
  await Future.delayed(const Duration(milliseconds: 500));
  return ['dui_front']; // <- esto debería venir de tu DB
}

class UploadDocumentPage extends StatefulWidget {
  final String perfilId;
  const UploadDocumentPage({super.key, required this.perfilId});

  @override
  State<UploadDocumentPage> createState() => _UploadDocumentPageState();
}

class _UploadDocumentPageState extends State<UploadDocumentPage> {
  bool isLoading = true;
  bool hasDuiFront = false;
  bool hasDuiBack = false;
  bool hasSelfie = false;

  @override
  void initState() {
    super.initState();
    _loadUploadedDocuments();
  }

  Future<void> _loadUploadedDocuments() async {
    final uploaded = await getUploadedDocuments(widget.perfilId);
    setState(() {
      hasDuiFront = uploaded.contains('dui_front');
      hasDuiBack = uploaded.contains('dui_back');
      hasSelfie = uploaded.contains('selfie');
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Verificación de Identidad')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Subí tus documentos para completar la verificación.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 40),
            _optionButton(context, 'DUI - Frente', 'dui_front', hasDuiFront),
            _optionButton(context, 'DUI - Reverso', 'dui_back', hasDuiBack),
            _optionButton(context, 'Selfie', 'selfie', hasSelfie),
          ],
        ),
      ),
    );
  }

  Widget _optionButton(
      BuildContext context, String text, String type, bool isDisabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: ElevatedButton(
        onPressed: isDisabled
            ? null
            : () => context.push('/capture-document', extra: {
                  'type': type,
                  'perfilId': widget.perfilId,
                }),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 60),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: isDisabled ? Colors.grey : Colors.green,
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}