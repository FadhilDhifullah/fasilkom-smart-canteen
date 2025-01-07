class SellerTransactionModel {
  final String uid; // Menyimpan UID
  final int transactionCount;
  final double dailyIncome;

  SellerTransactionModel({
    required this.uid,
    required this.transactionCount,
    required this.dailyIncome,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'transactionCount': transactionCount,
      'dailyIncome': dailyIncome,
    };
  }

  static SellerTransactionModel fromMap(Map<String, dynamic> map) {
    return SellerTransactionModel(
      uid: map['uid'],
      transactionCount: map['transactionCount'],
      dailyIncome: map['dailyIncome'],
    );
  }
}
