import 'package:shared_preferences/shared_preferences.dart';

Future<bool> saveToken(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString('token', token);
  } catch (e) {
    print('Error saving token: $e');
    return false;
  }
}

// Get authentication token
Future<String?> getToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  } catch (e) {
    print('Error getting token: $e');
    return null;
  }
}
