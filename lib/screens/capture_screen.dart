// ignore_for_file: avoid_print, unused_field

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_taker/services/camera_service.dart';
import 'package:img_taker/services/connectivity_service.dart';
import 'package:img_taker/services/saving_service.dart';
import 'package:img_taker/widgets/vehicle_detail.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  CameraController? _controller;
  List<CameraDescription>? cameras;
  bool _isInitialized = false;

  bool _isSvgF = true;
  bool _isSvgR = true;
  bool _isSvgI = true;
  File? imageFront;
  File? imageRear;
  File? imageInvoice;
  List<Map<String, dynamic>> images = [];
  final ImagePicker _picker = ImagePicker();
  int iconIndex = 0;
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;
  bool _isLoading = false;
  DateTime timeStamp = DateTime.now();

  @override
  void initState() {
    super.initState();
    _connectivityService.initialize();
    _initializeCamera();

    _connectivityService.connectionStatus.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    if (cameras!.isNotEmpty) {
      _controller = CameraController(
        cameras![0], // Use back camera
        ResolutionPreset.high,
      );
      await _controller!.initialize();
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String eventType = args['type'] == 1 ? 'enter' : 'exit';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back,
            // size: 30,
            size: MediaQuery.of(context).size.width / 22,
          ),
        ),
      ),
      body: Stack(
        children: [
          ListView(
            children: [
              SizedBox(height: MediaQuery.of(context).size.height / 40),
              Row(
                children: [
                  CarDetailWidget(
                    isSvg: _isSvgF,
                    image: imageFront ?? File('assets/front.svg'),
                    title: 'Mashinaning old qismi',
                    func: () async {
                      timeStamp = DateTime.now();
                      print('front');
                      try {
                        // final XFile? image = await _picker.pickImage(
                        //   source: ImageSource.camera,
                        //   maxWidth: 1800,
                        //   maxHeight: 1800,
                        // );
                        final File? image = await Navigator.push<File>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuickCameraScreen(),
                          ),
                        );

                        if (image != null) {
                          if (!mounted) return;
                          setState(() {
                            imageFront = image;
                            print(imageFront);
                            if (images.any((m) => m['type'] == 'front')) {
                              images.removeWhere((m) => m['type'] == 'front');
                            }
                            images.add(<String, dynamic>{
                              'image': image,
                              'type': 'front',
                            });
                            print(images);
                            _isSvgF = false;
                          });
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                      _isSvgF = false;
                    },
                  ),

                  SizedBox(height: MediaQuery.of(context).size.height / 40),
                  CarDetailWidget(
                    isSvg: _isSvgR,
                    image: imageRear ?? File('assets/rear.svg'),
                    title: 'Mashinaning orqa qismi',
                    func: () async {
                      timeStamp = DateTime.now();
                      try {
                        // final XFile? image = await _picker.pickImage(
                        //   source: ImageSource.camera,
                        //   maxWidth: 1800,
                        //   maxHeight: 1800,
                        // );
                        final File? image = await Navigator.push<File>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuickCameraScreen(),
                          ),
                        );

                        if (image != null) {
                          if (!mounted) return;
                          setState(() {
                            imageRear = image;
                            if (images.any((m) => m['type'] == 'rear')) {
                              images.removeWhere((m) => m['type'] == 'rear');
                            }
                            images.add(<String, dynamic>{
                              'image': image,
                              'type': 'rear',
                            });
                            print(images);
                            _isSvgR = false;
                          });
                        }
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                            backgroundColor: Colors.red,
                            duration: const Duration(seconds: 3),
                            behavior: SnackBarBehavior.floating,
                            margin: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        );
                      }
                      print('rear');
                    },
                  ),
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height / 40),
              CarDetailWidget(
                isSvg: _isSvgI,
                image: imageInvoice ?? File('assets/invoice.svg'),
                title: 'Nakladnoy',
                func: () async {
                  timeStamp = DateTime.now();
                  try {
                    // final XFile? image = await _picker.pickImage(
                    //   source: ImageSource.camera,
                    //   maxWidth: 1800,
                    //   maxHeight: 1800,
                    // );
                    final File? image = await Navigator.push<File>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const QuickCameraScreen(),
                      ),
                    );
                    if (image != null) {
                      if (!mounted) return;
                      if (images.any((m) => m['type'] == 'invoice')) {
                        images.removeWhere((m) => m['type'] == 'invoice');
                      }
                      setState(() {
                        imageInvoice = image;
                        // keep only the last invoice image (remove any previous invoice entry)
                        images.add(<String, dynamic>{
                          'image': image,
                          'type': 'invoice',
                        });
                        print(images);
                        _isSvgI = false;
                      });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  }

                  print('invoice');
                },
                imagePadding: MediaQuery.of(context).size.height / 40,
              ),
            ],
          ),
          if (_isLoading)
            Center(
              child: Opacity(opacity: 0.5, child: CircularProgressIndicator()),
            ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.fromLTRB(
          MediaQuery.of(context).size.width / 60,
          0,
          MediaQuery.of(context).size.width / 60,
          MediaQuery.of(context).size.width / 60,
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height / 8,
          width: MediaQuery.of(context).size.width / 2.1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: images.isNotEmpty
                  ? Colors.green
                  : Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(2),
              ),
            ),

            onPressed: () async {
              if (images.isEmpty) {
                if (!mounted) return;

                Navigator.pop(context);
                return;
              }

              if (!mounted) return;
              setState(() => _isLoading = true);
              // sort images in order: front, rear, invoice
              final List<Map<String, dynamic>> sortedImages = [];
              for (final t in ['front', 'rear', 'invoice']) {
                final matches = images.where((m) => m['type'] == t).toList();
                if (matches.isNotEmpty) {
                  // for invoice keep the last one, for others keep the first match
                  sortedImages.add(
                    t == 'invoice' ? matches.last : matches.first,
                  );
                }
              }
              final savedImages = await saveToStorage(sortedImages);
              try {
                await saveObject(savedImages, eventType, timeStamp);
                if (mounted) Navigator.pop(context);
              } catch (e) {
                print(e);
                await saveObject(savedImages, eventType, timeStamp);
                if (mounted) Navigator.pop(context);
              } finally {
                if (mounted) setState(() => _isLoading = false);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  images.isNotEmpty ? Icons.done : Icons.login,
                  size: MediaQuery.of(context).size.width / 15,
                  color: Colors.white,
                ),
                Text(
                  images.isNotEmpty ? 'Saqlash' : 'Bosh sahifa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: MediaQuery.of(context).size.width / 28,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
