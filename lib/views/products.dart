import 'package:flutter/material.dart';

class ProductsScreen extends StatelessWidget {
  ProductsScreen({super.key});

  // Mock data for our product catalog
  final List<Map<String, dynamic>> products = [
    {
      'name': 'Yamaha DM7 Digital Mixer',
      'price': 'Ksh 124,999/day',
      'category': 'Audio',
      'icon': Icons.speaker,
    },
    {
      'name': 'Epson 4K Projector',
      'price': 'Ksh 9,999/day',
      'category': 'Visual',
      'icon': Icons.videocam,
    },
    {
      'name': 'Shure SLXD Wireless Microphone System',
      'price': 'Ksh 6,499/day',
      'category': 'Audio',
      'icon': Icons.mic,
    },
    {
      'name': 'LED Stage Lights Package',
      'price': 'Ksh 5,999 - Ksh 499,999/day',
      'category': 'Lighting',
      'icon': Icons.lightbulb,
    },
    {
      'name': 'Pioneer CDJ 3000 Controller',
      'price': 'Ksh 20,499/day',
      'category': 'Audio',
      'icon': Icons.album,
    },
    {
      'name': '120" Projection Screen',
      'price': 'Ksh 29,999/day',
      'category': 'Visual',
      'icon': Icons.fit_screen,
    },
    {
      'name': 'Allen & Heath dLive S7000 Surface',
      'price': 'Ksh 150,000/day',
      'category': 'Audio',
      'icon': Icons.tune,
    },
    {
      'name': 'DiGiCo Quantum 338 Console',
      'price': 'Ksh 250,000/day',
      'category': 'Audio',
      'icon': Icons.tune,
    },
    {
      'name': 'd&b audiotechnik J-Series Line Array',
      'price': 'Ksh 350,000/day',
      'category': 'Audio',
      'icon': Icons.speaker,
    },
    {
      'name': 'dBTechnologies VIO L212',
      'price': 'Ksh 180,000/day',
      'category': 'Audio',
      'icon': Icons.speaker,
    },
    {
      'name': 'Allen & Heath DX168 Stage Box',
      'price': 'Ksh 15,000/day',
      'category': 'Accessories',
      'icon': Icons.dns,
    },
    {
      'name': 'DiGiCo SD-Rack (32 In / 16 Out)',
      'price': 'Ksh 95,000/day',
      'category': 'Accessories',
      'icon': Icons.dns,
    },
    {
      'name': 'Premium XLR Cable Bundle (50m)',
      'price': 'Ksh 3,500/day',
      'category': 'Accessories',
      'icon': Icons.cable,
    },
    {
      'name': 'Sennheiser EW-DX Wireless System',
      'price': 'Ksh 8,000/day',
      'category': 'Audio',
      'icon': Icons.mic,
    },
    {
      'name': 'Shure PSM1000 In-Ear Monitor System',
      'price': 'Ksh 12,000/day',
      'category': 'Audio',
      'icon': Icons.headphones,
    },
    {
      'name': 'MA Lighting grandMA3 compact Console',
      'price': 'Ksh 65,000/day',
      'category': 'Lighting',
      'icon': Icons.light,
    },
    {
      'name': 'Absen 2.9mm LED Video Wall (per sqm)',
      'price': 'Ksh 15,000/day',
      'category': 'Visual',
      'icon': Icons.monitor,
    },
    {
      'name': 'Blackmagic ATEM Television Studio HD',
      'price': 'Ksh 10,000/day',
      'category': 'Visual',
      'icon': Icons.switch_video,
    },
    {
      'name': 'Sony FX6 Cinema Camera',
      'price': 'Ksh 25,000/day',
      'category': 'Visual',
      'icon': Icons.camera_alt,
    },
    {
      'name': 'ClearCom FreeSpeak II Wireless Intercom',
      'price': 'Ksh 18,000/day',
      'category': 'Accessories',
      'icon': Icons.headset_mic,
    },
    {
      'name': 'Global Truss F34 (3m section)',
      'price': 'Ksh 1,500/day',
      'category': 'Accessories',
      'icon': Icons.grid_4x4,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Product Selections'),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        foregroundColor: const Color.fromARGB(255, 255, 255, 255),
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Icon(product['icon'], size: 54, color: Colors.blueGrey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['category'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color.fromARGB(255, 130, 29, 9),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  product['price'],
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Rent Now',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
