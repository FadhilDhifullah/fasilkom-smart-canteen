import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../viewmodels/cart_viewmodel.dart';
import 'customer_order_detail_screen.dart';

class CustomerCartScreen extends StatefulWidget {
  @override
  _CustomerCartScreenState createState() => _CustomerCartScreenState();
}

class _CustomerCartScreenState extends State<CustomerCartScreen> {
  final CartViewModel cartViewModel = CartViewModel();
  final Set<String> selectedItems = {};

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Center(child: Text('Pengguna tidak ditemukan.'));
    }

    final buyerId = user.uid;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF20452C),
        title: const Text(
          'Keranjang Saya',
         style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
         )
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('cart')
            .where('buyerId', isEqualTo: buyerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('Keranjang kosong.'));
          } else {
            final cartItems =
                snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
            final groupedItems = _groupItemsByCanteen(cartItems);

            double totalPrice = 0;
            for (var item in cartItems) {
              if (selectedItems.contains(item['cartId'])) {
                totalPrice += (item['price'] * item['quantity']);
              }
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: groupedItems.length,
                    itemBuilder: (context, index) {
                      final canteenName = groupedItems.keys.elementAt(index);
                      final items = groupedItems[canteenName]!;
                      return _buildCanteenCard(context, canteenName, items);
                    },
                  ),
                ),
                _buildBottomBar(context, totalPrice, groupedItems),
              ],
            );
          }
        },
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _groupItemsByCanteen(List<Map<String, dynamic>> cartItems) {
    final groupedItems = <String, List<Map<String, dynamic>>>{};
    for (var item in cartItems) {
      groupedItems.putIfAbsent(item['canteenName'], () => []).add(item);
    }
    return groupedItems;
  }

  Widget _buildCanteenCard(BuildContext context, String canteenName, List<Map<String, dynamic>> items) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('sellers').doc(items[0]['canteenId']).get(),
      builder: (context, snapshot) {
        String? canteenImageUrl;
        if (snapshot.hasData) {
          canteenImageUrl = snapshot.data?.get('imageUrl');
        }

        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (canteenImageUrl != null)
                      ClipOval(
                        child: Image.network(
                          canteenImageUrl,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        canteenName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                ...items.map((item) => _buildCartItem(context, item)).toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCartItem(BuildContext context, Map<String, dynamic> item) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('menus').doc(item['menuId']).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
          return const Text('Error loading menu data');
        } else {
          final menuData = snapshot.data!.data() as Map<String, dynamic>;
          final imageUrl = menuData['imageUrl'] ?? '';
          final stock = menuData['stock'] ?? 0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: selectedItems.contains(item['cartId']),
                  onChanged: (value) {
                    setState(() {
                      if (value == true) {
                        selectedItems.add(item['cartId']);
                      } else {
                        selectedItems.remove(item['cartId']);
                      }
                    });
                  },
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['menuName'],
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        item['category'],
                        style: const TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Stok: $stock',
                        style: const TextStyle(fontSize: 14, color: Colors.red),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline),
                            onPressed: () async {
                              if (item['quantity'] > 1) {
                                await cartViewModel.updateQuantity(item['cartId'], item['quantity'] - 1);
                              }
                            },
                          ),
                          Text('${item['quantity']}', style: const TextStyle(fontSize: 14)),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline),
                            onPressed: () async {
                              if (stock > 0) {
                                await cartViewModel.updateQuantity(item['cartId'], item['quantity'] + 1);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      'Rp ${_formatCurrency((item['price'] * item['quantity']).toInt())}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        await cartViewModel.deleteCartItem(item['cartId']);
                        setState(() {});
                      },
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, double totalPrice, Map<String, List<Map<String, dynamic>>> groupedItems) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, -2))],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Total Pembayaran', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(
                'Rp ${_formatCurrency(totalPrice.toInt())}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () async {
              if (selectedItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pilih item yang ingin dipesan.')),
                );
                return;
              }

              final selectedCartItems = groupedItems.entries
                  .expand((entry) => entry.value)
                  .where((item) => selectedItems.contains(item['cartId']))
                  .toList();

              final selectedCanteens = selectedCartItems.map((e) => e['canteenId']).toSet();
              if (selectedCanteens.length > 1) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Maaf, Anda hanya bisa memesan dari satu toko dalam satu waktu.',
                    ),
                  ),
                );
                return;
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CustomerOrderDetailScreen(
                    selectedCartItems: selectedCartItems,
                    totalPrice: totalPrice,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFA31D)),
            child: const Text('Pesan Sekarang'),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }
}
