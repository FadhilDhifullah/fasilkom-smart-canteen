import 'package:flutter/material.dart';
import 'customer_home_screen.dart';
import 'customer_order_status_screen.dart';
import 'customer_profile_screen.dart';

class CustomerMainScreen extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> userData;
  final bool isGuest;

  const CustomerMainScreen({
    required this.uid,
    required this.userData,
    required this.isGuest,
    Key? key,
  }) : super(key: key);

  @override
  _CustomerMainScreenState createState() => _CustomerMainScreenState();
}

class _CustomerMainScreenState extends State<CustomerMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CustomerHomeScreen(), // Halaman Beranda
      CustomerOrderStatusScreen(buyerId: widget.uid), // Halaman Pesanan
      CustomerProfileScreen(uid: widget.uid), // Halaman Akun Saya
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun Saya',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF5DAA80),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
      ),
    );
  }
}
