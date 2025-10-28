import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewBox extends StatelessWidget {
  final CameraController controller;
  final Function(XFile) onCapture;

  const CameraPreviewBox(
      {required this.controller, required this.onCapture, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CameraPreview(controller),
        Center(
          child: Container(
            width: 300,
            height: 200,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.greenAccent, width: 3),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        Positioned(
          bottom: 50,
          left: MediaQuery.of(context).size.width / 2 - 35,
          child: FloatingActionButton(
            onPressed: () async {
              final file = await controller.takePicture();
              onCapture(file);
            },
            child: const Icon(Icons.camera_alt),
          ),
        ),
      ],
    );
  }
}
