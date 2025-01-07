class OrderItem {
  final String itemId;
  final String itemName;
  final String category;
  final String canteenId;
  final String canteenName;
  final String canteenImageUrl;
  final String itemImageUrl;
  int quantity;
  String? notes;
  final double price;

  OrderItem({
    required this.itemId,
    required this.itemName,
    required this.category,
    required this.canteenId,
    required this.canteenName,
    required this.canteenImageUrl,
    required this.itemImageUrl,
    required this.quantity,
    this.notes,
    required this.price,
  });

  double get totalPrice => price * quantity;
}