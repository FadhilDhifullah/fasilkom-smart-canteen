import 'package:flutter/material.dart';
import 'seller_home_screen.dart';
import 'seller_order_status_screen.dart';
import 'seller_outlet_screen.dart';

class SellerMainScreen extends StatefulWidget {
  final String uid;

  const SellerMainScreen({required this.uid, Key? key}) : super(key: key);

  @override
  _SellerMainScreenState createState() => _SellerMainScreenState();
}

class _SellerMainScreenState extends State<SellerMainScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      SellerHomeScreen(uid: widget.uid), // Halaman Beranda
      SellerOrderStatusScreen(canteenId: widget.uid), // Halaman Pesanan
      SellerOutletScreen(uid: widget.uid), // Halaman Outlet
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
            icon: Icon(Icons.receipt),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Outlet Saya',
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
