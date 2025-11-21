import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:veemly/models/vehicle.dart';
import 'package:veemly/screens/auth_screen.dart';
import 'package:workmanager/workmanager.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print("=== WorkManager task started ===");

      // Initialize Hive
      await Hive.initFlutter();

      // Register adapter (required in separate isolate!)
      if (!Hive.isAdapterRegistered(32)) {
        Hive.registerAdapter(VehicleModelAdapter());
      }

      // Open and clear box
      final box = await Hive.openBox<VehicleModel>('vehicles');
      print("Items before clear: ${box.length}");
      await box.clear();
      print("Hive cleared");

      // Delete images folder
      final appDir = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${appDir.path}/images/');

      if (await imagesDir.exists()) {
        await imagesDir.delete(recursive: true);
        print("Images folder deleted");
      }

      print("=== WorkManager task completed ===");
      return true;
    } catch (e) {
      print("WorkManager error: $e");
      return false;
    }
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(VehicleModelAdapter());

  await Workmanager().initialize(
    callbackDispatcher,
    isInDebugMode: true,
  ); // Add debug mode

  // Use one-off task for testing (runs after 1 minute)
  await Workmanager().registerOneOffTask(
    "testCleanup",
    "imageCleanup",
    initialDelay: Duration(hours: 24),
  );

  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: AuthScreen(), debugShowCheckedModeBanner: false);
  }
}
