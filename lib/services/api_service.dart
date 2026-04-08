import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';

class ApiService {
  // Use '10.0.2.2' for Android Emulator to refer to your PC's localhost.
  // If using a physical device, replace this with your PC's IP (e.g., 192.168.1.5)
  static const String baseUrl = 'http://10.7.1.55/av_rental_api/api.php';

  // New method for user registration
  Future<Map<String, dynamic>> registerUser(
    String fullName,
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "register", // This is the action for the PHP script
              "full_name": fullName,
              "email_address": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 10));

      final decoded = jsonDecode(response.body);
      print("API Response ($fullName): ${response.body}");
      return decoded;
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "login",
              "email_address": email,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 10));
      final decoded = jsonDecode(response.body);
      print("Login Response: ${response.body}");
      return decoded;
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  // Method to fetch products from the database
  Future<List<Product>> fetchProducts() async {
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
          return (data['products'] as List)
              .map((e) => Product.fromJson(e))
              .toList();
        }
      }
      return []; // Return empty list on failure or no products
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
        print("Order Submit Result: ${data['status']}");
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> initiateMpesaPayment(
    String phoneNumber,
    double amount,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "stk_push",
              "phone_number": phoneNumber,
              "amount": amount
                  .toInt(), // Safaricom expects integers for STK push in sandbox usually
            }),
          )
          .timeout(const Duration(seconds: 15));

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
}
