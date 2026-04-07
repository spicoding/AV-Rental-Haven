import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Use '10.0.2.2' for Android Emulator to refer to your PC's localhost.
  // If using a physical device, replace this with your PC's IP (e.g., 192.168.1.5)
  static const String baseUrl = 'http://10.0.2.2/av_rental_api/api.php';

  // New method for user registration
  Future<Map<String, dynamic>> registerUser(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "action": "register",
          "full_name": name,
          "email_address": email,
          "password": password,
        }),
      );

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Method to fetch products from the database
  Future<List<dynamic>> fetchProducts() async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"action": "get_products"}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          return data['products'];
        }
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<bool> submitOrder(List<dynamic> orders) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"action": "place_order", "orders": orders}),
          )
          .timeout(const Duration(seconds: 10));

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
