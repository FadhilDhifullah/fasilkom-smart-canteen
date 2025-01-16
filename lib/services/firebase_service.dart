import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// **Simpan data penjual**
  Future<void> saveSellerData(String uid, Map<String, dynamic> sellerData) async {
    try {
      await _firestore.collection('sellers').doc(uid).set(sellerData);
    } catch (e) {
      throw 'Gagal menyimpan data penjual: $e';
    }
  }

  /// **Simpan data pelanggan**
  Future<void> saveCustomerData(String uid, Map<String, dynamic> customerData) async {
    try {
      await _firestore.collection('customers').doc(uid).set(customerData);
    } catch (e) {
      throw 'Gagal menyimpan data pelanggan: $e';
    }
  }

  /// **Ambil data pengguna berdasarkan UID**
  Future<Map<String, dynamic>> getUserData(String uid) async {
    try {
      final sellerDoc = await _firestore.collection('sellers').doc(uid).get();
      if (sellerDoc.exists) {
        return sellerDoc.data()!;
      }

      final customerDoc = await _firestore.collection('customers').doc(uid).get();
      if (customerDoc.exists) {
        return customerDoc.data()!;
      }

      throw 'Data pengguna tidak ditemukan untuk UID: $uid';
    } catch (e) {
      throw 'Gagal mengambil data pengguna: $e';
    }
  }

  /// **Inisialisasi data untuk penjual baru**
  Future<void> initializeSellerData(String uid, Map<String, dynamic> sellerData) async {
    try {
      // Inisialisasi transaksi
      await _firestore.collection('transactions').doc(uid).set({
        'uid': uid,
        'transactionCount': 0,
        'dailyIncome': 0.0,
      });

      // Inisialisasi jam operasional
      await _firestore.collection('operationalHours').doc(uid).set({
        'uid': uid,
        'openTime': '00:00',
        'closeTime': '00:00',
        'isShopOpen': false,
      });

      // Inisialisasi data outlet
      await fetchOrCreateOutletData(uid);
    } catch (e) {
      throw 'Gagal menginisialisasi data penjual: $e';
    }
  }

  /// **Ambil atau buat data outlet**
  Future<Map<String, dynamic>> fetchOrCreateOutletData(String uid) async {
    try {
      final outletRef = _firestore.collection('outlets').doc(uid);
      final outletSnapshot = await outletRef.get();

      if (!outletSnapshot.exists) {
        final sellerRef = _firestore.collection('sellers').doc(uid);
        final sellerSnapshot = await sellerRef.get();

        if (!sellerSnapshot.exists) {
          throw 'Data seller tidak ditemukan untuk UID: $uid';
        }

        final sellerData = sellerSnapshot.data()!;
        final outletData = {
          'uid': uid,
          'ownerName': sellerData['ownerName'] ?? 'Pemilik Baru',
          'shopName': sellerData['canteenName'] ?? 'Toko Baru',
          'email': sellerData['email'] ?? 'email@example.com',
          'phone': sellerData['phoneNumber'] ?? '08123456789',
          'description': sellerData['description'] ?? 'Deskripsi outlet',
          'openTime': '00:00',
          'closeTime': '00:00',
          'isShopOpen': false,
        };

        await outletRef.set(outletData);
        return outletData;
      }

      return outletSnapshot.data()!;
    } catch (e) {
      throw 'Gagal mengambil atau membuat data outlet: $e';
    }
  }

  /// **Ambil data penjual berdasarkan UID**
  Future<Map<String, dynamic>> getSellerData(String uid) async {
    try {
      final sellerSnapshot = await _firestore.collection('sellers').doc(uid).get();
      final transactionSnapshot = await _firestore.collection('transactions').doc(uid).get();
      final operationalSnapshot = await _firestore.collection('operationalHours').doc(uid).get();
      final outletSnapshot = await _firestore.collection('outlets').doc(uid).get();

      return {
        'seller': sellerSnapshot.data(),
        'transactions': transactionSnapshot.data(),
        'operationalHours': operationalSnapshot.data(),
        'outlet': outletSnapshot.data(),
      };
    } catch (e) {
      throw 'Gagal mendapatkan data penjual untuk UID: $uid, Error: $e';
    }
  }
  /// **Perbarui URL gambar penjual (sellers)**
  Future<void> updateSellerImage(String uid, String imageUrl) async {
    try {
      await _firestore.collection('sellers').doc(uid).update({'imageUrl': imageUrl});
    } catch (e) {
      throw 'Gagal memperbarui gambar penjual: $e';
    }
  }

  /// **Perbarui URL gambar outlet**
  Future<void> updateOutletImage(String uid, String imageUrl) async {
    try {
      await _firestore.collection('outlets').doc(uid).update({'imageUrl': imageUrl});
    } catch (e) {
      throw 'Gagal memperbarui gambar outlet: $e';
    }
  }

  /// **Perbarui data transaksi penjual**
  Future<void> updateTransactionData(String uid, int transactionCount, double dailyIncome) async {
    try {
      await _firestore.collection('transactions').doc(uid).update({
        'transactionCount': transactionCount,
        'dailyIncome': dailyIncome,
      });
    } catch (e) {
      throw 'Gagal memperbarui data transaksi: $e';
    }
  }

  /// **Perbarui jam operasional**
  Future<void> updateOperationalHours(String uid, String openTime, String closeTime, bool isShopOpen) async {
    try {
      await _firestore.collection('operationalHours').doc(uid).update({
        'openTime': openTime,
        'closeTime': closeTime,
        'isShopOpen': isShopOpen,
      });
    } catch (e) {
      throw 'Gagal memperbarui jam operasional: $e';
    }
  }

  /// **Perbarui data outlet**
  Future<void> updateOutletData(String uid, Map<String, dynamic> data) async {
    try {
      await _firestore.collection('outlets').doc(uid).update(data);
    } catch (e) {
      throw 'Gagal memperbarui data outlet: $e';
    }
  }
}
