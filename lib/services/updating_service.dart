import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive/hive.dart';

Future<void> checkAndClearIfExpired() async {
  final box = await Hive.openBox('timeStamp');

  // Get the stored lastUpdate
  DateTime? lastUpdate = box.get('lastUpdate');

  if (lastUpdate != null) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);

    // Check if more than 24 hours have passed
    if (difference.inHours >= 24) {
      await box.clear();
      print('Box cleared - more than 24 hours passed');

      // Optional: Set new lastUpdate after clearing
      await box.put('lastUpdate', DateTime.now());
    } else {
      print('Data is still valid - ${24 - difference.inHours} hours remaining');
    }
  } else {
    // No lastUpdate found, set it now
    await box.put('lastUpdate', DateTime.now());
  }
}

Future<void> saveLastUpdateTime() async {
  final box = await Hive.openBox('timeStamp');

  await box.put('lastUpdate', DateTime.now()); // Update timestamp
}
