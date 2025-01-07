class SellerOutletModel {
  final String uid;
  final String ownerName;
  final String shopName;
  final String email;
  final String phone;
  final String description;
  final String openTime;
  final String closeTime;
  final bool isShopOpen;

  SellerOutletModel({
    required this.uid,
    required this.ownerName,
    required this.shopName,
    required this.email,
    required this.phone,
    required this.description,
    required this.openTime,
    required this.closeTime,
    required this.isShopOpen,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'ownerName': ownerName,
      'shopName': shopName,
      'email': email,
      'phone': phone,
      'description': description,
      'openTime': openTime,
      'closeTime': closeTime,
      'isShopOpen': isShopOpen,
    };
  }

  static SellerOutletModel fromMap(Map<String, dynamic> map) {
    return SellerOutletModel(
      uid: map['uid'],
      ownerName: map['ownerName'],
      shopName: map['shopName'],
      email: map['email'],
      phone: map['phone'],
      description: map['description'],
      openTime: map['openTime'],
      closeTime: map['closeTime'],
      isShopOpen: map['isShopOpen'],
    );
  }
}
