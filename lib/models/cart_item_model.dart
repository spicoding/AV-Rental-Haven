import 'product_model.dart';

class CartItem {
  final Product product;
  final int quantity;
  final String? imageUrl; // For displaying in the cart UI

  CartItem({required this.product, this.quantity = 1, this.imageUrl});

  // Helper to create a CartItem from a Product
  factory CartItem.fromProduct(
    Product product, {
    int quantity = 1,
    String? imageUrl,
  }) {
    return CartItem(product: product, quantity: quantity, imageUrl: imageUrl);
  }

  // Method to convert a CartItem to the format expected by the 'orders' table in MySQL
  Map<String, dynamic> toDatabaseMap({
    required String location,
    required int userId,
    required String paymentId,
  }) {
    // Calculate the total amount for this specific cart item
    final double itemAmount = product.unitPrice * quantity;

    return {
      "location": location,
      "user_id": userId,
      "payment_id": paymentId,
      "amount": itemAmount.toStringAsFixed(2), // Format to 2 decimal places
      // You might also want to include product_id and quantity in a separate order_items table
      // For now, we're simplifying by just sending the total amount per item.
    };
  }
}
