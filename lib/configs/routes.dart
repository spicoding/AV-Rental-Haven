import 'package:get/get.dart';
import '../views/signup.dart';
import '../views/login.dart';
import '../views/homescreen.dart';

var routes = [
  GetPage(name: "/signup", page: () => const SignupPage()),
  GetPage(name: "/", page: () => const LoginPage()),
  GetPage(name: "/homescreen", page: () => const HomeScreen()),
];
