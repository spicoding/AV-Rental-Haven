class Product {
  final int productId;
  final String productName;
  final String? productDescription; // Nullable if description is optional
  final String? category;
  final double unitPrice;
  final String? imageUrl;

  Product({
    required this.productId,
    required this.productName,
    this.category,
    this.productDescription,
    required this.unitPrice,
    this.imageUrl,
  });

  // Factory constructor to create a Product from a JSON map (e.g., from API response)
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      productId: int.parse(json['product_id'].toString()),
      productName: json['product_name'] as String,
      productDescription: json['product_description'] as String?,
      category: json['category'] as String?,
      unitPrice: double.parse(json['unit_price'].toString()),
      imageUrl: json['image'] as String?,
    );
  }

  // No toJson needed for products as they are typically fetched, not sent for creation from Flutter
  // If you had an admin panel in Flutter to add products, you'd add a toJson method.
}
