import 'package:flutter/material.dart';

class CartInstance {
  final String id;
  final String productId;
  final String title;
  int quantity;
  final double price;

  CartInstance(this.id, this.productId, this.title, this.quantity, this.price);
}

class Cart with ChangeNotifier {
  Map<String, CartInstance> _items = {};

  Map<String, CartInstance> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    double total = 0.0;
    _items.forEach((key, value) {
      total += value.price * value.quantity;
    });
    return total;
  }

  void addItem(String productId, double price, String title) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (value) => CartInstance(value.id, productId, value.title,
              value.quantity + 1, value.price));
    } else {
      _items.putIfAbsent(
          productId,
          (() => CartInstance(
              DateTime.now().toString(), productId, title, 1, price)));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) {
      return;
    }
    if (_items[productId]!.quantity > 1) {
      _items[productId]!.quantity -= 1;
    } else if (_items[productId]!.quantity == 1) {
      _items.remove(productId);
    }
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }
}
