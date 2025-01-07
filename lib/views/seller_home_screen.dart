import 'package:flutter/material.dart';
import '../../viewmodels/seller_home_viewmodel.dart';
import 'seller_outlet_screen.dart';
import 'seller_menu_category_screen.dart';
import 'seller_payment_methods_screen.dart';

class SellerHomeScreen extends StatefulWidget {
  final String uid;

  const SellerHomeScreen({required this.uid, Key? key}) : super(key: key);

  @override
  _SellerHomeScreenState createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  final SellerHomeViewModel _homeViewModel = SellerHomeViewModel();
  Map<String, dynamic>? homeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  Future<void> _loadHomeData() async {
    try {
      homeData = await _homeViewModel.fetchSellerHomeData(widget.uid);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (homeData == null || homeData!.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: const Center(
          child: Text(
            'Data tidak tersedia.\nSilakan coba lagi nanti.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
        ),
      );
    }

    final seller = homeData!['seller'] ?? {};
    final transactions = homeData!['transactions'] ??
        {'transactionCount': 0, 'dailyIncome': 0.0};

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Dashboard Penjual',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadHomeData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Selamat berjualan, Kantin',
                      style: TextStyle(color: Colors.black, fontSize: 17),
                    ),
                    TextSpan(
                      text: seller['canteenName'] ?? 'Kantin',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF5DAA80),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTransactionInfo(
                      title: 'Transaksi Hari Ini',
                      value: '${transactions['transactionCount']}',
                    ),
                    Container(width: 1, height: 80, color: Colors.white),
                    _buildTransactionInfo(
                      title: 'Pemasukan Hari Ini',
                      value:
                          'Rp ${transactions['dailyIncome'].toStringAsFixed(2)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fitur Penjual',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        final feature = [
                          {'title': 'Menu', 'icon': 'assets/images/menu.png'},
                          {'title': 'Stok', 'icon': 'assets/images/stok.png'},
                          {
                            'title': 'Laporan Keuangan',
                            'icon': 'assets/images/laporan_keuangan.png'
                          },
                          {
                            'title': 'Ulasan',
                            'icon': 'assets/images/ulasan.png'
                          },
                          {
                            'title': 'Metode Pembayaran',
                            'icon': 'assets/images/payment_methods.png'
                          },
                        ][index];
                        return _buildFeatureItem(
                          context,
                          feature['title']!,
                          feature['icon']!,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
        selectedItemColor: const Color(0xFF5DAA80),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => SellerOutletScreen(uid: widget.uid)),
            );
          }
        },
      ),
    );
  }

  Widget _buildTransactionInfo({required String title, required String value}) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white, fontSize: 12)),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
      BuildContext context, String title, String iconPath) {
    return GestureDetector(
      onTap: () {
        if (title == 'Menu') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const SellerMenuCategoryScreen()),
          );
        } else if (title == 'Metode Pembayaran') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerPaymentMethodsScreen(),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Navigasi ke $title belum tersedia')),
          );
        }
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(iconPath, height: 40, width: 40),
          const SizedBox(height: 8),
          Text(title,
              style: const TextStyle(color: Colors.black, fontSize: 12)),
        ],
      ),
    );
  }
}
