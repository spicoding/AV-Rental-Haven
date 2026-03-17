import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'products.dart';
import 'profile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;

  final List<Widget> _pages = [
    const DashboardScreen(),
    ProductsScreen(),
    const Center(child: Text('Orders/Lines coming soon!')),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
        index: _page,
        backgroundColor: const Color.fromARGB(255, 248, 25, 0),
        items: <Widget>[
          const Icon(Icons.dashboard, size: 30),
          const Icon(Icons.category, size: 30),
          const Icon(Icons.line_style, size: 30),
          const Icon(Icons.person, size: 30),
        ],
        onTap: (index) {
          setState(() {
            _page = index;
          });
        },
      ),
      body: _pages[_page],
    );
  }
}
