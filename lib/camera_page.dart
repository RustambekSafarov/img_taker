// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_taker/services/connectivity_service.dart';
import 'package:img_taker/widgets/scaffold_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  final ImagePicker _picker = ImagePicker();
  List<String> _savedImagePaths = [];
  bool _isLoading = false;
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _connectivityService.initialize();
    _loadSavedImages();

    _connectivityService.connectionStatus.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });

      // Show snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        scaffoldMessenger(
          context,
          isConnected ? Icons.wifi : Icons.wifi_off,
          isConnected ? 'Internet Connected' : 'No internet Connection',
          isConnected ? true : false,
        );
      }
    });
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }

  // Load all saved images from app storage
  Future<void> _loadSavedImages() async {
    setState(() => _isLoading = true);

    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');
      print(directory);
      if (await imagesDir.exists()) {
        final files = imagesDir
            .listSync()
            .whereType<File>()
            .map((item) => item.path)
            .toList();

        setState(() {
          _savedImagePaths = files;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print('Error loading images: $e');
      setState(() => _isLoading = false);
    }
  }

  // Pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1800,
        maxHeight: 1800,
      );

      if (image != null) {
        await _saveImageToStorage(image);
      }
    } catch (e) {
      showError(context, 'Failed to capture image: $e');
    }
  }

  // Save image to app's permanent storage
  Future<void> _saveImageToStorage(XFile image) async {
    setState(() => _isLoading = true);

    try {
      // Get the app's document directory
      final directory = await getApplicationDocumentsDirectory();

      // Create an 'images' subdirectory if it doesn't exist
      final imagesDir = Directory('${directory.path}/images');
      if (!await imagesDir.exists()) {
        await imagesDir.create(recursive: true);
      }

      // Generate a unique filename using timestamp
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(image.path)}';
      final savedPath = '${imagesDir.path}/$fileName';

      // Copy the image to the app storage
      await File(image.path).copy(savedPath);

      // Reload the images list
      await _loadSavedImages();

      showSuccess('Image saved successfully!', context);
    } catch (e) {
      showError(context, 'Failed to save image: $e');
      setState(() => _isLoading = false);
    }
  }

  // Delete an image from storage
  Future<void> _deleteImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        await _loadSavedImages();
        showSuccess('Image deleted', context);
      }
    } catch (e) {
      showError(context, 'Failed to delete image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _isConnected
            ? Icon(Icons.fiber_manual_record, color: Colors.green)
            : Icon(Icons.fiber_manual_record, color: Colors.red),
        title: const Text('Image Storage'),
        actions: [
          _isConnected
              ? IconButton(
                  onPressed: () => scaffoldMessenger(
                    context,
                    Icons.cloud_done,
                    'Synced!',
                    true,
                  ),
                  icon: Icon(Icons.cloud_done),
                )
              : IconButton(
                  icon: const Icon(Icons.cloud_off),
                  onPressed: () => scaffoldMessenger(
                    context,
                    Icons.wifi_off,
                    'No internet connection!',
                    false,
                  ),
                ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _savedImagePaths.isEmpty
          ? const Center(
              child: Text(
                'No images saved yet',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _savedImagePaths.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      contentPadding: EdgeInsetsGeometry.all(0),
                      content: ClipRRect(
                        borderRadius: BorderRadiusGeometry.all(
                          Radius.circular(10),
                        ),
                        child: Image.file(
                          File(_savedImagePaths[index]),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(
                          File(_savedImagePaths[index]),
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            style: IconButton.styleFrom(
                              // ignore: deprecated_member_use
                              backgroundColor: Colors.red.withOpacity(0.5),
                            ),
                            onPressed: () =>
                                _deleteImage(_savedImagePaths[index]),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: [BottomNavigationBarItem(icon: Icon(Icons.camera),)],
      // ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'camera',
        onPressed: _pickImageFromCamera,
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
