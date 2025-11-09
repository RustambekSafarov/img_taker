import 'dart:io';

import 'package:hive/hive.dart';
import 'package:img_taker/models/vehicle.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

Future<void> saveObject(
  List<Map> paths,
  String eventType,
  DateTime timeStamp, {
  List<Map>? remotePaths,
}) async {
  final box = await Hive.openBox<VehicleModel>('vehicles');
  final vehicle = VehicleModel(
    imagePaths: paths,
    remoteImagePaths: remotePaths,
    timeCreation: timeStamp.toIso8601String(),
    eventType: eventType,
    isUploaded: remotePaths != null,
  );
  box.add(vehicle);
}

Future<List<VehicleModel>> getObjects() async {
  final box = await Hive.openBox<VehicleModel>('vehicles');
  print(box.values.toList());
  return box.values.toList();
}

Future<void> updateObject(List<Map> remotePaths, int index) async {
  final box = await Hive.openBox<VehicleModel>('vehicles');
  final object = box.getAt(index);
  print("index at $object");
  object?.remoteImagePaths = remotePaths;
  object?.isUploaded = true;
  await object?.save();
}

Future<List<Map>> saveToStorage(List<Map> images) async {
  final directory = await getApplicationDocumentsDirectory();
  final fileCollection = DateTime.now().toIso8601String();
  final imagesDir = Directory('${directory.path}/images/$fileCollection/');
  if (!await imagesDir.exists()) {
    await imagesDir.create(recursive: true);
  }
  final savedPath = imagesDir.path;
  List<Map> savedImages = [];

  for (int i = 0; i < images.length; i++) {
    // Preserve original extension when saving. images[i]['image'] is expected to be an XFile
    final dynamic img = images[i]['image'];
    String originalPath = '';
    try {
      originalPath = img.path ?? '';
    } catch (_) {
      originalPath = '';
    }
    final ext = originalPath.isNotEmpty ? p.extension(originalPath) : '.jpg';
    final filename = '${images[i]['type']}$ext';
    final dest = p.join(savedPath, filename);
    // XFile has saveTo; if not, this will throw and bubble up
    await images[i]['image'].saveTo(dest);
    savedImages.add({'image': dest, 'type': images[i]['type']});
  }
  return savedImages;
}
