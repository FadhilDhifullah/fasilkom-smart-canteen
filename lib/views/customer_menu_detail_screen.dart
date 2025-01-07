import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/cart_viewmodel.dart';
import '../views/customer_cart_screen.dart';

class CustomerMenuDetailScreen extends StatelessWidget {
  final String category;

  const CustomerMenuDetailScreen({Key? key, required this.category}) : super(key: key);

  Future<void> _addToCart(
      BuildContext context,
      String menuId,
      String menuName,
      String canteenName,
      String canteenId,
      double price,
      String category,
      CartViewModel cartViewModel) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pengguna tidak ditemukan')),
      );
      return;
    }

    final buyerId = user.uid;

    try {
      // Cek apakah menu sudah ada di keranjang
      final existingCart = await FirebaseFirestore.instance
          .collection('cart')
          .where('buyerId', isEqualTo: buyerId)
          .where('menuId', isEqualTo: menuId)
          .get();

      if (existingCart.docs.isNotEmpty) {
        // Tampilkan dialog jika menu sudah ada di keranjang
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Menu Sudah Ada di Keranjang'),
            content: const Text('Menu yang Anda pilih sudah ada di keranjang.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context); // Tutup dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => CustomerCartScreen()),
                  );
                },
                child: const Text('Lihat Keranjang'),
              ),
            ],
          ),
        );
        return;
      }

      // Tambahkan ke keranjang jika belum ada
      await cartViewModel.addToCart(
        menuId,
        menuName,
        canteenName,
        canteenId,
        price,
        category,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil ditambahkan ke keranjang')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ke keranjang: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartViewModel = CartViewModel();
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Pengguna tidak ditemukan.'));
    }

    final buyerId = user.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5DAA80),
        title: Text(
          category,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('cart')
                .where('buyerId', isEqualTo: buyerId)
                .snapshots(),
            builder: (context, snapshot) {
              int cartItemCount = 0;
              if (snapshot.hasData) {
                cartItemCount = snapshot.data!.docs.length;
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CustomerCartScreen()),
                      );
                    },
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('menus')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Tidak ada menu tersedia untuk kategori ini.'));
          } else {
            final menus = snapshot.data!.docs;

            return ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: menus.length,
              separatorBuilder: (context, index) => const Divider(color: Colors.grey),
              itemBuilder: (context, index) {
                final menu = menus[index].data() as Map<String, dynamic>;
                final menuId = menus[index].id;

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
                        // Gambar Menu
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
                        // Detail Menu
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                menu['name'],
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Stok: ${menu['stock']}',
                                style: const TextStyle(fontSize: 14, color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Rp ${menu['price']}',
                                style: const TextStyle(fontSize: 14, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        // Tombol Aksi
                        ElevatedButton(
                          onPressed: () async {
                            await _addToCart(
                              context,
                              menuId,
                              menu['name'],
                              menu['canteenName'],
                              menu['canteenId'],
                              double.tryParse(menu['price'].toString()) ?? 0.0,
                              category,
                              cartViewModel,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF5DAA80),
                            minimumSize: const Size(80, 30),
                          ),
                          child: const Text('Tambah', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
