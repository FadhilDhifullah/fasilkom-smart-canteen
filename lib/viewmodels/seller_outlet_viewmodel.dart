import '../services/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SellerOutletViewModel {
  final FirebaseService _firebaseService = FirebaseService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Ambil atau buat data outlet
  Future<Map<String, dynamic>> fetchOrCreateOutletData(String uid) async {
    return await _firebaseService.fetchOrCreateOutletData(uid);
  }

  // Perbarui data outlet
  Future<void> updateOutletData(String uid, Map<String, dynamic> data) async {
    await _firebaseService.updateOutletData(uid, data);
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
