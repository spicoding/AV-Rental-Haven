import 'package:get/get.dart';
import '../services/api_service.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';

class OrderController extends GetxController {
  // Reactive list of items in the cart
  var orders = <CartItem>[].obs;
  final ApiService _apiService = ApiService();
  var isLoading = false.obs;
  var currentUserId = 0.obs; // Start as 0 (logged out)

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

  Future<bool> processCheckout() async {
    if (orders.isEmpty) return false;
    if (currentUserId.value == 0) {
      Get.snackbar("Error", "Please log in to place an order.");
      return false;
    }

    isLoading.value = true;
    try {
      // Map UI items to the MySQL database schema
      final databaseReadyOrders = orders.map((item) {
        return item.toDatabaseMap(
          location: "Main Campus", // Replace with actual location logic
          userId: currentUserId.value, // Use the dynamic user ID
          paymentId:
              "PAY-${DateTime.now().millisecondsSinceEpoch}", // Generate a unique payment ID
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
