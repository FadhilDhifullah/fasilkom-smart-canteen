import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/cart_model.dart';

class CartViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addToCart(
    String menuId,
    String menuName,
    String canteenName,
    String canteenId, // Tambahkan parameter canteenId
    double price,
    String category,
  ) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw 'Pengguna tidak ditemukan';

    final buyerId = user.uid;

    // Ambil data menu dari koleksi menus
    final menuDoc = await _firestore.collection('menus').doc(menuId).get();
    if (!menuDoc.exists) throw 'Menu tidak ditemukan';

    final menuData = menuDoc.data() as Map<String, dynamic>;
    final imageUrl = menuData['imageUrl'] ?? '';
    final stock = menuData['stock'] ?? 0;

    // Pastikan stok mencukupi
    if (stock <= 0) throw 'Stok tidak mencukupi';

    // Tambahkan ke keranjang dengan data lengkap
    final cartRef = await _firestore.collection('cart').add({
      'buyerId': buyerId,
      'menuId': menuId,
      'menuName': menuName,
      'canteenName': canteenName,
      'canteenId': canteenId, // Tambahkan canteenId ke dokumen
      'price': price,
      'quantity': 1, // Jumlah default 1
      'category': category,
      'imageUrl': imageUrl, // Tambahkan imageUrl ke dokumen
      'stock': stock, // Tambahkan stok awal ke dokumen
    });

    // Update dokumen untuk menyimpan cartId di dalam dokumen
    await cartRef.update({'cartId': cartRef.id});

    // Kurangi stok menu
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(menuDoc.reference);
      if (!snapshot.exists) throw 'Menu tidak ditemukan';

      final currentStock = snapshot['stock'] as int;
      if (currentStock <= 0) throw 'Stok tidak mencukupi';

      transaction.update(menuDoc.reference, {'stock': currentStock - 1});
    });
  }

  // Metode untuk mendapatkan item keranjang berdasarkan buyerId
  Stream<List<CartModel>> getCartItems(String buyerId) {
    return _firestore
        .collection('cart')
        .where('buyerId', isEqualTo: buyerId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CartModel.fromFirestore(doc.data(), doc.id))
            .toList());
  }

  // Metode untuk memperbarui jumlah (quantity) item keranjang
  Future<void> updateQuantity(String cartId, int newQuantity) async {
    if (newQuantity < 1) throw 'Quantity tidak bisa kurang dari 1';
    await _firestore.collection('cart').doc(cartId).update({'quantity': newQuantity});
  }

  // Metode untuk menghapus item dari keranjang
  Future<void> deleteCartItem(String cartId) async {
    final cartDoc = await _firestore.collection('cart').doc(cartId).get();
    if (!cartDoc.exists) return;

    final cartData = cartDoc.data() as Map<String, dynamic>;
    final menuId = cartData['menuId'];
    final quantity = cartData['quantity'];

    await _firestore.runTransaction((transaction) async {
      final menuDoc = _firestore.collection('menus').doc(menuId);
      final snapshot = await transaction.get(menuDoc);
      if (snapshot.exists) {
        final currentStock = snapshot['stock'] as int;
        transaction.update(menuDoc, {'stock': currentStock + quantity});
      }
      transaction.delete(cartDoc.reference);
    });
  }

  // Metode untuk memperbarui stok menu
  Future<void> updateStock(String menuId, int newStock) async {
    if (newStock < 0) throw 'Stok tidak bisa kurang dari 0';
    await _firestore.collection('menus').doc(menuId).update({'stock': newStock});
  }
}
