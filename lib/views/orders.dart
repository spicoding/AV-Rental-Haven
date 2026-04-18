import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/user_model.dart';
import '../models/payment_model.dart';
import 'checkout.dart';

class OrderController extends GetxController {
  // Reactive list of items in the cart
  var orders = <CartItem>[].obs;
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;
  var currentUserId = 0.obs; // Start as 0 (logged out)
  var currentUser =
      Rxn<User>(); // Stores logged-in user details for the profile
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

      // 2. Save Payment Record to DB
      final payment = PaymentModel(
        userId: currentUserId.value,
        paymentMethod: 'mpesa',
        amount: totalAmount,
        transactionReference: checkoutRequestId,
        status: 'pending',
        phoneNumber: phoneNumber,
      );

      final savePaymentResponse = await _apiService.savePaymentRecord(payment);

      if (savePaymentResponse['status'] != 'success') {
        Get.snackbar("Error", "Failed to record payment info.");
        return false;
      }

      final int paymentId = int.parse(
        savePaymentResponse['payment_id'].toString(),
      );

      // 3. Map UI items for the order
      final databaseReadyOrders = orders
          .map((item) => item.toOrderItemMap())
          .toList();

      bool success = await _apiService.submitOrder(
        currentUserId.value,
        paymentId,
        databaseReadyOrders,
      );

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

  Future<bool> processCardCheckout({
    required String cardNumber,
    required String expiry,
    required String cvv,
  }) async {
    if (orders.isEmpty) return false;
    if (currentUserId.value == 0) {
      Get.snackbar("Error", "Please log in to place an order.");
      return false;
    }

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
      if (savePaymentResponse['status'] != 'success') return false;

      final int paymentId = int.parse(
        savePaymentResponse['payment_id'].toString(),
      );
      final databaseReadyOrders = orders
          .map((item) => item.toOrderItemMap())
          .toList();

      bool success = await _apiService.submitOrder(
        currentUserId.value,
        paymentId,
        databaseReadyOrders,
      );

      if (success) orders.clear();
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
