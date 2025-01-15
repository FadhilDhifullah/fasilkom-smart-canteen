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

  void _showAllItems(List<dynamic> items) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daftar Menu'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Image.network(
                  item?['imageUrl'] ?? 'https://via.placeholder.com/150',
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                ),
                title: Text(item?['menuName'] ?? 'Nama Tidak Diketahui'),
                subtitle: Text(
                    'x${item?['quantity'] ?? 0} - Rp ${item?['price'] ?? 0}'),
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
              if (firstItem != null && firstItem['notes'] != null && firstItem['notes'].isNotEmpty)
                Text(
                  'Catatan: ${firstItem['notes']}',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
            ] else
              const Text(
                'Tidak ada item dalam pesanan.',
                style: TextStyle(fontSize: 14, color: Colors.red),
              ),
            Text(
              'Status: ${order.status}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            if (order.items.length > 1)
              TextButton(
                onPressed: () => _showAllItems(order.items),
                child: const Text('Lihat Selengkapnya'),
              ),
            if (order.proofImageUrl != null)
              ElevatedButton(
                onPressed: () => _showProofImage(order.proofImageUrl),
                child: const Text('Lihat Bukti Pembayaran'),
              ),
            Row(
              children: [
                if (order.status == 'Menunggu Konfirmasi Penjual')
                  ElevatedButton(
                    onPressed: () =>
                        _viewModel.updateOrderStatus(order.orderId, 'Dalam Proses'),
                    child: const Text('Konfirmasi'),
                  ),
                if (order.status == 'Dalam Proses')
                  ElevatedButton(
                    onPressed: () =>
                        _viewModel.updateOrderStatus(order.orderId, 'Selesai'),
                    child: const Text('Selesai'),
                  ),
                if ((order.status == 'Menunggu Konfirmasi Penjual' ||
                    order.status == 'Dalam Proses') &&
                    order.status != 'Selesai')
                  ElevatedButton(
                    onPressed: () =>
                        _viewModel.updateOrderStatus(order.orderId, 'Batal'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Batalkan'),
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
        backgroundColor: const Color(0xFF5DAA80),
        title: const Text('Status Pesanan'),
        automaticallyImplyLeading: false,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Menunggu Konfirmasi'),
            Tab(text: 'Dalam Proses'),
            Tab(text: 'Selesai'),
            Tab(text: 'Batal'),
          ],
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
