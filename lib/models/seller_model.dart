class SellerModel {
  final String? uid;
  final String canteenName;
  final String email;
  final String address;
  final String description;
  final String imageUrl;

  SellerModel({
    this.uid,
    required this.canteenName,
    required this.email,
    required this.address,
    required this.description,
    required this.imageUrl,
  });

  // Konversi objek menjadi Map
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'canteenName': canteenName,
      'email': email,
      'address': address,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
