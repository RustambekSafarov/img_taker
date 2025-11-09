import 'dart:io';

import 'package:hive/hive.dart';
import 'package:img_taker/models/vehicle.dart';
import 'package:path_provider/path_provider.dart';

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
    String x = savedPath + images[i]['type'];
    await images[i]['image'].saveTo(x);
    savedImages.add({'image': x, 'type': images[i]['type']});
  }
  return savedImages;
}
