import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'orders.dart';
import 'payment.dart';
import '../services/api_service.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Retrieve the existing controller to access the orders
    final OrderController controller = Get.find<OrderController>();
    final ApiService apiService = ApiService();

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
                    final item = controller.orders[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.asset(
                          item['image'],
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) =>
                              const Icon(Icons.image_not_supported),
                        ),
                      ),
                      title: Text(
                        item['name'],
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        item['price'],
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
              child: ElevatedButton(
                onPressed: () async {
                  // Send data to MySQL via the PHP API
                  bool success = await apiService.submitOrder(
                    controller.orders,
                  );

                  if (success) {
                    if (context.mounted) {
                      // Navigate to the payment processing screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PaymentScreen(),
                        ),
                      );
                    }
                  } else {
                    Get.snackbar(
                      'Database Error',
                      'Failed to link with MySQL. Ensure XAMPP is running and the API is accessible.',
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
                child: const Text(
                  'Place Order',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
