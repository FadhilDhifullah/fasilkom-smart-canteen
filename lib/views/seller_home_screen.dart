
import 'package:flutter/material.dart';
import '../../viewmodels/seller_home_viewmodel.dart';
import 'package:intl/intl.dart';
import 'seller_menu_category_screen.dart';
import 'seller_sales_report_screen.dart';
import 'seller_payment_methods_screen.dart';
import 'seller_stock_screen.dart';
import 'seller_review_screen.dart';

String formatCurrency(num value) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(value);
}

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
      final data = await _homeViewModel.fetchSellerHomeData(widget.uid);
      if (mounted) {
        setState(() {
          homeData = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data: $e')),
        );
        setState(() {
          isLoading = false;
        });
      }
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
        automaticallyImplyLeading: false,
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
                      text: 'Selamat berjualan, Kantin ',
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
                      value: formatCurrency(transactions['dailyIncome']),
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
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
                          {'title': 'Laporan Keuangan', 'icon': 'assets/images/laporan_keuangan.png'},
                          {'title': 'Ulasan', 'icon': 'assets/images/ulasan.png'},
                          {'title': 'Metode Pembayaran', 'icon': 'assets/images/payment_methods.png'},
                        ][index];
                        return _buildFeatureItem(
                          context,
                          feature['title']!,
                          feature['icon']!,
                          seller,
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
      BuildContext context, String title, String iconPath, Map<String, dynamic> seller) {
    return GestureDetector(
      onTap: () {
        if (title == 'Menu') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SellerMenuCategoryScreen(),
            ),
          );
        } else if (title == 'Metode Pembayaran') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerPaymentMethodsScreen(),
            ),
          );
        } else if (title == 'Laporan Keuangan') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerSalesReportScreen(
                canteenId: widget.uid,
              ),
            ),
          );
        } else if (title == 'Stok') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SellerStockScreen(
                canteenId: widget.uid,
              ),
            ),
          );
        } else if (title == 'Ulasan') {
          Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => SellerReviewScreen(
      canteenId: widget.uid,
      sellerProfileImage: seller['imageUrl'] ?? 'https://via.placeholder.com/150',
    ),
  ),
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
