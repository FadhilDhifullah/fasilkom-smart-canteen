import 'package:flutter/material.dart';
import '../models/order_item_model.dart';

class OrderViewModel extends ChangeNotifier {
  List<OrderItem> _orderItems = [];
  String _paymentMethod = "QRIS";

  List<OrderItem> get orderItems => _orderItems;
  String get paymentMethod => _paymentMethod;

  void addItem(OrderItem item) {
    _orderItems.add(item);
    notifyListeners();
  }

  void updateQuantity(String orderId, int newQuantity) {
  final item = _orderItems.firstWhere((element) => element.orderId == orderId);
  if (newQuantity > 0) {
    item.quantity = newQuantity;
  } else {
    _orderItems.remove(item);
  }
  notifyListeners();
}

void updateNotes(String orderId, String notes) {
  final item = _orderItems.firstWhere((element) => element.orderId == orderId);
  item.notes = notes;
  notifyListeners();
}


  void updatePaymentMethod(String method) {
    _paymentMethod = method;
    notifyListeners();
  }

  double get totalPrice => _orderItems.fold(
      0, (sum, item) => sum + item.totalPrice);

  void clearOrders() {
    _orderItems.clear();
    notifyListeners();
  }
}
