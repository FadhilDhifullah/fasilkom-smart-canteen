import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../views/customer_cart_screen.dart';
import '../views/customer_review_screen.dart';

class CustomerMenuDetailScreen extends StatefulWidget {
  final String category;

  const CustomerMenuDetailScreen({Key? key, required this.category}) : super(key: key);

  @override
  _CustomerMenuDetailScreenState createState() => _CustomerMenuDetailScreenState();
}

class _CustomerMenuDetailScreenState extends State<CustomerMenuDetailScreen> {
  final CartViewModel cartViewModel = CartViewModel();
  String searchQuery = "";

  Future<void> _addToCart(
    BuildContext context,
    String menuId,
    String menuName,
    String canteenName,
    String canteenId,
    double price,
    String category,
  ) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna tidak ditemukan')),
      );
      return;
    }

    final buyerId = user.uid;

    try {
      final existingCart = await FirebaseFirestore.instance
          .collection('cart')
          .where('buyerId', isEqualTo: buyerId)
          .where('menuId', isEqualTo: menuId)
          .get();

      if (existingCart.docs.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Menu Sudah Ada di Keranjang'),
            content: const Text('Menu ini sudah ada di keranjang Anda. Silakan cek keranjang untuk melanjutkan.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => CustomerCartScreen()));
                },
                child: const Text('Lihat Keranjang'),
              ),
            ],
          ),
        );
        return;
      }

      await cartViewModel.addToCart(menuId, menuName, canteenName, canteenId, price, category);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil ditambahkan ke keranjang')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ke keranjang: $e')),
      );
    }
  }

  double _calculateAverageRating(List<dynamic> reviews) {
    if (reviews.isEmpty) return 0.0;
    final totalRating = reviews.fold<double>(
      0.0,
      (sum, review) => sum + (review['rating']?.toDouble() ?? 0.0),
    );
    return totalRating / reviews.length;
  }
String formatCurrency(double value) {
  return value.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.');
}

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Pengguna tidak ditemukan.'));
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF20452C),
        title: Text(
          widget.category,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('cart')
                .where('buyerId', isEqualTo: user.uid)
                .snapshots(),
            builder: (context, snapshot) {
              int cartItemCount = snapshot.data?.docs.length ?? 0;

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, color: Colors.white),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CustomerCartScreen()),
                    ),
                  ),
                  if (cartItemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '$cartItemCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari menu...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value.trim()),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('menus')
                  .where('category', isEqualTo: widget.category)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final menus = snapshot.data!.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .where((menu) => searchQuery.isEmpty ||
                        (menu['name']?.toLowerCase().contains(searchQuery.toLowerCase()) ?? false))
                    .toList();

                if (menus.isEmpty) {
                  return const Center(child: Text('Tidak ada menu tersedia untuk kategori ini.'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: menus.length,
                  itemBuilder: (context, index) {
                    final menu = menus[index];
                    final menuId = snapshot.data!.docs[index].id;

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                menu['imageUrl'],
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    menu['name'],
                                    style: const TextStyle(
                                        fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                   const SizedBox(height: 4),
                                  Text(
                                    menu['canteenName'],
        style: const TextStyle(fontSize: 14, color: Colors.black),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stok: ${menu['stock']}',
                                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
  'Rp ${formatCurrency(double.tryParse(menu['price'].toString()) ?? 0.0)}',
  style: const TextStyle(fontSize: 14, color: Colors.green),
),

                                  const SizedBox(height: 4),
                                  FutureBuilder<QuerySnapshot>(
                                    future: FirebaseFirestore.instance
                                        .collection('reviews')
                                        .where('canteenId', isEqualTo: menu['canteenId'])
                                        .get(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                        return const Text('Rating: -');
                                      }

                                      final reviews = snapshot.data!.docs;
                                      final averageRating = _calculateAverageRating(
                                          reviews.map((e) => e.data() as Map<String, dynamic>).toList());

                                      return Row(
                                        children: [
                                          Text('Rating: ${averageRating.toStringAsFixed(1)}'),
                                          const SizedBox(width: 4),
                                          Icon(Icons.star, color: Colors.amber, size: 16),
                                        ],
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () => Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CustomerReviewScreen(
                                          canteenId: menu['canteenId'],
                                          isReadOnly: true,
                                        ),
                                      ),
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF20452C),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: const Text('Lihat Review',
                                        style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async => await _addToCart(
                                context,
                                menuId,
                                menu['name'],
                                menu['canteenName'],
                                menu['canteenId'],
                                double.tryParse(menu['price'].toString()) ?? 0.0,
                                widget.category,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF5DAA80),
                                minimumSize: const Size(80, 30),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Tambah', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
