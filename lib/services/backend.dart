import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:http_parser/http_parser.dart';

String baseUrl = 'https://absvision.ai/api/v1';

Future<String> signIn(String phone, String password) async {
  final response = await http.post(
    Uri.parse('$baseUrl/auth/sign-in'),
    body: jsonEncode({"phone_number": "+998$phone", "password": password}),
    headers: {"Content-Type": "application/json"},
  );

  Map jsonData = jsonDecode(response.body);
  print(response.statusCode);
  return response.statusCode == 200 ? jsonData['access_token'] : 'error';
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
  var headers = {
    "Authorization": "Bearer $token",
    "Content-Type": "application/json",
  };
  final request = http.MultipartRequest('POST', url);
  request.headers.addAll(headers);

  for (int i = 0; i < images.length; i++) {
    print(images[i]['image']);
    request.files.add(
      await http.MultipartFile.fromPath(
        '${images[i]['type']}_image',
        images[i]['image'],
        filename: basename(images[i]['image']),
        contentType: MediaType('image', 'png'),
      ),
    );
  }

  final response = await request.send();
  final res = await http.Response.fromStream(response);
  print(res.body);
  final data = jsonDecode(res.body);
  return data;
}
