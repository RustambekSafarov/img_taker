import 'package:hive/hive.dart';
import 'package:img_taker/models/vehicle.dart';
import 'package:img_taker/services/backend.dart';
import 'package:img_taker/services/saving_service.dart';

class UploaderService {
  static final UploaderService _instance = UploaderService._internal();
  factory UploaderService() => _instance;
  UploaderService._internal();

  /// Scans Hive for pending uploads (isUploaded == false) and attempts to upload them.
  Future<void> retryPendingUploads(String token) async {
    try {
      final box = await Hive.openBox<VehicleModel>('vehicles');
      for (int i = 0; i < box.length; i++) {
        final obj = box.getAt(i);
        if (obj == null) continue;
        if (obj.isUploaded) continue;
        try {
          final result = await sendImage(
            token,
            obj.imagePaths,
            DateTime.parse(obj.timeCreation),
            obj.eventType,
          );
          if (result['images'] != null) {
            // updateObject will set remoteImagePaths and isUploaded
            await updateObject(result['images'], i);
            print('Uploaded object at index $i');
          }
        } catch (e) {
          print('Upload failed for index $i: $e');
        }
      }
    } catch (e) {
      print('retryPendingUploads error: $e');
    }
  }
}
