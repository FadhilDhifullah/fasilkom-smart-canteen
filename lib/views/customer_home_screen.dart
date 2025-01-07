import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'customer_menu_detail_screen.dart'; // Import layar detail kategori menu
import 'customer_profile_screen.dart'; // Import halaman profil

class CustomerHomeScreen extends StatefulWidget {
  @override
  _CustomerHomeScreenState createState() => _CustomerHomeScreenState();
}

class _CustomerHomeScreenState extends State<CustomerHomeScreen> {
  String? customerName;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF5DAA80),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Selamat datang,',
                style: TextStyle(fontSize: 16, color: Colors.white)),
            Text(customerName ?? 'Customer',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerProfileScreen(
                      uid: FirebaseAuth.instance.currentUser!.uid),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 100,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              children: [
                _buildCategoryItem(context, 'Aneka Nasi', 'assets/images/aneka_nasi.png'),
                _buildCategoryItem(context, 'Bakso & Mie', 'assets/images/bakso_mie.png'),
                _buildCategoryItem(context, 'Camilan', 'assets/images/camilan.png'),
                _buildCategoryItem(context, 'Minuman', 'assets/images/minuman.png'),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('menus')
                  .limit(3)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('Tidak ada menu yang direkomendasikan.'));
                } else {
                  final menus = snapshot.data!.docs;
                  return ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: menus.length,
                    itemBuilder: (context, index) {
                      final menu = menus[index].data() as Map<String, dynamic>;
                      return _buildMenuCard(menu);
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF5DAA80),
        unselectedItemColor: Colors.grey,
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
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Akun Saya',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          // Navigasi antar halaman jika diperlukan
        },
      ),
    );
  }

  Widget _buildCategoryItem(BuildContext context, String title, String iconPath) {
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
          CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage(iconPath),
          ),
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildMenuCard(Map<String, dynamic> menu) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Image.network(menu['imageUrl'], height: 50, width: 50, fit: BoxFit.cover),
        title: Text(menu['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Rp ${menu['price']}', style: const TextStyle(color: Colors.green)),
        trailing: ElevatedButton(
          onPressed: () {
            // Tambahkan aksi pemesanan
          },
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5DAA80)),
          child: const Text('Pesan Sekarang'),
        ),
      ),
    );
  }
}
