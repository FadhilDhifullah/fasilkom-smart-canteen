import 'package:flutter/material.dart';
import '../viewmodels/sales_report_viewmodel.dart';
import '../models/sales_report_model.dart';
import 'seller_sales_report_list_screen.dart';

class SellerSalesReportScreen extends StatefulWidget {
  final String canteenId;

  const SellerSalesReportScreen({Key? key, required this.canteenId}) : super(key: key);

  @override
  _SellerSalesReportScreenState createState() => _SellerSalesReportScreenState();
}

class _SellerSalesReportScreenState extends State<SellerSalesReportScreen> {
  final SalesReportViewModel _viewModel = SalesReportViewModel();
  bool _isWeekly = true;
  SalesReport? _report;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() => _isLoading = true);
    try {
      final report = await _viewModel.fetchSalesReport(widget.canteenId, _isWeekly);
      setState(() {
        _report = report;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String _formatCurrency(double value) {
    return value.toStringAsFixed(0).replaceAllMapped(
        RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]}.');
  }

  Widget _buildTabButton(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isWeekly = (title == 'Mingguan');
          _loadReport();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0A5744) : Colors.white,
          border: Border.all(color: const Color(0xFF0A5744)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF0A5744),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildInfoBox({required String title, required Widget content}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 8)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          content,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A5744),
        title: const Text('Laporan Penjualan'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildTabButton('Mingguan', _isWeekly),
                      const SizedBox(width: 16),
                      _buildTabButton('Bulanan', !_isWeekly),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD6E9D8),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Rp ${_report != null ? _formatCurrency(_report!.totalSales) : '0'}',
                          style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoBox(
                          title: 'Penjualan Berdasarkan Jenis',
                          content: Column(
                            children: _report?.categorySales.entries
                                    .map((e) => Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(e.key),
                                            Text('Rp ${_formatCurrency(e.value)}'),
                                          ],
                                        ))
                                    .toList() ??
                                [],
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildInfoBox(
                          title: 'Informasi Lainnya',
                          content: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Total Transaksi'),
                                  Text('${_report?.totalTransactions ?? 0}'),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Item Terjual'),
                                  Text('${_report?.totalItemsSold ?? 0}'),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                 builder: (context) => SellerSalesReportListScreen(
          canteenId: widget.canteenId, )
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFA31D),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Lihat Daftar Selengkapnya',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
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
}
