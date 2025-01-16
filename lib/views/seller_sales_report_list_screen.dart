import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SellerSalesReportListScreen extends StatelessWidget {
  final String canteenId;

  const SellerSalesReportListScreen({Key? key, required this.canteenId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A5744), // Hijau tua
        title: const Text(
          'Daftar Penjualan',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pemasukan',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('orders')
                    .where('canteenId', isEqualTo: canteenId)
                    .where('status', isEqualTo: 'Selesai')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('Tidak ada data penjualan tersedia.'),
                    );
                  }

                  final orders = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final date = (order['timestamp'] as Timestamp).toDate();
                      final formattedDate = '${date.day}/${date.month}/${date.year}';

                      // Hitung totalAmount secara manual
                      final items = order['items'] as List<dynamic>;
                      final totalAmount = items.fold<num>(
                          0, (sum, item) => sum + (item['price'] * item['quantity']));

                      return _buildSalesItem(
                        date: formattedDate,
                        amount: _formatCurrency(totalAmount),
                        onTap: () {
                          _showOrderDetails(context, order);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCurrency(num value) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.');
  }

  Widget _buildSalesItem({
    required String date,
    required String amount,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD6E9D8), // Hijau muda
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                date,
                style: const TextStyle(fontSize: 16, color: Colors.black),
              ),
              const SizedBox(height: 4),
              GestureDetector(
                onTap: onTap,
                child: const Text(
                  'Lihat selengkapnya >',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          Text(
            'Rp $amount',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(BuildContext context, QueryDocumentSnapshot order) {
    final items = order['items'] as List<dynamic>;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detail Penjualan'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Image.network(
                  item['imageUrl'] ?? 'https://via.placeholder.com/150',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error),
                ),
                title: Text(item['menuName'] ?? 'Nama Tidak Diketahui'),
                subtitle: Text('x${item['quantity']} - Rp ${_formatCurrency(item['price'])}'),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }
}
