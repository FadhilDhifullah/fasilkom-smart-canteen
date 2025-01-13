import 'package:cloud_firestore/cloud_firestore.dart';

class SellerHomeViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> fetchSellerHomeData(String canteenId) async {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);

    // Query untuk transaksi selesai hari ini
    final snapshot = await _firestore
        .collection('orders')
        .where('canteenId', isEqualTo: canteenId)
        .where('status', isEqualTo: 'Selesai')
        .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
        .get();

    double dailyIncome = 0;
    int transactionCount = snapshot.docs.length;

    for (var doc in snapshot.docs) {
      final data = doc.data();
      final items = List<Map<String, dynamic>>.from(data['items']);
      for (var item in items) {
        final price = item['price'] as double;
        final quantity = item['quantity'] as int;
        dailyIncome += price * quantity;
      }
    }

    // Mendapatkan informasi penjual dari Firestore
    final sellerSnapshot =
        await _firestore.collection('sellers').doc(canteenId).get();

    return {
      'seller': sellerSnapshot.data() ?? {},
      'transactions': {
        'transactionCount': transactionCount,
        'dailyIncome': dailyIncome,
      },
    };
  }
}
