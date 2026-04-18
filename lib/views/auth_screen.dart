import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import 'orders.dart';
import '../models/user_model.dart';
import 'homescreen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final ApiService _apiService = ApiService();
  final OrderController _orderController = Get.isRegistered<OrderController>()
      ? Get.find<OrderController>()
      : Get.put(OrderController(), permanent: true);

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_isLogin &&
        _passwordController.text != _confirmPasswordController.text) {
      Get.snackbar("Error", "Passwords do not match");
      return;
    }

    setState(() => _isLoading = true);
    Map<String, dynamic> response;

    if (_isLogin) {
      response = await _apiService.loginUser(
        _emailController.text.trim().toLowerCase(),
        _passwordController.text,
      );
    } else {
      response = await _apiService.registerUser(
        _nameController.text.trim(),
        _emailController.text.trim().toLowerCase(),
        _passwordController.text,
      );
    }

    setState(() => _isLoading = false);

    if (response['status'] == 'success') {
      if (!_isLogin) {
        // Redirect to Login state after successful signup
        setState(() => _isLogin = true);
        _passwordController.clear();
        Get.snackbar("Success", "Account created! Please log in.");
      } else {
        // Successful login: Update user ID and return
        final user = User.fromJson(response);
        _orderController.currentUser.value = user;
        _orderController.currentUserId.value = user.id ?? 0;

        Get.snackbar("Success", "Welcome back!");
        Get.offAll(
          () => const HomeScreen(),
        ); // Direct to HomeScreen after login
      }
    } else {
      Get.snackbar(
        "Error",
        response['message'] ?? "Auth failed",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Login' : 'Create Account'),
        backgroundColor: const Color.fromARGB(255, 255, 0, 0),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!_isLogin)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Full Name'),
                  validator: (v) => v!.isEmpty ? 'Enter your name' : null,
                ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => !v!.contains('@') ? 'Invalid email' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                obscureText: _obscurePassword,
                validator: (v) => v!.length < 6 ? 'Min 6 characters' : null,
              ),
              if (!_isLogin)
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration: const InputDecoration(
                    labelText: 'Confirm Password',
                  ),
                  obscureText: _obscurePassword,
                  validator: (v) =>
                      v!.isEmpty ? 'Please confirm password' : null,
                ),
              const SizedBox(height: 30),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(_isLogin ? 'Login' : 'Register'),
                ),
              TextButton(
                onPressed: () => setState(() => _isLogin = !_isLogin),
                child: Text(
                  _isLogin
                      ? "Don't have an account? Sign Up"
                      : "Already have an account? Login",
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
