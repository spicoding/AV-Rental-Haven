import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'orders.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final OrderController _orderController;
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _orderController = Get.find<OrderController>();
    // Initialize controllers with current user data from OrderController
    final user = _orderController.currentUser.value;
    _nameController = TextEditingController(text: user?.fullName ?? '');
    _emailController = TextEditingController(text: user?.emailAddress ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color.fromARGB(255, 230, 230, 230),
                  backgroundImage:
                      _orderController.currentUser.value?.imageUrl != null
                      ? NetworkImage(
                          _orderController.currentUser.value!.imageUrl!,
                        )
                      : null,
                  child: _orderController.currentUser.value?.imageUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.blueGrey,
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Color.fromARGB(255, 255, 0, 0),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                  foregroundColor: Colors.white,
                ),
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (image == null) return;

    setState(() => _isLoading = true);
    try {
      final userId = fb_auth.FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) return;

      final ref = FirebaseStorage.instance
          .ref()
          .child('user_avatars')
          .child('$userId.jpg');
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();

      // Update user document with image URL
      await ApiService().updateUser(
        userId: userId,
        fullName: _nameController.text,
        email: _emailController.text,
        imageUrl: url,
      );
      // You would typically add an 'image_url' parameter to your updateUser method

      // Update local state immediately
      _orderController.setUser(
        User(
          id: userId,
          fullName: _nameController.text,
          emailAddress: _emailController.text,
          imageUrl: url,
        ),
      );

      Get.snackbar("Success", "Profile picture updated");
    } catch (e) {
      Get.snackbar("Error", "Failed to upload image: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final fbUser = fb_auth.FirebaseAuth.instance.currentUser;

    if (fbUser == null) {
      Get.snackbar(
        'Error',
        'Please log in to update your profile.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    if (name.isEmpty || email.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill in all fields',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = ApiService();
      final result = await apiService.updateUser(
        userId: fbUser.uid,
        fullName: name,
        email: email,
      );

      if (result['status'] == 'success') {
        // Update local state with the existing image URL preserved
        final currentUser = _orderController.currentUser.value;
        _orderController.setUser(
          User(
            id: fbUser.uid,
            fullName: name,
            emailAddress: email,
            imageUrl: currentUser?.imageUrl,
          ),
        );

        if (mounted) {
          Get.back();
        }
        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Update failed',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}
