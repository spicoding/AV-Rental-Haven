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

  // Method to convert a CartItem to the format expected for an individual order item in the 'order_items' table
  Map<String, dynamic> toOrderItemMap() {
    final double itemAmount = product.unitPrice * quantity;

    return {
      "product_id": product.productId,
      "quantity": quantity,
      "unit_price": product.unitPrice,
      "total_price_for_item": itemAmount.toStringAsFixed(
        2,
      ), // Format to 2 decimal places
    };
  }
}
