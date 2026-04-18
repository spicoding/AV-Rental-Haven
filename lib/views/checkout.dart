import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'orders.dart';
import 'auth_screen.dart';
import '../models/cart_item_model.dart'; // Import the CartItem model

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _phoneController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();

  String _selectedPaymentMethod = 'mpesa';
  final _formKey = GlobalKey<FormState>();

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
            Obx(() {
              final user = controller.currentUser.value;
              if (user != null) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Logged in as: ${user.emailAddress}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
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
            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('M-Pesa'),
                    value: 'mpesa',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) =>
                        setState(() => _selectedPaymentMethod = value!),
                  ),
                ),
                Expanded(
                  child: RadioListTile<String>(
                    title: const Text('Card'),
                    value: 'card',
                    groupValue: _selectedPaymentMethod,
                    onChanged: (value) =>
                        setState(() => _selectedPaymentMethod = value!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  if (_selectedPaymentMethod == 'mpesa')
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: "M-Pesa Phone Number",
                        hintText: "2547XXXXXXXX",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (v) =>
                          v!.isEmpty ? 'Enter phone number' : null,
                    )
                  else ...[
                    TextFormField(
                      controller: _cardNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Card Number',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.credit_card),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v!.isEmpty ? 'Enter card number' : null,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _expiryController,
                            decoration: const InputDecoration(
                              labelText: 'MM/YY',
                              border: OutlineInputBorder(),
                            ),
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: _cvvController,
                            decoration: const InputDecoration(
                              labelText: 'CVV',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () {
                          if (!_formKey.currentState!.validate()) return;
                          _handlePayment(controller);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: controller.isLoading.value
                      ? const CircularProgressIndicator(color: Colors.white)
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

  Future<void> _handlePayment(OrderController controller) async {
    if (_selectedPaymentMethod == 'mpesa') {
      bool success = await controller.processCheckout(_phoneController.text);
      if (success) {
        Get.snackbar(
          'Success',
          'M-Pesa payment initiated!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        Get.back();
      } else {
        Get.snackbar('Error', 'Payment failed', backgroundColor: Colors.red);
      }
    } else {
      // Simulate Card Payment logic
      controller.isLoading.value = true;
      await Future.delayed(const Duration(seconds: 2));
      controller.isLoading.value = false;

      controller.rentalHistory.addAll(controller.orders);
      controller.orders.clear();
      Get.snackbar(
        'Success',
        'Card payment processed successfully!',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }
}
