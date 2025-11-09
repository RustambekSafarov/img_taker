// ignore_for_file: avoid_print, unused_field

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:img_taker/services/backend.dart';
import 'package:img_taker/services/connectivity_service.dart';
import 'package:img_taker/services/saving_service.dart';
import 'package:img_taker/widgets/vehicle_detail.dart';

class CaptureScreen extends StatefulWidget {
  const CaptureScreen({super.key});

  @override
  State<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends State<CaptureScreen> {
  bool _isSvgF = true;
  bool _isSvgR = true;
  bool _isSvgI = true;
  XFile? imageFront;
  XFile? imageRear;
  XFile? imageInvoice;
  List<Map> images = [];
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

    _connectivityService.connectionStatus.listen((isConnected) {
      setState(() {
        _isConnected = isConnected;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    String eventType = args['type'] == 1 ? 'enter' : 'exit';
    String token = args["token"];
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
      body: ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height / 40),
          Row(
            children: [
              CarDetailWidget(
                isSvg: _isSvgF,
                image: imageFront ?? XFile('assets/front.svg'),
                title: 'Mashinaning old qismi',
                func: () async {
                  timeStamp = DateTime.now();
                  print('front');
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1800,
                      maxHeight: 1800,
                    );

                    if (image != null) {
                      if (!mounted) return;
                      setState(() {
                        imageFront = image;
                        images.add({'image': image, 'type': 'front'});
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
                image: imageRear ?? XFile('assets/rear.svg'),
                title: 'Mashinaning orqa qismi',
                func: () async {
                  timeStamp = DateTime.now();
                  try {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1800,
                      maxHeight: 1800,
                    );

                    if (image != null) {
                      if (!mounted) return;
                      setState(() {
                        imageRear = image;
                        images.add({'image': image, 'type': 'rear'});
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
            image: imageInvoice ?? XFile('assets/invoice.svg'),
            title: 'Nakladnoy',
            func: () async {
              timeStamp = DateTime.now();
              try {
                final XFile? image = await _picker.pickImage(
                  source: ImageSource.camera,
                  maxWidth: 1800,
                  maxHeight: 1800,
                );
                if (image != null) {
                  if (!mounted) return;
                  setState(() {
                    imageInvoice = image;
                    images.add({'image': image, 'type': 'invoice'});
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
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(2),
              ),
            ),

            onPressed: () async {
              if (images.isEmpty) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please capture at least one image'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              if (!mounted) return;
              setState(() => _isLoading = true);
              final savedImages = await saveToStorage(images);
              try {
                // Use saved file paths for upload (images were saved to disk)
                final data = await sendImage(
                  token,
                  savedImages,
                  timeStamp,
                  eventType,
                );
                await saveObject(
                  savedImages,
                  eventType,
                  timeStamp,
                  remotePaths: data['images'],
                );
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
                  Icons.login,
                  size: MediaQuery.of(context).size.width / 15,
                  color: Colors.white,
                ),
                Text(
                  'Bosh sahifa',
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
