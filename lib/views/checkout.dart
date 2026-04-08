import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'orders.dart';
import 'payment.dart';
import '../models/cart_item_model.dart'; // Import the CartItem model

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the existing controller to access the orders
    final OrderController controller = Get.find<OrderController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () => ListView.builder(
                  itemCount: controller.orders.length,
                  itemBuilder: (context, index) {
                    final CartItem item =
                        controller.orders[index]; // Use CartItem type
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          item.imageUrl ??
                              'assets/placeholder.png', // Use item.imageUrl
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text(
                        item.product.productName,
                      ), // Use item.product.productName
                      subtitle: Text('Quantity: ${item.quantity}'),
                      trailing: Text(
                        '\$${(item.product.unitPrice * item.quantity).toStringAsFixed(2)}', // Display calculated price
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  },
                ),
              ),
            ),
            const Divider(),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          // Logic moved to OrderController.processCheckout()
                          bool success = await controller.processCheckout();
                          if (success && context.mounted) {
                            Get.to(() => const PaymentScreen());
                          } else if (!success) {
                            Get.snackbar(
                              'Order Failed',
                              'Could not place order. Please try again.',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Place Order',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
