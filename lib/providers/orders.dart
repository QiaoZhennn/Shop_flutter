import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:my_app/api_keys.dart';
import 'package:my_app/providers/cart.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartInstance> products;
  final DateTime dateTime;

  OrderItem(this.id, this.amount, this.products, this.dateTime);
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];
  final String? _authToken;
  final String? _userId;
  Orders(this._authToken, this._userId, this._orders);
  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchAndSetOrders() async {
    final url = DB_BASE + 'orders/$_userId.json?auth=$_authToken';
    final response = await http.get(Uri.parse(url));
    final List<OrderItem> loadedOrders = [];
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    extractedData.forEach((orderId, orderData) {
      OrderItem orderItem = OrderItem(
          orderId,
          orderData['amount'],
          (orderData['products'] as List<dynamic>)
              .map((item) => CartInstance(item['id'], item['productId'],
                  item['title'], item['quantity'], item['price']))
              .toList(),
          DateTime.parse(orderData['dateTime']));
      loadedOrders.add(orderItem);
    });
    _orders = loadedOrders.reversed.toList();
  }

  Future<void> addOrder(List<CartInstance> cart, double total) async {
    final url = DB_BASE + 'orders/$_userId.json?auth=$_authToken';
    final ts = DateTime.now();
    await http.post(Uri.parse(url),
        body: json.encode({
          'amount': total,
          'dateTime': ts.toIso8601String(),
          'products': cart
              .map((e) => {
                    'id': e.id,
                    'productId': e.productId,
                    'title': e.title,
                    'quantity': e.quantity,
                    'price': e.price,
                  })
              .toList()
        }));
    _orders.insert(0, OrderItem(ts.toIso8601String(), total, cart, ts));
    notifyListeners();
  }
}
