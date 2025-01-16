import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer_menu_detail_screen.dart';
import 'customer_cart_screen.dart';

class CustomerHomeScreen extends StatefulWidget {
  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String? customerName;
  String searchQuery = "";
  bool isSearching = false;
  List<Map<String, dynamic>> searchResults = [];

  @override
  void initState() {
    super.initState();
    fetchCustomerName();
  }

  Future<void> fetchCustomerName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final customerDoc = await FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .get();
        if (customerDoc.exists) {
          setState(() {
            customerName = customerDoc.data()?['fullName'] ?? 'Customer';
          });
        } else {
          setState(() {
            customerName = 'Customer';
          });
        }
      }
    } catch (e) {
      print('Error fetching customer name: $e');
      setState(() {
        customerName = 'Customer';
      });
    }
  }

  Future<List<Map<String, dynamic>>> _getFilteredMenus() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('menus').get();
    return querySnapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'menuId': doc.id,
        'name': data['name'] ?? 'Menu',
        'canteenName': data['canteenName'] ?? 'Kantin Tidak Diketahui',
        'canteenId': data['canteenId'] ?? '',
        'price': data['price'] ?? 0.0,
        'category': data['category'] ?? 'Kategori Tidak Diketahui',
        'imageUrl': data['imageUrl'] ?? '',
      };
    }).toList();
  }

 Future<void> _searchMenus(String query) async {
  final queryLower = query.toLowerCase(); // Mengubah input pengguna ke huruf kecil
  final querySnapshot = await FirebaseFirestore.instance
      .collection('menus')
      .get();

  setState(() {
    searchResults = querySnapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final nameLower = (data['name'] ?? '').toString().toLowerCase();
      return nameLower.contains(queryLower); // Memeriksa jika nama mengandung query
    }).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'menuId': doc.id,
        'name': data['name'] ?? 'Menu',
        'canteenName': data['canteenName'] ?? 'Kantin Tidak Diketahui',
        'canteenId': data['canteenId'] ?? '',
        'price': data['price'] ?? 0.0,
        'category': data['category'] ?? 'Kategori Tidak Diketahui',
        'imageUrl': data['imageUrl'] ?? '',
      };
    }).toList();
    isSearching = true;
  });
}


  Future<void> _addToCart(
    BuildContext context,
    String menuId,
    String menuName,
    String canteenName,
    String canteenId,
    double price,
    String category,
    String imageUrl,
    int stock,
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
          content: const Text('Menu yang Anda pilih sudah ada di keranjang.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
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

    // Generate unique cartId
    final cartDoc = FirebaseFirestore.instance.collection('cart').doc();
    final cartId = cartDoc.id;

    // Tambahkan data lengkap ke keranjang
    await cartDoc.set({
      'cartId': cartId,
      'buyerId': buyerId,
      'canteenId': canteenId,
      'canteenName': canteenName,
      'menuId': menuId,
      'menuName': menuName,
      'price': price,
      'category': category,
      'imageUrl': imageUrl,
      'quantity': 1,
      'stock': stock,
    });

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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF20452C),
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Selamat datang,",
              style: TextStyle(fontSize: 14, color: Colors.white70),
            ),
            Text(
              customerName ?? "Customer",
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerCartScreen(),
                ),
              );
            },
          ),
        ],
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFF5F5F5),
                  hintText: "Makan apa hari ini ...",
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    _searchMenus(value);
                  } else {
                    setState(() {
                      isSearching = false;
                    });
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCategoryCard(context, "Aneka Nasi", "assets/images/nasi_icon.png"),
                  _buildCategoryCard(context, "Mie dan Bakso", "assets/images/mie_icon.png"),
                  _buildCategoryCard(context, "Camilan", "assets/images/camilan_icon.png"),
                  _buildCategoryCard(context, "Minuman", "assets/images/minuman_icon.png"),
                ],
              ),
            ),
            const SizedBox(height: 16),
            isSearching
                ? ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final menu = searchResults[index];
                      return _buildMenuCard(menu);
                    },
                  )
                : FutureBuilder<List<Map<String, dynamic>>>(
                    future: _getFilteredMenus(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text('Tidak ada menu ditemukan.'));
                      } else {
                        final menus = snapshot.data!;
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: menus.length,
                          itemBuilder: (context, index) {
                            final menu = menus[index];
                            return _buildMenuCard(menu);
                          },
                        );
                      }
                    },
                  ),
          ],
        ),
      ),
     
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> menu) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(menu['imageUrl'],
                  height: 150, width: double.infinity, fit: BoxFit.cover),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(menu['name'],
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold)),
                  Text('Rp ${menu['price'].toStringAsFixed(0).replaceAllMapped(
                    RegExp(r"\B(?=(\d{3})+(?!\d))"),
                    (match) => '.',
                  )}',
                      style: const TextStyle(
                          fontSize: 14, color: Colors.grey)),
                  Text(menu['canteenName'] ?? '',
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                  Align(
  alignment: Alignment.centerRight,
  child: ElevatedButton(
    onPressed: () {
      _addToCart(
        context,
        menu['menuId'] ?? '',
        menu['name'] ?? 'Menu',
        menu['canteenName'] ?? 'Kantin Tidak Diketahui',
        menu['canteenId'] ?? '',
        (menu['price'] != null) ? double.tryParse(menu['price'].toString()) ?? 0.0 : 0.0,
        menu['category'] ?? 'Kategori Tidak Diketahui',
        menu['imageUrl'] ?? '',
        menu['stock'] ?? 0,
      );
    },
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF20452C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
    child: const Text(
      "Pesan Sekarang",
      style: TextStyle(fontSize: 12, color: Colors.white),
    ),
  ),
),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String title, String iconPath) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CustomerMenuDetailScreen(category: title),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.asset(iconPath, width: 32, height: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
