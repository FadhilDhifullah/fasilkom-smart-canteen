class CartModel {
  final String cartId;
  final String buyerId;
  final String menuId;
  final String menuName;
  final String canteenName;
  final String canteenId; // Tambahkan field canteenId
  final double price;
  final int quantity;
  final String category;

  CartModel({
    required this.cartId,
    required this.buyerId,
    required this.menuId,
    required this.menuName,
    required this.canteenName,
    required this.canteenId, // Tambahkan ke konstruktor
    required this.price,
    required this.quantity,
    required this.category,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'cartId': cartId,
      'buyerId': buyerId,
      'menuId': menuId,
      'menuName': menuName,
      'canteenName': canteenName,
      'canteenId': canteenId, // Tambahkan ke peta
      'price': price,
      'quantity': quantity,
      'category': category,
    };
  }

  static CartModel fromFirestore(Map<String, dynamic> data, String id) {
    return CartModel(
      cartId: id,
      buyerId: data['buyerId'] ?? '',
      menuId: data['menuId'] ?? '',
      menuName: data['menuName'] ?? '',
      canteenName: data['canteenName'] ?? '',
      canteenId: data['canteenId'] ?? '', // Ambil dari Firestore
      price: data['price'] ?? 0.0,
      quantity: data['quantity'] ?? 0,
      category: data['category'] ?? '',
    );
  }
}
