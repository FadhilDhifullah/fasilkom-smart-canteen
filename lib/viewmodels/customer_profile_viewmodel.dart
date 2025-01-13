import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:apilikasi_smart_canteen/models/customer_model.dart';

class CustomerProfileViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<Customer?> fetchCustomerData(String uid) async {
    try {
      final doc = await _firestore.collection('customers').doc(uid).get();
      if (!doc.exists) {
        return null;
      }
      return Customer.fromMap(doc.data()!);
    } catch (e) {
      throw 'Gagal mengambil data pelanggan: $e';
    }
  }

  Future<void> updateCustomerData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('customers').doc(uid).update(data);
    } catch (e) {
      throw 'Gagal memperbarui data pelanggan: $e';
    }
  }

  Future<String> uploadProfilePicture(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$uid.jpg');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw 'Gagal mengunggah gambar: $e';
    }
  }
}
