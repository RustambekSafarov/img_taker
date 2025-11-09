import 'package:hive/hive.dart';

part 'vehicle.g.dart';

@HiveType(typeId: 0)
class VehicleModel extends HiveObject {
  @HiveField(0)
  String timeCreation;

  @HiveField(1)
  String eventType;

  @HiveField(2)
  String? licensePlate;

  @HiveField(3)
  bool isUploaded;

  @HiveField(4)
  List<Map> imagePaths;

  @HiveField(5)
  List<Map>? remoteImagePaths;

  VehicleModel({
    required this.imagePaths,
    required this.timeCreation,
    required this.eventType,
    this.remoteImagePaths,
    this.isUploaded = false,
    this.licensePlate,
  });
}
