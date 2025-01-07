import '../services/firebase_service.dart';


class SellerHomeViewModel {
  final FirebaseService _firebaseService = FirebaseService();

  Future<Map<String, dynamic>> fetchSellerHomeData(String uid) async {
    return await _firebaseService.getSellerData(uid);
  }

  Future<void> updateTransaction(String uid, int count, double income) async {
    await _firebaseService.updateTransactionData(uid, count, income);
  }
}
