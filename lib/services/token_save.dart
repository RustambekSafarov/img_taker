import 'package:shared_preferences/shared_preferences.dart';

Future<bool> saveToken(String token, String user) async {
  try {
    final prefs = await SharedPreferences.getInstance();

    return await prefs.setString('token', token) &&
        await prefs.setString('user', user);
  } catch (e) {
    print('Error saving token: $e');
    return false;
  }
}

// Get authentication token
Future<List?> getToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final user = prefs.getString('user');
    return [token, user];
  } catch (e) {
    print('Error getting token: $e');
    return null;
  }
}

Future<void> deleteToken() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('token');
    prefs.remove('user');
  } catch (e) {
    print('Error getting token: $e');
    return null;
  }
}
