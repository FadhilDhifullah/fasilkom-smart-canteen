import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendNotificationToCustomer(String userId, String title, String body) async {
    await _firestore.collection('notifications').add({
      'userId': userId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendNotificationToSeller(String sellerId, String title, String body) async {
    await _firestore.collection('notifications').add({
      'sellerId': sellerId,
      'title': title,
      'body': body,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}
