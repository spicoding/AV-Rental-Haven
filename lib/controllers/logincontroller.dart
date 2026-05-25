import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../views/orders.dart';
import '../views/homescreen.dart';
import '../models/user_model.dart';

class LoginController extends GetxController {
  final ApiService _apiService = ApiService();

  // Safely find the OrderController or initialize it if it's missing
  OrderController get _orderController => Get.isRegistered<OrderController>()
      ? Get.find<OrderController>()
      : Get.put(OrderController(), permanent: true);

  var isLoading = false.obs;
  var isObscured = true.obs;

  Future<void> login(String email, String password) async {
    // 1. Hardcoded Admin Bypass (Optional)
    if (email == "admin" && password == "34493370") {
      final adminUser = User(
        id: "admin_system_uid",
        fullName: "System Admin",
        emailAddress: "admin@avhaven.com",
      );
      _orderController.setUser(adminUser);
      Get.offAll(() => const HomeScreen());
      Get.snackbar("Success", "Logged in as Admin");
      return;
    }

    // 2. Standard Database Login
    isLoading.value = true;
    final response = await _apiService.loginUser(email, password);
    isLoading.value = false;

    if (response['status'] == 'success') {
      // Capture full user details from the response
      final user = response['user'] as User;
      _orderController.setUser(user);

      Get.snackbar("Success", "Welcome back!");
      Get.offAll(() => const HomeScreen());
    } else {
      Get.snackbar(
        "Login Failed",
        response['message'] ?? "Invalid credentials",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void togglePassword() {
    isObscured.value = !isObscured.value;
  }
}
