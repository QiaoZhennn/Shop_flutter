import 'package:flutter/material.dart';
import 'package:my_app/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartInstance> products;
  final DateTime dateTime;

  OrderItem(this.id, this.amount, this.products, this.dateTime);
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  List<OrderItem> get orders {
    return [..._orders];
  }

  void addOrder(List<CartInstance> cart, double total) {
    _orders.insert(
        0, OrderItem(DateTime.now().toString(), total, cart, DateTime.now()));
    notifyListeners();
  }
}
