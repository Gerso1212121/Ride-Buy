import 'dart:io';
import 'package:ezride/App/DATA/datasources/Auth/IADocument_DataSourcers.dart';
import 'package:ezride/App/presentation/widgets/camera_preview_box.dart';
import 'package:ezride/Services/render/render_db_client.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class CaptureScreen extends StatefulWidget {
  final String sourceType; // 'document_front', 'document_back', 'selfie'
  final IADocumentDataSourcers dataSource;

  const CaptureScreen(
      {required this.sourceType, required this.dataSource, super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? controller;
  bool loading = false;
  late CameraDescription camera;

  @override
  void initState() {
    super.initState();
    initCamera();
  }

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    camera = cameras.first;
    controller = CameraController(camera, ResolutionPreset.medium);
    await controller!.initialize();
    setState(() {});
  }

  Future<void> handleCapture(XFile file) async {
    setState(() => loading = true);
    try {
      final hash =
          sha256.convert(await File(file.path).readAsBytes()).toString();
      final result = await widget.dataSource.analyzeDocument(File(file.path));
      await RenderDbClient.insertDocument(
        ocrData: result.toJson(),
        hash: hash,
        createdAt: DateTime.now(),
        sourceType: widget.sourceType,
        provider: widget.sourceType == 'selfie'
            ? 'FaceAPI'
            : 'AzureDocumentIntelligence',
      );
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Captura y subida exitosa')));
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized)
      return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(title: Text('Captura ${widget.sourceType}')),
      body: Stack(
        children: [
          CameraPreviewBox(controller: controller!, onCapture: handleCapture),
          if (loading)
            const Center(
              child: CircularProgressIndicator(color: Colors.redAccent),
            )
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
