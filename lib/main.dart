import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:img_taker/camera_page.dart';

import 'services/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: CameraPage(), debugShowCheckedModeBanner: false);
  }
}
