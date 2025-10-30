import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  // dynamic width and height

  // file
  File? image;

  // image picker
  final picker = ImagePicker();

  // pick image method
  Future<void> pickImage(ImageSource source) async {
    // pick from camera or gallery
    final pickFile = await picker.pickImage(source: source);

    // update selected image
    if (pickFile != null) {
      setState(() {
        image = File(pickFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 300,
              height: 300,
              child: image != null
                  ?
                    // image selected
                    Image.file(image!)
                  :
                    // no image selected
                    Center(child: Text('No image selected')),
            ),
            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.camera),
                  child: Text('Camera'),
                ),
                ElevatedButton(
                  onPressed: () => pickImage(ImageSource.gallery),
                  child: Text('Gallery'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
