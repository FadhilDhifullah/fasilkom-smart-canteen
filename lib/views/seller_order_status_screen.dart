import 'package:flutter/material.dart';
import '../models/order_status_model.dart';
import '../viewmodels/order_status_viewmodel.dart';

class SellerOrderStatusScreen extends StatefulWidget {
  final String canteenId;

  const SellerOrderStatusScreen({Key? key, required this.canteenId})
      : super(key: key);

  @override
  _SellerOrderStatusScreenState createState() =>
      _SellerOrderStatusScreenState();
}

class _SellerOrderStatusScreenState extends State<SellerOrderStatusScreen>
    with SingleTickerProviderStateMixin {
  final OrderStatusViewModel _viewModel = OrderStatusViewModel();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showProofImage(String? imageUrl) {
    if (imageUrl == null) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 300,
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        ),
      ),
    );
  }
void _showFullOrderDetails(OrderStatusModel order) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Detail Pesanan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...order.items.map((item) {
                  return ListTile(
                    leading: Image.network(
                      item['imageUrl'] ?? 'https://via.placeholder.com/150',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(item['menuName'] ?? 'Menu Tidak Diketahui'),
                    subtitle: Text('Jumlah: ${item['quantity']}'),
                    trailing: Text(
                      'Rp ${(item['price'] * item['quantity']).toStringAsFixed(0)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                Text(
                  'Catatan: ${order.items.first['notes'] ?? 'Tidak ada catatan'}',
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFA31D),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Tutup', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

 Widget _buildStatusCard(OrderStatusModel order) {
  final hasItems = order.items.isNotEmpty;
  final firstItem = hasItems ? order.items.first : null;

  return Card(
    elevation: 3,
    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (hasItems) ...[
            Row(
              children: [
                Image.network(
                  firstItem?['imageUrl'] ?? 'https://via.placeholder.com/150',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem?['menuName'] ?? 'Nama Tidak Diketahui',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Nama Pembeli: ${order.customerName ?? 'Tidak Diketahui'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ] else
            const Text(
              'Tidak ada item dalam pesanan.',
              style: TextStyle(fontSize: 14, color: Colors.red),
            ),
          Text(
            'Status: ${order.status}',
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(height: 8),
          // Catatan Pembeli
          if (order.items.first.containsKey('notes') &&
              order.items.first['notes'].isNotEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Catatan: ${order.items.first['notes']}',
                style: const TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
          const SizedBox(height: 8),
          // Tombol Lihat Selengkapnya
          ElevatedButton(
            onPressed: () => _showFullOrderDetails(order),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Lihat Selengkapnya',
              style: TextStyle(color: Colors.black),
            ),
          ),
          const SizedBox(height: 8),
          if (order.proofImageUrl != null &&
              order.paymentMethod == 'QRIS' &&
              order.status == 'Menunggu Konfirmasi Penjual')
            ElevatedButton(
              onPressed: () => _showProofImage(order.proofImageUrl),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Lihat Bukti Pembayaran',
                  style: TextStyle(color: Colors.black)),
            ),
          Row(
            children: [
              if (order.status == 'Menunggu Konfirmasi Penjual')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _viewModel.updateOrderStatus(order.orderId, 'Dalam Proses'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Konfirmasi',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              if (order.status == 'Dalam Proses')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _viewModel.updateOrderStatus(order.orderId, 'Selesai'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Selesai',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              const SizedBox(width: 8),
              if ((order.status == 'Menunggu Konfirmasi Penjual' ||
                  order.status == 'Dalam Proses') &&
                  order.status != 'Selesai')
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        _viewModel.updateOrderStatus(order.orderId, 'Batal'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Batalkan',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
            ],
          ),
        ],
      ),
    ),
  );
}

  Widget _buildOrderList(String status) {
    return RefreshIndicator(
      onRefresh: () async {
        try {
          await _viewModel.fetchOrdersByCanteenAndStatusOnce(
              widget.canteenId, status);
          setState(() {});
        } catch (e) {
          print("Gagal memuat data dari server: $e");
        }
      },
      child: StreamBuilder<List<OrderStatusModel>>(
        stream: _viewModel.fetchOrdersByCanteenAndStatus(widget.canteenId, status),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                Center(child: Text('Tidak ada pesanan.')),
              ],
            );
          }

          final orders = snapshot.data!;
          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              return _buildStatusCard(orders[index]);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Status Pesanan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle:
              const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          unselectedLabelColor: Colors.grey,
          tabs: List.generate(4, (index) {
            return Tab(
              child: AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (context, child) {
                  final selected = _tabController.index == index;
                  return Text(
                    ['Menunggu Konfirmasi', 'Dalam Proses', 'Selesai', 'Batal'][index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: selected ? Colors.black : Colors.grey,
                      shadows: selected
                          ? [
                              Shadow(
                                color: Colors.black.withOpacity(0.3),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOrderList('Menunggu Konfirmasi Penjual'),
          _buildOrderList('Dalam Proses'),
          _buildOrderList('Selesai'),
          _buildOrderList('Batal'),
        ],
      ),
    );
  }
}
