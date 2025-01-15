class SellerOutletModel {
  final String uid;
  final String shopName;
  final String email;
  final String phone;
  final String description;
  final bool isShopOpen;

  SellerOutletModel({
    required this.uid,
    required this.shopName,
    required this.email,
    required this.phone,
    required this.description,
    required this.isShopOpen,
  });

  // Mengubah data model menjadi Map untuk disimpan ke database
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'shopName': shopName,
      'email': email,
      'phone': phone,
      'description': description,
      'isShopOpen': isShopOpen,
    };
  }

  // Membaca data dari Map dan mengubahnya menjadi objek SellerOutletModel
  static SellerOutletModel fromMap(Map<String, dynamic> map) {
    return SellerOutletModel(
      uid: map['uid'],
      shopName: map['shopName'],
      email: map['email'],
      phone: map['phone'],
      description: map['description'],
      isShopOpen: map['isShopOpen'],
    );
  }

  // Method untuk memperbarui data yang ada, jika dibutuhkan
  SellerOutletModel copyWith({
    String? ownerName,
    String? shopName,
    String? email,
    String? phone,
    String? description,
    String? openTime,
    String? closeTime,
    bool? isShopOpen,
  }) {
    return SellerOutletModel(
      uid: this.uid,
      shopName: shopName ?? this.shopName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      description: description ?? this.description,
      isShopOpen: isShopOpen ?? this.isShopOpen,
    );
  }
}
