import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class SignUpController extends GetxController {
  var isLoading = false.obs;
  var isObscured = true.obs;
  final ApiService _apiService = ApiService();

  void togglePassword() {
    isObscured.value = !isObscured.value;
  }

  Future<void> register(String fullName, String email, String password) async {
    try {
      isLoading.value = true;

      final result = await _apiService.registerUser(fullName, email, password);

      if (result['status'] == 'success') {
        Get.snackbar(
          "Success",
          "Account created successfully",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.offAllNamed('/login');
      } else {
        Get.snackbar(
          "Error",
          result['message'] ?? "Registration failed",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
}
