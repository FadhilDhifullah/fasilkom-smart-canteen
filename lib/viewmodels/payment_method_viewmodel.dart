import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/payment_method_model.dart';

class PaymentMethodViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Mengambil metode pembayaran dari Firestore berdasarkan uid
  Future<PaymentMethodModel?> fetchPaymentMethods(String uid) async {
    try {
      final doc = await _firestore.collection('payment_methods').doc(uid).get();
      if (doc.exists) {
        return PaymentMethodModel.fromFirestore(doc.data()!);
      }
      return null;
    } catch (e) {
      throw 'Gagal mengambil data metode pembayaran: $e';
    }
  }

  /// Menyimpan metode pembayaran ke Firestore
  Future<void> savePaymentMethods(
      String uid, String sellerId, PaymentMethodModel paymentMethods) async {
    try {
      await _firestore.collection('payment_methods').doc(uid).set({
        ...paymentMethods.toFirestore(),
        'sellerId': sellerId, // Tambahkan sellerId ke dalam data
      });
    } catch (e) {
      throw 'Gagal menyimpan metode pembayaran: $e';
    }
  }

  /// Mengunggah gambar QRIS ke Firebase Storage dan mengembalikan URL
  Future<String?> uploadQRISImage(String uid, File imageFile) async {
    try {
      final fileName = '${uid}_qris.png';
      final storageRef = _storage.ref().child('qris_images/$fileName');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      throw 'Gagal mengunggah gambar QRIS: $e';
    }
  }
}
