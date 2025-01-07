class PaymentMethodModel {
  final String sellerId; // ID penjual
  final bool isCOD;
  final bool isQRIS;
  final String? qrisUrl;

  PaymentMethodModel({
    required this.sellerId,
    required this.isCOD,
    required this.isQRIS,
    this.qrisUrl,
  });

  factory PaymentMethodModel.fromFirestore(Map<String, dynamic> data) {
    return PaymentMethodModel(
      sellerId: data['sellerId'] ?? '', // Pastikan sellerId selalu tersedia
      isCOD: data['isCOD'] ?? false,
      isQRIS: data['isQRIS'] ?? false,
      qrisUrl: data['qrisUrl'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'sellerId': sellerId,
      'isCOD': isCOD,
      'isQRIS': isQRIS,
      'qrisUrl': qrisUrl,
    };
  }
}
