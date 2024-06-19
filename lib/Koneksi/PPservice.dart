import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = 'http://192.168.100.31/surya4/lib/API/APIPerson.php';

  static Future<Map<String, dynamic>?> fetchConsumerData(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/get_consumer.php'),
        body: {'email': email},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map<String, dynamic> && data['message'] == null) {
          return data;
        } else {
          return null;
        }
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }
}
