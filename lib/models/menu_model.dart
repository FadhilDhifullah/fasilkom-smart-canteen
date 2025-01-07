class MenuModel {
  final String id;
  final String name;
  final String category;
  final int stock;
  final double price;
  final String imageUrl;
  final String uid; // UID pengguna yang login
  final String canteenName; // Nama kantin
  final String canteenId; // ID Kantin (baru ditambahkan)

  MenuModel({
    required this.id,
    required this.name,
    required this.category,
    required this.stock,
    required this.price,
    required this.imageUrl,
    required this.uid,
    required this.canteenName,
    required this.canteenId, // Tambahkan ini
  });

  factory MenuModel.fromFirestore(Map<String, dynamic> data, String id) {
    return MenuModel(
      id: id,
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      stock: data['stock'] ?? 0,
      price: (data['price'] ?? 0).toDouble(),
      imageUrl: data['imageUrl'] ?? '',
      uid: data['uid'] ?? '',
      canteenName: data['canteenName'] ?? '',
      canteenId: data['canteenId'] ?? '', // Ambil canteenId
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'category': category,
      'stock': stock,
      'price': price,
      'imageUrl': imageUrl,
      'uid': uid,
      'canteenName': canteenName,
      'canteenId': canteenId, // Simpan canteenId
    };
  }
}
