import 'package:cloud_firestore/cloud_firestore.dart';

class OrderStatusModel {
  final String orderId;
  final String buyerId;
  final String canteenId;
  final String canteenName;
  final List<Map<String, dynamic>> items; // Tambahkan untuk menyimpan daftar menu
  final String paymentMethod;
  final double price; // Tetap ada jika ingin menyimpan total harga
  final int quantity; // Tetap ada untuk kompatibilitas
  final String status;
  final String? proofImageUrl; // URL bukti pembayaran (opsional)
  final DateTime timestamp;

  OrderStatusModel({
    required this.orderId,
    required this.buyerId,
    required this.canteenId,
    required this.canteenName,
    required this.items,
    required this.paymentMethod,
    required this.price,
    required this.quantity,
    required this.status,
    this.proofImageUrl,
    required this.timestamp,
  });

  factory OrderStatusModel.fromFirestore(Map<String, dynamic> data, String id) {
    return OrderStatusModel(
      orderId: id,
      buyerId: data['buyerId'] ?? '',
      canteenId: data['canteenId'] ?? '',
      canteenName: data['canteenName'] ?? '',
      items: (data['items'] as List<dynamic>?)?.map((e) => Map<String, dynamic>.from(e)).toList() ?? [],
      paymentMethod: data['paymentMethod'] ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0, // Tetap konversi jika disimpan
      quantity: (data['quantity'] as num?)?.toInt() ?? 0, // Tetap kompatibel
      status: data['status'] ?? 'Pending',
      proofImageUrl: data['proofImageUrl'],
      timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'buyerId': buyerId,
      'canteenId': canteenId,
      'canteenName': canteenName,
      'items': items, // Menyimpan array menu
      'paymentMethod': paymentMethod,
      'price': price, // Tetap ada
      'quantity': quantity, // Tetap ada
      'status': status,
      'proofImageUrl': proofImageUrl,
      'timestamp': timestamp,
    };
  }
  
}
