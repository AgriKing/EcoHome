import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/device.dart';

class ApiService {
  static const String _baseUrl = 'https://ecohome-server.onrender.com'; // Adjust if hosted

  static Future<List<Map<String, String>>> getRecommendations(List<Device> devices) async {
    final url = Uri.parse('$_baseUrl/recommend');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'devices': devices.map((device) => device.toMap()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, String>>.from(data['recommendations']);
    } else {
      throw Exception('Failed to fetch recommendations');
    }
  }
}
