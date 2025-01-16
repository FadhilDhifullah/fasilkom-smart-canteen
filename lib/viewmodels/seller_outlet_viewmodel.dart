import 'dart:io';
import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
class SellerOutletViewModel {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  // Ambil data penjual berdasarkan UID
  Future<Map<String, dynamic>> getSellerData(String uid) async {
    try {
      return await _firebaseService.getSellerData(uid);
    } catch (e) {
      throw 'Gagal mengambil data penjual: $e';
    }
  }

  // Ambil atau buat data outlet
  Future<Map<String, dynamic>> fetchOrCreateOutletData(String uid) async {
    return await _firebaseService.fetchOrCreateOutletData(uid);
  }

  // Perbarui data outlet
  Future<void> updateOutletData(String uid, Map<String, dynamic> data) async {
    await _firebaseService.updateOutletData(uid, data);
  }

  // Upload foto profil ke Firebase Storage
  Future<String> uploadProfilePicture(String uid, File imageFile) async {
    try {
      final ref = _firebaseStorage.ref().child('profile_pictures/$uid');
      final uploadTask = await ref.putFile(imageFile);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw 'Gagal mengunggah foto profil: $e';
    }
  }

  // Perbarui URL gambar untuk seller dan outlet
  Future<void> updateSellerAndOutletImage(String uid, String imageUrl) async {
    try {
      // Update data di Firestore
      await _firebaseService.updateSellerImage(uid, imageUrl);
      await _firebaseService.updateOutletImage(uid, imageUrl);
    } catch (e) {
      throw 'Gagal memperbarui foto profil: $e';
    }
  }

  // Fitur reset password
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw e.message ?? 'Terjadi kesalahan saat mereset password.';
    }
  }
}
