import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sales_report_model.dart';

class SalesReportViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<SalesReport> fetchSalesReport(String canteenId, bool isWeekly) async {
    try {
      DateTime now = DateTime.now();
      DateTime startDate = isWeekly
          ? now.subtract(Duration(days: now.weekday)) // Start of the week
          : DateTime(now.year, now.month); // Start of the month

      final querySnapshot = await _firestore
          .collection('orders')
          .where('canteenId', isEqualTo: canteenId)
          .where('status', isEqualTo: 'Selesai')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .get();

      double totalSales = 0;
      int totalTransactions = 0;
      int totalItemsSold = 0;
      Map<String, double> categorySales = {};

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        totalTransactions++;
        List<dynamic> items = data['items'] ?? [];

        for (var item in items) {
          double price = item['price']?.toDouble() ?? 0;
          int quantity = item['quantity']?.toInt() ?? 0;
          String category = item['category'] ?? 'Uncategorized';

          totalSales += price * quantity;
          totalItemsSold += quantity;

          if (!categorySales.containsKey(category)) {
            categorySales[category] = 0;
          }
          categorySales[category] = categorySales[category]! + (price * quantity);
        }
      }

      return SalesReport(
        totalSales: totalSales,
        totalTransactions: totalTransactions,
        totalItemsSold: totalItemsSold,
        categorySales: categorySales,
      );
    } catch (e) {
      throw Exception('Failed to fetch sales report: $e');
    }
  }
}
