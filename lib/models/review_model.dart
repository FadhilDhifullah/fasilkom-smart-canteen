import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String canteenId;
  final String menuId;
  final String orderId;
  final String menuName;
  final String menuImageUrl;
  final String customerId;
  final String customerName;
  final String customerProfileImage;
  final String reviewText;
  final int rating;
  final DateTime timestamp;
  final String? reply; // Balasan dari penjual
  final String? replyProfileImage; // Gambar profil penjual untuk balasan
  final DateTime? replyTimestamp; // Waktu balasan

  ReviewModel({
    required this.reviewId,
    required this.canteenId,
    required this.menuId,
    required this.orderId,
    required this.menuName,
    required this.menuImageUrl,
    required this.customerId,
    required this.customerName,
    required this.customerProfileImage,
    required this.reviewText,
    required this.rating,
    required this.timestamp,
    this.reply, // Properti opsional
    this.replyProfileImage, // Properti opsional
    this.replyTimestamp, // Properti opsional
  });

  factory ReviewModel.fromMap(String id, Map<String, dynamic> data) {
    return ReviewModel(
      reviewId: id,
      canteenId: data['canteenId'] ?? '',
      menuId: data['menuId'] ?? '',
      orderId: data['orderId'] ?? '',
      menuName: data['menuName'] ?? '',
      menuImageUrl: data['menuImageUrl'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      customerProfileImage: data['customerProfileImage'] ?? '',
      reviewText: data['reviewText'] ?? '',
      rating: data['rating'] ?? 0,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      reply: data['reply'], // Ambil balasan jika ada
      replyProfileImage: data['replyProfileImage'], // Ambil gambar profil penjual jika ada
      replyTimestamp: data['replyTimestamp'] != null
          ? (data['replyTimestamp'] as Timestamp).toDate()
          : null, // Ambil waktu balasan jika ada
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'canteenId': canteenId,
      'menuId': menuId,
      'orderId': orderId,
      'menuName': menuName,
      'menuImageUrl': menuImageUrl,
      'customerId': customerId,
      'customerName': customerName,
      'customerProfileImage': customerProfileImage,
      'reviewText': reviewText,
      'rating': rating,
      'timestamp': timestamp,
      'reply': reply, // Tambahkan balasan jika ada
      'replyProfileImage': replyProfileImage, // Tambahkan gambar profil penjual jika ada
      'replyTimestamp': replyTimestamp, // Tambahkan waktu balasan jika ada
    };
  }
}
