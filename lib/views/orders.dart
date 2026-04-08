import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import 'checkout.dart';

class OrderController extends GetxController {
  // Reactive list of items in the cart
  var orders = <CartItem>[].obs;
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;
  var currentUserId = 0.obs; // Start as 0 (logged out)
  var rentalHistory =
      <dynamic>[].obs; // Added to fix rental_history.dart errors

  // Added to fix products.dart error
  void addOrder(Map<String, dynamic> productData) {
    // Convert mock map data from products.dart to the Product model
    double price =
        double.tryParse(
          productData['price'].toString().replaceAll(RegExp(r'[^0-9.]'), ''),
        ) ??
        0.0;

    final product = Product(
      productId: productData['name'].hashCode,
      productName: productData['name'],
      unitPrice: price,
    );

    addItem(product, imageUrl: productData['image']);
  }

  void addItem(Product product, {String? imageUrl}) {
    // Check if item already exists, if so, increment quantity
    final existingItemIndex = orders.indexWhere(
      (item) => item.product.productId == product.productId,
    );
    if (existingItemIndex != -1) {
      // For simplicity, we'll just add a new item. For a real cart, you'd update quantity.
      orders.add(
        CartItem.fromProduct(product, quantity: 1, imageUrl: imageUrl),
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
    if (currentUserId.value == 0) {
      Get.snackbar("Error", "Please log in to place an order.");
      return false;
    }

    isLoading.value = true;
    try {
      // 1. Initiate M-Pesa Payment
      final mpesaResponse = await _apiService.initiateMpesaPayment(
        phoneNumber,
        totalAmount,
      );

      if (mpesaResponse['status'] != 'success') {
        Get.snackbar(
          "Payment Error",
          mpesaResponse['message'] ?? "STK Push failed",
        );
        return false;
      }

      final checkoutRequestId = mpesaResponse['CheckoutRequestID'];

      // 2. Map UI items to the MySQL database schema using the M-Pesa Request ID
      final databaseReadyOrders = orders.map((item) {
        return item.toDatabaseMap(
          location: "Main Campus", // Replace with actual location logic
          userId: currentUserId.value, // Use the dynamic user ID
          paymentId:
              checkoutRequestId, // Use M-Pesa CheckoutRequestID as the payment reference
        );
      }).toList();

      bool success = await _apiService.submitOrder(databaseReadyOrders);

      if (success) {
        orders.clear(); // Empty cart on success
      }
      return success;
    } catch (e) {
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
                    leading: Image.asset(
                      item.imageUrl ?? 'assets/placeholder.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
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
}
