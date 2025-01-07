import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/firebase_service.dart';
import '../models/seller_model.dart';

class AuthViewModel {
  final AuthService _authService = AuthService();
  final FirebaseService _firebaseService = FirebaseService();

  // Mendapatkan pengguna yang sedang login
  User? get currentUser => _authService.currentUser;

  /// **Pendaftaran Penjual**
  Future<void> registerSeller(SellerModel seller, String password) async {
    try {
      final user = await _authService.registerWithEmailAndPassword(seller.email, password);
      if (user != null) {
        final sellerData = seller.toMap();
        sellerData['uid'] = user.uid;
        sellerData['role'] = 'seller'; // Tambahkan peran sebagai seller

        // Simpan data penjual di Firestore
        await _firebaseService.saveSellerData(user.uid, sellerData);
      }
    } catch (e) {
      print("Error during seller registration: $e");
      rethrow;
    }
  }

  /// **Pendaftaran Pelanggan**
  Future<void> registerCustomer({
    required String fullName,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      final user = await _authService.registerWithEmailAndPassword(email, password);
      if (user != null) {
        final customerData = {
          'uid': user.uid,
          'fullName': fullName,
          'email': email,
          'phoneNumber': phoneNumber,
          'role': 'customer', // Tambahkan peran sebagai customer
        };

        // Simpan data pelanggan di Firestore
        await _firebaseService.saveCustomerData(user.uid, customerData);
      }
    } catch (e) {
      print("Error during customer registration: $e");
      rethrow;
    }
  }

  /// **Login untuk Penjual dan Pelanggan**
  Future<String> login(String email, String password) async {
    try {
      final user = await _authService.loginWithEmailAndPassword(email, password);
      if (user != null) {
        // Ambil data pengguna dari Firestore berdasarkan UID
        final userData = await _firebaseService.getUserData(user.uid);

        if (userData['role'] == 'seller') {
          print("Login sebagai penjual berhasil: ${user.uid}");
          return 'seller';
        } else if (userData['role'] == 'customer') {
          print("Login sebagai pelanggan berhasil: ${user.uid}");
          return 'customer';
        } else {
          throw 'Peran pengguna tidak valid.';
        }
      } else {
        throw 'Login gagal. Pengguna tidak ditemukan.';
      }
    } catch (e) {
      print("Error during login: $e");
      rethrow;
    }
  }
  
}
