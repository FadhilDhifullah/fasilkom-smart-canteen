import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'customer_order_status_screen.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:permission_handler/permission_handler.dart';
class CustomerOrderDetailScreen extends StatefulWidget {
  final List<Map<String, dynamic>> selectedCartItems;
  final double totalPrice;

  const CustomerOrderDetailScreen({
    Key? key,
    required this.selectedCartItems,
    required this.totalPrice,
  }) : super(key: key);

  @override
  _CustomerOrderDetailScreenState createState() =>
      _CustomerOrderDetailScreenState();
}

class _CustomerOrderDetailScreenState extends State<CustomerOrderDetailScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _paymentMethod;
  String? _qrisUrl;
  bool isLoading = true;
  List<String> _orderIds = [];

  @override
  void initState() {
    super.initState();
    _fetchPaymentMethods();
  }

  Future<void> _fetchPaymentMethods() async {
    try {
      final sellerId = widget.selectedCartItems.first['canteenId'];
      final paymentMethods =
          await _firestore.collection('payment_methods').doc(sellerId).get();

      if (paymentMethods.exists) {
        final data = paymentMethods.data()!;
       setState(() {
  if (data['isCOD'] == true && data['isQRIS'] == true) {
    _paymentMethod = "COD"; // Default ke COD jika keduanya tersedia
  } else if (data['isCOD'] == true) {
    _paymentMethod = "COD";
  } else if (data['isQRIS'] == true) {
    _paymentMethod = "QRIS";
  } else {
    _paymentMethod = "COD"; // Nilai fallback jika tidak ada metode ditemukan
  }
  _qrisUrl = data['qrisUrl'];
  isLoading = false;
});
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat metode pembayaran: $e')),
      );
      setState(() {
        isLoading = false;
      });
    }
  }
bool _isOrderInProgress = false;

