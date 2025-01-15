class Customer {
  final String uid;
  final String fullName;
  final String email;
  final String phoneNumber;
  final Map<String, String>? address; // Stores province, city, and subdistrict
  final String? profilePicture;      // URL of the profile picture
  final String? nomorIndukMahasiswa; // NIM or Student Identification Number
  final bool? isEmailVerified;       // Email verification status

  Customer({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.address,
    this.profilePicture,
    this.nomorIndukMahasiswa,
    this.isEmailVerified,
  });

  /// Factory constructor to create a `Customer` instance from a map.
  factory Customer.fromMap(Map<String, dynamic> data) {
    return Customer(
      uid: data['uid'] ?? '',
      fullName: data['fullName'] ?? 'Nama tidak tersedia',
      email: data['email'] ?? 'Email tidak tersedia',
      phoneNumber: data['phoneNumber'] ?? 'Nomor telepon tidak tersedia',
      address: data['address'] != null
          ? Map<String, String>.from(data['address'])
          : null,
      profilePicture: data['profilePicture'] as String?,
      nomorIndukMahasiswa: data['nomorIndukMahasiswa'] as String?,
      isEmailVerified: data['isEmailVerified'] as bool?,
    );
  }

  /// Convert `Customer` instance to a map.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      if (address != null) 'address': address,
      if (profilePicture != null) 'profilePicture': profilePicture,
      if (nomorIndukMahasiswa != null) 'nomorIndukMahasiswa': nomorIndukMahasiswa,
      if (isEmailVerified != null) 'isEmailVerified': isEmailVerified,
    };
  }
}
