import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'edit_profile.dart';
import 'rental_history.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 30),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color.fromARGB(255, 230, 230, 230),
              child: Icon(Icons.person, size: 60, color: Colors.blueGrey),
            ),
            const SizedBox(height: 16),
            const Text(
              'John Doe',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'johndoe@example.com',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            const Divider(),
            _buildProfileOption(Icons.edit, 'Edit Profile', () {
              Get.to(() => const EditProfileScreen());
            }),
            _buildProfileOption(Icons.history, 'Rental History', () {
              Get.to(() => const RentalHistoryScreen());
            }),
            _buildProfileOption(Icons.payment, 'Payment Methods', () {}),
            _buildProfileOption(Icons.settings, 'Settings', () {}),
            const Divider(),
            _buildProfileOption(Icons.logout, 'Log Out', () {
              // Navigate back to the login page
              Get.offAllNamed("/login");
            }, isDestructive: true),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption(
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : Colors.blueGrey),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? Colors.red : Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
