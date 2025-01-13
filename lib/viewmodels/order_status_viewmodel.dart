import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:apilikasi_smart_canteen/models/order_status_model.dart';
import 'dart:io';

class OrderStatusViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Stream<List<OrderStatusModel>> fetchOrdersByStatus(String buyerId, String status) {
  return _firestore
      .collection('orders')
      .where('buyerId', isEqualTo: buyerId)
      .where('status', isEqualTo: status)
      .snapshots(includeMetadataChanges: true)
      .map((snapshot) {
        print("Snapshot size: ${snapshot.docs.length}"); // Debug log
        return snapshot.docs.map((doc) {
          return OrderStatusModel.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
}





  Stream<List<OrderStatusModel>> fetchOrders(String buyerId) {
    return _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
              return OrderStatusModel.fromFirestore(doc.data(), doc.id);
            }).toList());
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': newStatus,
      });
    } catch (e) {
      throw 'Gagal memperbarui status pesanan: $e';
    }
  }

  Future<String?> uploadProofImage(String orderId, File imageFile) async {
    try {
      final fileName = '$orderId-proof.png';
      final storageRef = _storage.ref().child('order_proofs/$fileName');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Gagal mengunggah bukti pembayaran: $e';
    }
  }
  Future<List<OrderStatusModel>> fetchOrdersOnce(String buyerId, String status) async {
  try {
    final snapshot = await _firestore
        .collection('orders')
        .where('buyerId', isEqualTo: buyerId)
        .where('status', isEqualTo: status)
        .get(const GetOptions(source: Source.server));
    return snapshot.docs.map((doc) => OrderStatusModel.fromFirestore(doc.data(), doc.id)).toList();
  } catch (e) {
    throw "Gagal memuat data dari server: $e";
  }
}
Stream<List<OrderStatusModel>> fetchOrdersByCanteenAndStatus(String canteenId, String status) {
  return _firestore
      .collection('orders')
      .where('canteenId', isEqualTo: canteenId)
      .where('status', isEqualTo: status)
      .snapshots(includeMetadataChanges: true)
      .map((snapshot) {
        if (snapshot.metadata.isFromCache) {
          print("Data diambil dari cache, bukan server");
        } else {
          print("Data diambil dari server");
        }
        return snapshot.docs.map((doc) {
          return OrderStatusModel.fromFirestore(doc.data(), doc.id);
        }).toList();
      });
}
Future<List<OrderStatusModel>> fetchOrdersByCanteenAndStatusOnce(
    String canteenId, String status) async {
  try {
    final snapshot = await _firestore
        .collection('orders')
        .where('canteenId', isEqualTo: canteenId)
        .where('status', isEqualTo: status)
        .get(const GetOptions(source: Source.server));
    return snapshot.docs.map((doc) => OrderStatusModel.fromFirestore(doc.data(), doc.id)).toList();
  } catch (e) {
    throw "Gagal memuat data dari server: $e";
  }
}




}
