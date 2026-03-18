import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'orders.dart';

class ProductsScreen extends StatelessWidget {
  ProductsScreen({super.key});

  final OrderController orderController = Get.put(OrderController());

  // Mock data for our product catalog
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Yamaha DM7 Digital Mixer',
      'price': 'Ksh 124,999/day',
      'category': 'Audio',
      'image': 'assets/yamaha dm7.jpg',
    },
    {
      'name': 'Epson 4K Projector',
      'price': 'Ksh 9,999/day',
      'category': 'Visual',
      'image': 'assets/epson projector.jpg',
    },
    {
      'name': 'Shure SLXD Wireless Microphone System',
      'price': 'Ksh 6,499/day',
      'category': 'Audio',
      'image': "assets/slxd+.jpg",
    },
    {
      'name': 'LED Stage Lights Package',
      'price': 'Ksh 5,999 - Ksh 499,999/day',
      'category': 'Lighting',
      'image': 'assets/led stage lights.jpg',
    },
    {
      'name': 'Pioneer CDJ 3000 Controller',
      'price': 'Ksh 20,499/day',
      'category': 'Audio',
      'image': 'assets/CDJ-3000_angle.jpeg',
    },
    {
      'name': '120" Projection Screen',
      'price': 'Ksh 29,999/day',
      'category': 'Visual',
      'image': 'assets/120 projectorscreen.jpg',
    },
    {
      'name': 'Allen & Heath dLive S7000 Surface',
      'price': 'Ksh 150,000/day',
      'category': 'Audio',
      'image':
          'assets/xAllen-Heath-dLive-S7000-and-CDM32-Package-768x768.jpg.pagespeed.ic.E-4kLBWTUA.jpg',
    },
    {
      'name': 'DiGiCo Quantum 338 Console',
      'price': 'Ksh 250,000/day',
      'category': 'Audio',
      'image': 'assets/Q338-Pulse-Angle-for-Web1-1200x750.jpg',
    },
    {
      'name': 'd&b audiotechnik J-Series Line Array',
      'price': 'Ksh 350,000/day',
      'category': 'Audio',
      'image': 'assets/d&b audiotechnik.jpg',
    },
    {
      'name': 'dBTechnologies VIO L212',
      'price': 'Ksh 180,000/day',
      'category': 'Audio',
      'image': 'assets/d&b audiotechnik.jpg',
    },
    {
      'name': 'Allen & Heath DX168 Stage Box',
      'price': 'Ksh 15,000/day',
      'category': 'Accessories',
      'image': 'assets/DX168-Hero-1.jpg',
    },
    {
      'name': 'DiGiCo SD-Rack (32 In / 16 Out)',
      'price': 'Ksh 95,000/day',
      'category': 'Accessories',
      'image': 'assets/SD_Mini_Rack_1-1-1200x750-1.png',
    },
    {
      'name': 'Premium XLR Cable Bundle (50m)',
      'price': 'Ksh 3,500/day',
      'category': 'Accessories',
      'image': 'assets/XLR.png',
    },
    {
      'name': 'Sennheiser EW-DX Wireless System',
      'price': 'Ksh 8,000/day',
      'category': 'Audio',
      'image': 'assets/EWE-DX Mics Dante.png',
    },
    {
      'name': 'Shure PSM1000 In-Ear Monitor System',
      'price': 'Ksh 12,000/day',
      'category': 'Audio',
      'image': 'assets/PSM 1000.jpg',
    },
    {
      'name': 'MA Lighting grandMA3 compact Console',
      'price': 'Ksh 65,000/day',
      'category': 'Lighting',
      'image': 'assets/GrandMA3.png',
    },
    {
      'name': 'Absen 2.9mm SA-C Flexible Displays (per sqm)',
      'price': 'Ksh 15,000/day',
      'category': 'Visual',
      'image': 'assets/sa-series-1920X900-sa-series-1920X900LED panels.jpg',
    },
    {
      'name': 'Blackmagic ATEM Television Studio 4K8',
      'price': 'Ksh 19,999/day',
      'category': 'Visual',
      'image': 'assets/ATEM Television studio 4K8.jpg',
    },
    {
      'name': 'Sony FX6 Cinema Camera',
      'price': 'Ksh 25,000/day',
      'category': 'Visual',
      'image': 'assets/Sony FX6.jpg',
    },
    {
      'name': 'Hollyland Solidcom M1 Pro Wireless Intercom',
      'price': 'Ksh 29,999/day',
      'category': 'Accessories',
      'image': 'assets/Hollylans Solidcom M1 Pro.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Selections'),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          Obx(
            () => IconButton(
              icon: Badge(
                label: Text(orderController.orders.length.toString()),
                isLabelVisible: orderController.orders.isNotEmpty,
                child: const Icon(Icons.shopping_cart),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OrdersScreen()),
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.65, // Adjusts height for content
          ),
          itemBuilder: (context, index) {
            final product = products[index];
            return _buildProductCard(product);
          },
        ),
      ),
    );
  }

  Widget _buildProductCard(Map<String, dynamic> product) {
    return ProductCardItem(product: product);
  }
}

class ProductCardItem extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductCardItem({super.key, required this.product});

  @override
  State<ProductCardItem> createState() => _ProductCardItemState();
}

class _ProductCardItemState extends State<ProductCardItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  ProductDetailsScreen(product: widget.product),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          transform: Matrix4.identity()..scale(_isHovered ? 1.03 : 1.0),
          child: Card(
            elevation: _isHovered ? 8 : 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: Image.asset(
                      widget.product['image'],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade200,
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 50,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product['category'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color.fromARGB(255, 130, 29, 9),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.product['name'],
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.product['price'],
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailsScreen(
                                  product: widget.product,
                                ),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromARGB(
                              255,
                              255,
                              0,
                              0,
                            ),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Order Now',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ProductDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product['name']),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              product['image'],
              width: double.infinity,
              height: 300,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 300,
                  color: Colors.grey.shade200,
                  child: const Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 50,
                      color: Colors.grey,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['category'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromARGB(255, 130, 29, 9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['price'],
                    style: const TextStyle(fontSize: 20, color: Colors.black87),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Product Description',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Experience top-tier performance with the ${product['name']}. '
                    'Perfect for your ${product['category'].toLowerCase()} needs, ensuring high quality and reliability for your events. '
                    'Order it today for only ${product['price']}!',
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.find<OrderController>().addOrder(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Added to your orders!'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm Order',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
