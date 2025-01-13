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
    };
  }
  
}

