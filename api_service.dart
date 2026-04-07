import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use '10.0.2.2' for Android Emulator to refer to your PC's localhost.
  // For physical devices, use your computer's local IP address (e.g., '192.168.1.5').
  static const String baseUrl = 'http://10.0.2.2/av_rental_api/api.php';

  Future<bool> submitOrder(List<dynamic> orders) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"orders": orders}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }
}
