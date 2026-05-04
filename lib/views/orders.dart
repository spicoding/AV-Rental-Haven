import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import '../views/homescreen.dart';
import 'checkout.dart';
import 'dart:io';

class OrderController extends GetxController {
  // Reactive list of items in the cart
  var orders = <CartItem>[].obs;
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;
  var currentUserId = ''.obs; // Start as empty string
  var currentUser =
      Rxn<User>(); // Stores logged-in user details for the profile
  var rentalHistory =
      <dynamic>[].obs; // Added to fix rental_history.dart errors
  var products = <Product>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    isLoading.value = true;
    final fetched = await _apiService.fetchProducts();
    products.assignAll(fetched);
    isLoading.value = false;
  }

  Future<void> fetchRentalHistory() async {
    if (currentUserId.value.isEmpty) return;
    final history = await _apiService.fetchRentalHistory(currentUserId.value);
    rentalHistory.assignAll(history);
  }

  // Call this method from your LoginController or SignUpController
  // after a successful API response to update the profile UI
  void setUser(User user) {
    currentUser.value = user;
    currentUserId.value = user.id ?? '';
    fetchRentalHistory();
  }

  // Added to fix products.dart error
  void addOrder(Map<String, dynamic> productData) {
    // Convert mock map data from products.dart to the Product model
    double price =
        double.tryParse(
          productData['price'].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;

    final product = Product(
      productId: productData['name'].hashCode.toString(),
      productName: productData['name'],
      unitPrice: price,
    );

    // Now that we use relative paths in the DB, we just pass the image as is
    // ApiService handles the full URL construction
    addItem(product, imageUrl: productData['image']);
  }

  void addItem(Product product, {String? imageUrl}) {
    // Check if item already exists, if so, increment quantity
    final existingItemIndex = orders.indexWhere(
      (item) => item.product.productId == product.productId,
    );
    if (existingItemIndex != -1) {
      // Increment quantity if item already exists in cart
      final existingItem = orders[existingItemIndex];
      orders[existingItemIndex] = CartItem.fromProduct(
        existingItem.product,
        quantity: existingItem.quantity + 1,
        imageUrl: existingItem.imageUrl ?? imageUrl,
      );
    } else {
      orders.add(
        CartItem.fromProduct(product, quantity: 1, imageUrl: imageUrl),
      );
    }
  }

  void removeItem(int index) {
    orders.removeAt(index);
  }

  // This getter calculates the total amount of all items in the cart
  double get totalAmount {
    return orders.fold(0, (sum, item) {
      return sum + (item.product.unitPrice * item.quantity);
    });
  }

  Future<bool> processCheckout(String phoneNumber) async {
    if (orders.isEmpty) return false;

    isLoading.value = true;
    try {
      // 1. Initiate M-Pesa Payment
      final mpesaResponse = await _apiService.initiateMpesaPayment(
        phoneNumber,
        totalAmount,
        currentUserId.value,
      );

      if (mpesaResponse['status'] != 'success') {
        Get.snackbar(
          "Payment Error",
          mpesaResponse['message'] ?? "STK Push failed",
        );
        return false;
      }

      final checkoutRequestId = mpesaResponse['CheckoutRequestID'].toString();

      if (checkoutRequestId == "null") {
        Get.snackbar("Error", "Invalid checkout reference received.");
        return false;
      }

      // --- Transaction Verification (Polling) ---
      bool isVerified = false;
      int attempts = 0;
      const int maxAttempts = 12; // Wait for up to 60 seconds (5s * 12)

      while (attempts < maxAttempts && !isVerified) {
        await Future.delayed(const Duration(seconds: 5));
        final statusCheck = await _apiService.checkMpesaStatus(
          checkoutRequestId,
        );

        final String status =
            statusCheck['status']?.toString().toLowerCase() ?? '';
        final String message =
            statusCheck['message']?.toString().toLowerCase() ?? '';

        // Handle cases where status is 'success' OR message indicates authorization/success
        if (status == 'success' ||
            message.contains('authorized') ||
            message.contains('successful')) {
          isVerified = true;
          break;
        }

        // Handle cases where the status check fails due to server-side authentication issues with Safaricom
        if (status == 'error' &&
            (message.contains('authentication failed') ||
                message.contains('unauthorized'))) {
          Get.snackbar(
            "Payment Status Pending",
            "The server had trouble verifying your payment instantly. If your M-Pesa transaction was successful, we will proceed with your order.",
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            duration: const Duration(seconds: 7),
          );
          isVerified = true;
          break;
        }

        // M-Pesa explicitly failed (and not just 'failed' with 'authorized' message)
        if (status == 'failed' && !message.contains('authorized')) {
          Get.snackbar(
            "Payment Failed",
            statusCheck['message'] ?? "M-Pesa transaction failed.",
          );
          return false;
        }

        // Any other generic error from the status check (not authentication failure)
        if (status == 'error') {
          Get.snackbar(
            "Payment Status Error",
            statusCheck['message'] ??
                "Could not verify payment with the server.",
          );
          return false;
        }
        attempts++;
      }

      if (!isVerified) {
        Get.snackbar(
          "Verification Timeout",
          "We haven't received confirmation yet. Please check your history later.",
        );
        return false;
      }

      // 2. Save Payment Record to DB
      final payment = PaymentModel(
        userId: currentUserId.value,
        paymentMethod: 'mpesa',
        amount: totalAmount,
        transactionReference: checkoutRequestId,
        status: 'completed',
        phoneNumber: phoneNumber,
      );

      final savePaymentResponse = await _apiService.savePaymentRecord(payment);

      if (savePaymentResponse['status'] != 'success') {
        Get.snackbar("Error", "Failed to record payment info.");
        return false;
      }

      final String paymentId = savePaymentResponse['payment_id'].toString();

      // 3. Map UI items for the order
      final databaseReadyOrders = orders.map((item) {
        return {
          ...item.toOrderItemMap(),
          'image': item.imageUrl, // Explicitly include the absolute path
        };
      }).toList();

      final orderResponse = await _apiService.submitOrder(
        currentUserId.value,
        paymentId,
        totalAmount,
        databaseReadyOrders,
      );

      if (orderResponse['status'] == 'success') {
        _showSuccessDialog();
        return true;
      } else {
        Get.snackbar(
          "Order Error",
          orderResponse['message'] ?? "Failed to place order record.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return false;
      }
    } catch (e) {
      print("Checkout Exception: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _showSuccessDialog() {
    Get.defaultDialog(
      title: "Order Successful!",
      middleText: "Your payment was processed and your order has been placed.",
      backgroundColor: Colors.white,
      titleStyle: const TextStyle(
        color: Colors.black,
        fontWeight: FontWeight.bold,
      ),
      middleTextStyle: const TextStyle(color: Colors.black54),
      confirm: ElevatedButton(
        onPressed: () {
          orders.clear();
          fetchRentalHistory();
          Get.offAll(() => const HomeScreen());
        },
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
        child: const Text("Go to Home", style: TextStyle(color: Colors.white)),
      ),
      barrierDismissible: false,
    );
  }

  Future<bool> processCardCheckout({
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) async {
    if (orders.isEmpty) return false;

    isLoading.value = true;
    try {
      final cardResponse = await _apiService.processCardPayment(
        userId: currentUserId.value,
        amount: totalAmount,
        cardNumber: cardNumber,
        expiry: expiry,
        cvv: cvv,
      );

      if (cardResponse['status'] != 'success') {
        Get.snackbar(
          "Payment Error",
          cardResponse['message'] ?? "Card processing failed",
        );
        return false;
      }

      final transactionId = cardResponse['transaction_id'].toString();
      final payment = PaymentModel(
        userId: currentUserId.value,
        paymentMethod: 'card',
        amount: totalAmount,
        transactionReference: transactionId,
        status: 'completed',
        cardLastFour: cardNumber.substring(cardNumber.length - 4),
      );

      final savePaymentResponse = await _apiService.savePaymentRecord(payment);
      if (savePaymentResponse['status'] != 'success') {
        Get.snackbar("Error", "Failed to save payment record.");
        isLoading.value = false;
        return false;
      }

      final String paymentId = savePaymentResponse['payment_id'].toString();
      final databaseReadyOrders = orders.map((item) {
        return {
          ...item.toOrderItemMap(),
          'image': item.imageUrl, // Store the web URL path for the order item
        };
      }).toList();

      final orderResponse = await _apiService.submitOrder(
        currentUserId.value,
        paymentId,
        totalAmount,
        databaseReadyOrders,
      );

      if (orderResponse['status'] == 'success') {
        orders.clear();
        _showSuccessDialog(); // Call success dialog for card payments too
        return true;
      } else {
        Get.snackbar(
          "Order Error",
          orderResponse['message'] ?? "Failed to place order.",
        );
        return false;
      }
    } catch (e) {
      print("Card Checkout Exception: $e");
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.find<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        foregroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.orders.isEmpty) {
          return const Center(child: Text('Your cart is empty'));
        }
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: controller.orders.length,
                itemBuilder: (context, index) {
                  final item = controller.orders[index];
                  return ListTile(
                    leading: _buildLeadingImage(item.imageUrl),
                    title: Text(item.product.productName),
                    subtitle: Text('Quantity: ${item.quantity}'),
                    trailing: Text(
                      'Ksh ${(item.product.unitPrice * item.quantity).toStringAsFixed(2)}',
                    ),
                    onLongPress: () => controller.removeItem(index),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Total: Ksh ${controller.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.to(() => CheckoutScreen()),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Proceed to Checkout',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildLeadingImage(String? path) {
    if (path == null) return _imagePlaceholder();

    if (path.startsWith('http')) {
      return Image.network(
        path,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
        errorBuilder: (c, e, s) => _imagePlaceholder(),
      );
    }
    return Image.asset(
      path,
      width: 50,
      height: 50,
      fit: BoxFit.cover,
      errorBuilder: (c, e, s) => _imagePlaceholder(),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 50,
      height: 50,
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_not_supported, color: Colors.grey),
    );
  }
}
