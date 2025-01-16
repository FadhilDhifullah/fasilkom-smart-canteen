import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../models/order_status_model.dart';
import '../viewmodels/order_status_viewmodel.dart';
import 'package:apilikasi_smart_canteen/views/customer_review_screen.dart';
import 'dart:io';

class CustomerOrderStatusScreen extends StatefulWidget {
  final String buyerId;

  const CustomerOrderStatusScreen({Key? key, required this.buyerId})
      : super(key: key);

  @override
  _CustomerOrderStatusScreenState createState() =>
      _CustomerOrderStatusScreenState();
}

class _CustomerOrderStatusScreenState
    extends State<CustomerOrderStatusScreen> with SingleTickerProviderStateMixin {
  final OrderStatusViewModel _viewModel = OrderStatusViewModel();
  late TabController _tabController;
  Map<String, File?> _selectedProofImages = {};
  Map<String, bool> _proofUploaded = {};
  String customerName = 'Nama Tidak Diketahui';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadCustomerName();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomerName() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.buyerId)
          .get();
      setState(() {
        customerName = userDoc.data()?['fullName'] ?? 'Nama Tidak Diketahui';
      });
    } catch (e) {
      setState(() {
        customerName = 'Nama Tidak Diketahui';
      });
      print('Gagal memuat nama pelanggan: $e');
    }
  }

  Future<void> _uploadProof(String orderId) async {
    if (_selectedProofImages[orderId] == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      final imageUrl = await _viewModel.uploadProofImage(
          orderId, _selectedProofImages[orderId]!);

      if (imageUrl != null) {
        await FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .update({
          'proofImageUrl': imageUrl,
          'status': 'Menunggu Konfirmasi Penjual',
        });

        setState(() {
          _proofUploaded[orderId] = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bukti pembayaran berhasil diunggah')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengunggah bukti pembayaran: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _pickImage(String orderId) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedProofImages[orderId] = File(pickedFile.path);
        _proofUploaded[orderId] = false;
      });
    }
  }

  Widget _buildStatusCard(OrderStatusModel order) {
    final hasItems = order.items != null && order.items!.isNotEmpty;
    final firstItem = hasItems ? order.items!.first : null;

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        firstItem?['menuName'] ?? 'Nama Menu Tidak Tersedia',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Kantin: ${order.canteenName ?? 'Tidak Diketahui'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 8),
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
            if (order.status == 'Belum Bayar') ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('orders')
                            .doc(order.orderId)
                            .update({'status': 'Batal'});

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Pesanan berhasil dibatalkan')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      child: const Text('Batalkan', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_selectedProofImages[order.orderId] != null && !_proofUploaded[order.orderId]!) {
                          await _uploadProof(order.orderId);
                        } else {
                          await _pickImage(order.orderId);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF5DAA80),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      ),
                      child: Text(
                        _selectedProofImages[order.orderId] != null && !_proofUploaded[order.orderId]!
                            ? 'Kirim Bukti'
                            : 'Pilih Bukti',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (order.status == 'Selesai')
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CustomerReviewScreen(
                        canteenId: order.canteenId,
                        menuId: order.items?.first['menuId'] ?? '',
                        orderId: order.orderId,
                        menuName: order.items?.first['menuName'] ??
                            'Nama Menu Tidak Diketahui',
                        menuImageUrl: order.items?.first['imageUrl'] ?? '',
                        customerId: widget.buyerId,
                        customerName: customerName,
                        customerProfileImage:
                            'https://via.placeholder.com/150',
                        items: order.items ?? [],
                        isReadOnly: false, 
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA31D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Beri Ulasan', style: TextStyle(color: Colors.white)),
              ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Catatan: ${order.items?.first['notes'] ?? 'Tidak ada catatan'}',
                style: const TextStyle(fontSize: 14, color: Colors.black),
              ),
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
          await _viewModel.fetchOrdersOnce(widget.buyerId, status);
          setState(() {});
        } catch (e) {
          print("Gagal memuat data: $e");
        }
      },
      child: StreamBuilder<List<OrderStatusModel>>(
        stream: _viewModel.fetchOrdersByStatus(widget.buyerId, status),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Tidak ada pesanan.'));
          }

          final orders = snapshot.data!;
          return ListView.builder(
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
        title: const Text( 'Pesanan',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,)),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF20452C),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          isScrollable: true,
          labelPadding: const EdgeInsets.symmetric(horizontal: 16),
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          unselectedLabelColor: const Color.fromARGB(255, 180, 160, 160),
          tabs: List.generate(5, (index) {
            return Tab(
              child: AnimatedBuilder(
                animation: _tabController.animation!,
                builder: (context, child) {
                  final selected = _tabController.index == index;
                  return Text(
                    ['Belum Bayar', 'Menunggu Konfirmasi', 'Dalam Proses', 'Selesai', 'Batal'][index],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: selected
                          ? [
                              Shadow(
                                color: Colors.white.withOpacity(0.8),
                                blurRadius: 10,
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
          _buildOrderList('Belum Bayar'),
          _buildOrderList('Menunggu Konfirmasi Penjual'),
          _buildOrderList('Dalam Proses'),
          _buildOrderList('Selesai'),
          _buildOrderList('Batal'),
        ],
      ),
    );
  }
}
