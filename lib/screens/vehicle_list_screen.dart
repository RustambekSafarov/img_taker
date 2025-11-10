// ignore_for_file: avoid_print, use_build_context_synchronously

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:img_taker/screens/auth_screen.dart';
import 'package:img_taker/screens/capture_screen.dart';
import 'package:img_taker/screens/vehicle_detail_screen.dart';

import 'package:img_taker/services/connectivity_service.dart';
import 'package:img_taker/services/saving_service.dart';
import 'package:img_taker/services/uploader_service.dart';
import 'package:img_taker/services/token_save.dart';
import 'package:img_taker/widgets/scaffold_message.dart';
import 'package:intl/intl.dart';

class VehicleListScreen extends StatefulWidget {
  const VehicleListScreen({super.key});

  @override
  State<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends State<VehicleListScreen> {
  final ConnectivityService _connectivityService = ConnectivityService();
  List _savedImagePaths = [];
  bool _isLoading = false;
  bool _isConnected = true;
  String? token = '';

  @override
  void initState() {
    super.initState();
    _checkToken();
    _getVehicles();

    // getAllEvents();
    _connectivityService.initialize();
    _connectivityService.connectionStatus.listen((isConnected) async {
      setState(() {
        _isConnected = isConnected;
      });
      // When reconnected, try to upload pending items
      if (isConnected && token != null) {
        await UploaderService().retryPendingUploads(token!);
        _savedImagePaths = await getObjects();
        setState(() {});
      }
    });
  }

  Future<void> _checkToken() async {
    token = await getToken();
  }

  Future<void> _getVehicles() async {
    final vehicles = getObjects();
    _savedImagePaths = await vehicles;
    setState(() {
      print(_savedImagePaths);
    });
  }
  // Load all saved images from app storage

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    // print(_savedImagePaths);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: _isConnected
            ? Icon(Icons.fiber_manual_record, color: Colors.green)
            : Icon(Icons.fiber_manual_record, color: Colors.red),
        title: const Text('Saqlanganlar'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return AuthScreen();
                  },
                ),
              );
            },
            child: Text('User', style: TextStyle(color: Colors.black)),
          ),
          _isConnected
              ? IconButton(
                  onPressed: () async {
                    setState(() => _isLoading = true);
                    try {
                      await UploaderService().retryPendingUploads(token!);
                      _savedImagePaths = await getObjects();
                      scaffoldMessenger(
                        context,
                        Icons.cloud_done,
                        'Synced!',
                        true,
                      );
                      setState(() {});
                    } finally {
                      setState(() => _isLoading = false);
                    }
                    // scaffoldMessenger(
                    //   context,
                    //   Icons.cloud_done,
                    //   'Synced!',
                    //   true,
                    // );
                  },
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
      body: Stack(
        children: [
          ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: _savedImagePaths.length,
            itemBuilder: (context, index) {
              // print(_savedImagePaths[index].imagePaths);
              return Card(
                child: ListTile(
                  trailing: _savedImagePaths[index].isUploaded
                      ? Icon(Icons.done)
                      : Icon(Icons.cloud_off),

                  onTap: () {
                    print(_savedImagePaths[index].imagePaths);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VehicleDetailScreen(),
                        settings: RouteSettings(
                          arguments: {
                            'data': _savedImagePaths[index].imagePaths,
                          },
                        ),
                      ),
                    );
                  },
                  leading: SizedBox(
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(10),
                      child: Image.file(
                        File(_savedImagePaths[index].imagePaths[0]['image']!),
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width / 11,
                        height: MediaQuery.of(context).size.width / 10,
                      ),
                    ),
                  ),
                  title: Text(
                    DateFormat('MMM d, yyyy h:mm a').format(
                      DateTime.parse(_savedImagePaths[index].timeCreation),
                    ),
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: MediaQuery.of(context).size.width / 32,
                    ),
                  ),
                  subtitle: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            (_savedImagePaths[index].imagePaths as List)
                                .map((p) {
                                  String type = p['type']?.toString() ?? '';
                                  switch (type) {
                                    case 'front':
                                      return 'Old';
                                    case 'rear':
                                      return 'Orqa';
                                    case 'invoice':
                                      return 'Nakladnoy';
                                    default:
                                      return type;
                                  }
                                })
                                .where((s) => s.isNotEmpty)
                                .join(' • '),
                            style: TextStyle(
                              fontWeight: FontWeight.w300,
                              fontSize: MediaQuery.of(context).size.width / 37,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _savedImagePaths[index].eventType == 'enter'
                              ? Icon(Icons.login, color: Colors.greenAccent)
                              : Icon(Icons.logout, color: Colors.redAccent),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // if (_isLoading)
          //   Center(
          //     child: Opacity(
          //       opacity: 0.5,
          //       child: SizedBox(
          //         width: double.infinity,
          //         height: double.infinity,
          //         child: CircularProgressIndicator(),
          //       ),
          //     ),
          //   ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.fromLTRB(
          0,
          0,
          0,
          MediaQuery.of(context).size.width / 60,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height / 8,
              width: MediaQuery.of(context).size.width / 2.1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(2),
                  ),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CaptureScreen(),
                      settings: RouteSettings(
                        arguments: {"type": 1, "token": args['token']},
                      ),
                    ),
                  );
                  _savedImagePaths = await getObjects();
                  await UploaderService().retryPendingUploads(token!);
                  setState(() {});
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
                      'Kirish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width / 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: MediaQuery.of(context).size.height / 8,
              width: MediaQuery.of(context).size.width / 2.1,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(2),
                  ),
                ),
                onPressed: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CaptureScreen(),
                      settings: RouteSettings(
                        arguments: {"type": 2, "token": args['token']},
                      ),
                    ),
                  );
                  _savedImagePaths = await getObjects();
                  await UploaderService().retryPendingUploads(token!);
                  setState(() {});
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.logout,
                      size: MediaQuery.of(context).size.width / 15,
                      color: Colors.white,
                    ),
                    Text(
                      'Chiqish',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width / 28,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
