import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

String baseUrl = 'https://report-apis.absvision.ai/veemly_api';

Future<List> signIn(String phone, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/sign-in'),
    body: jsonEncode({"phone_number": "+998$phone", "password": password}),
    headers: {"Content-Type": "application/json"},
  );

  Map jsonData = jsonDecode(response.body);
  print(response.statusCode);
  List data = [jsonData['access_token'], jsonData['user']['full_name']];
  return response.statusCode == 200 ? data : ['error'];
}

Future<List> getVehicles(String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/vehicles/'),
    headers: {
      "Content-Type": "application/json",
      'Authorization': 'Bearer $token',
    },
  );

  Map jsonData = jsonDecode(response.body);

  return jsonData['vehicles'];
}

Future<Map> sendImage(
  String token,
  List<Map> images,
  DateTime time,
  String eventType,
) async {
  final url = Uri.parse(
    '$baseUrl/vehicles/?event_type=$eventType&timestamp=${time.toIso8601String()}',
  );
  // For multipart requests, let the MultipartRequest set Content-Type.
  var headers = {"Authorization": "Bearer $token"};
  final request = http.MultipartRequest('POST', url);
  request.headers.addAll(headers);

  for (int i = 0; i < images.length; i++) {
    final filePath = images[i]['image'];
    print(filePath);
    final filename = basename(filePath);

    request.files.add(
      await http.MultipartFile.fromPath(
        '${images[i]['type']}_image',
        filePath,
        filename: filename,
        contentType: MediaType('image', 'jpeg'),
      ),
    );
  }

  final response = await request.send();
  final res = await http.Response.fromStream(response);
  print(res.body);
  final data = jsonDecode(res.body);

  // Ensure images array is properly cast to List<Map<String, dynamic>>
  if (data['images'] != null && data['images'] is List) {
    data['images'] = (data['images'] as List).map((item) {
      if (item is Map) {
        return Map<String, dynamic>.from(item);
      }
      return <String, dynamic>{};
    }).toList();
  }

  return data;
}
