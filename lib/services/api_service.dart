import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../models/product_model.dart';
import '../models/payment_model.dart';

class ApiService {
  // Use '10.0.2.2' for Android Emulator to refer to your PC's localhost.
  // If using a physical device, replace this with your PC's IP (e.g., 192.168.1.5)
  static const String baseUrl = 'http://10.7.6.169/av_rental_api/api.php';

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

      print("HTTP Status (${response.statusCode}) for $fullName");

      if (response.statusCode == 500) {
        return {
          "status": "error",
          "message":
              "Database connection failed. Please ensure your MySQL service is running on the server.",
        };
      }

      if (response.statusCode != 200) {
        return {
          "status": "error",
          "message":
              "Server error (${response.statusCode}). Check your API logs.",
        };
      }

      if (response.body.isEmpty) {
        return {
          "status": "error",
          "message": "Server returned an empty response.",
        };
      }

      try {
        final decoded = jsonDecode(response.body);
        print("API Response ($fullName): ${response.body}");
        return decoded;
      } catch (e) {
        print("JSON Parsing Error: $e. Response Body: ${response.body}");
        return {
          "status": "error",
          "message":
              "The server returned an invalid response. The database might be offline.",
        };
      }
    } on TimeoutException {
      return {
        "status": "error",
        "message":
            "Connection timed out. Please check if your server at $baseUrl is reachable.",
      };
    } on http.ClientException catch (e) {
      return {"status": "error", "message": "Network error: ${e.message}"};
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> loginUser(String email, String password) async {
    // This method returns Map<String, dynamic> which includes user details
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

      print("HTTP Status (${response.statusCode}) for Login");

      if (response.statusCode == 500) {
        return {
          "status": "error",
          "message":
              "Database error: The server could not connect to the database. Verify that MySQL is started.",
        };
      }

      if (response.statusCode != 200) {
        return {
          "status": "error",
          "message":
              "Server error (${response.statusCode}). Check your database connection.",
        };
      }

      if (response.body.isEmpty) {
        return {
          "status": "error",
          "message": "Server returned an empty response.",
        };
      }

      try {
        final decoded = jsonDecode(response.body);
        print("Login Response: ${response.body}");
        return decoded;
      } catch (e) {
        print("JSON Parsing Error: $e. Response Body: ${response.body}");
        return {
          "status": "error",
          "message":
              "Invalid response from server. Please verify the database is running.",
        };
      }
    } on TimeoutException {
      return {
        "status": "error",
        "message":
            "Login timed out. Please check your internet and server connection.",
      };
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

  Future<bool> submitOrder(
    int userId,
    int paymentId,
    List<Map<String, dynamic>> orderItems,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "place_order",
              "user_id": userId,
              "payment_id": paymentId, // Link to the payment
              "order_items": orderItems, // List of individual items
            }),
          )
          .timeout(const Duration(seconds: 10));
      print("Order Submit Response: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Order Submit Result: ${data['status']}");
        return data['status'] == 'success';
      }
      return false;
    } catch (e) {
      // Catch any exception during the HTTP request or JSON decoding
      print("Error submitting order: $e");
      return false;
    }
  }

  Future<Map<String, dynamic>> initiateMpesaPayment(
    String phoneNumber,
    double amount,
    int userId, // Add userId
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "stk_push",
              "phone_number": phoneNumber,
              "amount": amount, // Send as double
              "user_id": userId, // Send userId
              "platform": "M-Pesa", // Indicate payment platform
            }),
          )
          .timeout(const Duration(seconds: 15));
      print("M-Pesa API Response: ${response.body}");

      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> processCardPayment({
    required int userId,
    required double amount,
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "action": "card_payment",
              "user_id": userId,
              "amount": amount,
              "card_number": cardNumber,
              "expiry": expiry,
              "cvv": cvv,
            }),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }

  Future<Map<String, dynamic>> savePaymentRecord(PaymentModel payment) async {
    try {
      final response = await http
          .post(
            Uri.parse(baseUrl),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({"action": "save_payment", ...payment.toJson()}),
          )
          .timeout(const Duration(seconds: 10));
      return jsonDecode(response.body);
    } catch (e) {
      return {"status": "error", "message": e.toString()};
    }
  }
}
