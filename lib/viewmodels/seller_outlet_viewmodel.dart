import '../services/firebase_service.dart';

class SellerOutletViewModel {
  final FirebaseService _firebaseService = FirebaseService();

  // Ambil atau buat data outlet
  Future<Map<String, dynamic>> fetchOrCreateOutletData(String uid) async {
    return await _firebaseService.fetchOrCreateOutletData(uid);
  }

  // Perbarui data outlet
  Future<void> updateOutletData(String uid, Map<String, dynamic> data) async {
    await _firebaseService.updateOutletData(uid, data);
  }
}
