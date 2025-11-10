import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class QuickCameraScreen extends StatefulWidget {
  const QuickCameraScreen({Key? key}) : super(key: key);

  @override
  State<QuickCameraScreen> createState() => _QuickCameraScreenState();
}

class _QuickCameraScreenState extends State<QuickCameraScreen> {
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(firstCamera, ResolutionPreset.high);

    _initializeControllerFuture = _controller!.initialize();
    setState(() {});
  }

  Future<void> _takePictureAndReturn() async {
    try {
      await _initializeControllerFuture;

      // Take the picture
      final image = await _controller!.takePicture();

      // Immediately return without preview
      if (mounted) {
        Navigator.pop(context, File(image.path));
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Camera preview
                Positioned.fill(child: CameraPreview(_controller!)),

                // Close button
                Positioned(
                  top: 40,
                  left: 20,
                  child: SafeArea(
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 32,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),

                // Capture button (automatically returns after capture)
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _takePictureAndReturn,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.5),
                            width: 5,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.camera_alt,
                            color: Colors.black,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(color: Colors.white),
            );
          }
        },
      ),
    );
  }
}