Future<void> _moveCartToOrders() async {
  if (_isOrderInProgress) return; // Jika sudah berjalan, abaikan pemanggilan berikutnya

  _isOrderInProgress = true; // Tandai proses sedang berlangsung
  final buyerId = _auth.currentUser?.uid ?? '';
  final canteenId = widget.selectedCartItems.first['canteenId'];
  final canteenName = widget.selectedCartItems.first['canteenName'];
  final orderId = _firestore.collection('orders').doc().id;
  String customerName = "Tidak Diketahui";

  try {
    // Ambil nama pelanggan dari Firestore
    final customerDoc = await _firestore.collection('customers').doc(buyerId).get();
    if (customerDoc.exists) {
      customerName = customerDoc.data()?['fullName'] ?? "Tidak Diketahui";
    }

    // Kumpulkan semua item dalam satu pesanan
    List<Map<String, dynamic>> orderItems = widget.selectedCartItems.map((item) {
      return {
        'menuId': item['menuId'],
        'menuName': item['menuName'],
        'category': item['category'],
        'price': item['price'],
        'quantity': item['quantity'],
        'notes': item['notes'] ?? '',
        'imageUrl': item['imageUrl'] ?? 'https://via.placeholder.com/150',
      };
    }).toList();

    // Tentukan status berdasarkan metode pembayaran
    String initialStatus = _paymentMethod == "COD"
        ? "Menunggu Konfirmasi Penjual"
        : "Belum Bayar";

    // Simpan pesanan dalam satu dokumen
    await _firestore.collection('orders').doc(orderId).set({
      'orderId': orderId,
      'buyerId': buyerId,
      'customerName': customerName,
      'canteenId': canteenId,
      'canteenName': canteenName,
      'items': orderItems,
      'paymentMethod': _paymentMethod,
      'status': initialStatus,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Hapus semua item dari keranjang
    for (var item in widget.selectedCartItems) {
      await _firestore.collection('cart').doc(item['cartId']).delete();

      // Update stok menu
      final menuRef = _firestore.collection('menus').doc(item['menuId']);
      final menuDoc = await menuRef.get();
      if (menuDoc.exists) {
        final currentStock = menuDoc['stock'] as int;
        await menuRef.update({'stock': currentStock - item['quantity']});
      }
    }
  } catch (e) {
    print('Error saat memindahkan cart ke orders: $e');
  } finally {
    _isOrderInProgress = false; // Proses selesai
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
       
        title: const Text( 'Pesanan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,)),
        backgroundColor: const Color(0xFF20452C),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                ..._buildOrderItems(),
                _buildPaymentMethodSelector(),
                const Divider(),
                _buildSummary(),
              ],
            ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  List<Widget> _buildOrderItems() {
  return widget.selectedCartItems.map((orderItem) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipOval(
                  child: Image.network(
                    orderItem['imageUrl'] ?? 'https://via.placeholder.com/150',
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  orderItem['canteenName'] ?? 'Nama Kantin Tidak Diketahui',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    orderItem['imageUrl'] ?? 'https://via.placeholder.com/150',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orderItem['menuName'] ?? 'Menu Tidak Diketahui',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        orderItem['category'] ?? 'Kategori Tidak Diketahui',
                        style: const TextStyle(
                            fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        'Rp ${(orderItem['price'] ?? 0).toStringAsFixed(0)}',
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Text(
                  'x${orderItem['quantity'] ?? 0}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Catatan Tambahan',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  orderItem['notes'] = value; // Simpan catatan
                });
              },
            ),
          ],
        ),
      ),
    );
  }).toList();
}


  Widget _buildPaymentMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Metode Pembayaran',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        if (_paymentMethod == null)
          const Text('Tidak ada metode pembayaran tersedia.'),
        if (_qrisUrl != null)
          ListTile(
            title: const Text('QRIS'),
            subtitle: _paymentMethod == "QRIS"
                ? Image.network(
                    _qrisUrl!,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error),
                  )
                : null,
            trailing: _paymentMethod == "QRIS"
                ? IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: _downloadQRIS,
                  )
                : null,
            leading: Radio(
              value: "QRIS",
              groupValue: _paymentMethod,
              onChanged: (value) {
                setState(() {
                  _paymentMethod = value.toString();
                });
              },
            ),
          ),
        ListTile(
          title: const Text('COD'),
          subtitle: const Text('Pembayaran langsung di tempat.'),
          leading: Radio(
            value: "COD",
            groupValue: _paymentMethod,
            onChanged: (value) {
              setState(() {
                _paymentMethod = value.toString();
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummary() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Pesanan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...widget.selectedCartItems.map((item) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${item['menuName'] ?? 'Item Tidak Diketahui'} x${item['quantity'] ?? 0}'),
              Text(
                'Rp ${((item['price'] ?? 0) * (item['quantity'] ?? 0)).toStringAsFixed(0)}',
              ),
            ],
          );
        }).toList(),
        const Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total Pembayaran',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Rp ${widget.totalPrice.toStringAsFixed(0)}',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: const BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, -2)),
      ],
    ),
    child: ElevatedButton(
      onPressed: isLoading
          ? null // Nonaktifkan tombol jika sedang loading
          : () async {
              if (_paymentMethod == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Pilih metode pembayaran terlebih dahulu')),
                );
                return;
              }

              setState(() {
                isLoading = true;
              });

              try {
                // Pindahkan item ke orders
                await _moveCartToOrders();

                // Navigasikan ke layar status pesanan
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CustomerOrderStatusScreen(
                      buyerId: _auth.currentUser!.uid,
                    ),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal membuat pesanan: $e')),
                );
              } finally {
                setState(() {
                  isLoading = false;
                });
              }
            },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFA31D),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      child: isLoading
          ? const CircularProgressIndicator(
              color: Colors.white,
            )
          : const Text(
              'Buat Pesanan',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
    ),
  );
}



  Future<void> _downloadQRIS() async {
  if (_qrisUrl != null) {
    try {
      // Meminta izin akses penyimpanan
      if (await Permission.storage.request().isGranted) {
        // Tentukan direktori unduhan umum
        final directory = Directory('/storage/emulated/0/Download');
        if (!directory.existsSync()) {
          directory.createSync(recursive: true);
        }

        // Lokasi file unduhan
        final filePath = '${directory.path}/qris.png';

        // Unduh gambar menggunakan Dio
        final dio = Dio();
        await dio.download(_qrisUrl!, filePath);

        // Tampilkan notifikasi keberhasilan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('QRIS berhasil diunduh ke $filePath')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Izin penyimpanan ditolak')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunduh QRIS: $e')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('QRIS URL tidak tersedia')),
    );
  }
}
Future<void> _cancelOrders() async {
  try {
    for (var orderId in _orderIds) {
      final orderDoc = await _firestore.collection('orders').doc(orderId).get();
      if (orderDoc.exists) {
        final orderData = orderDoc.data()!;
        final menuId = orderData['menuId'];
        final quantity = orderData['quantity'];

        // Kembalikan stok menu
        final menuRef = _firestore.collection('menus').doc(menuId);
        final menuDoc = await menuRef.get();
        if (menuDoc.exists) {
          final currentStock = menuDoc['stock'] as int;
          await menuRef.update({'stock': currentStock + quantity});
        }
      }

      // Hapus order dari Firestore
      await _firestore.collection('orders').doc(orderId).delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Pesanan berhasil dibatalkan')),
    );
  } catch (e) {
    print('Error saat membatalkan pesanan: $e');
  }
}

}
