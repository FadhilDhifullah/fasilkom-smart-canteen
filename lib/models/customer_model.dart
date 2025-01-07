class Customer {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final Map<String, dynamic>? address; // pakai dynamic jika isinya bervariasi
  final String? profilePicture;        // tambah field ini

  Customer({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.address,
    this.profilePicture,               // tambahkan
  });

  factory Customer.fromMap(Map<String, dynamic> data) {
    return Customer(
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? 'Nama tidak tersedia',
      email: data['email'] ?? 'Email tidak tersedia',
      phoneNumber: data['phoneNumber'] ?? 'Nomor telepon tidak tersedia',
      address: data['address'] != null
          ? Map<String, dynamic>.from(data['address'])
          : null,
      profilePicture: data['profilePicture'] as String?, // baca field
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      if (address != null) 'address': address,
      if (profilePicture != null) 'profilePicture': profilePicture,
    };
  }
}
