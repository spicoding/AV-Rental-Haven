import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AV Rentals'),
        backgroundColor: const Color.fromARGB(255, 255, 10, 2),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            // const Icon(
            //   Icons.info_outline,
            //   size: 80,
            //   color: Color.fromARGB(255, 255, 34, 0),
            // ),
            const SizedBox(height: 16),
            const Text(
              'AV Rental Haven',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your premium destination for top-tier audio and visual equipment rentals.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            _buildInfoCard(
              title: 'Our Mission',
              content:
                  'To empower events of all sizes with crystal clear audio and stunning visuals by providing accessible, reliable, and high-quality equipment to our clients.',
              icon: Icons.flag,
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              title: 'Contact Us',
              content:
                  'Email: support@avrentalhaven.com\nPhone: +254 768398483\nAddress: ASK House off Ngong Road, 3rd Floor, Nairobi, Kenya',
              icon: Icons.contact_mail,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required String content,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: const Color.fromARGB(255, 252, 0, 0)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    content,
                    style: const TextStyle(fontSize: 14, height: 1.5),
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
