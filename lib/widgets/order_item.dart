import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/orders.dart' as prov;
import 'package:intl/intl.dart';

class OrderItem extends StatefulWidget {
  const OrderItem(this.orderItem);
  final prov.OrderItem orderItem;

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      height: _expanded ? min(widget.orderItem.products.length * 22.0 + 110, 200): 95,
      child: Card(
        margin: EdgeInsets.all(10),
        child: Column(children: [
          ListTile(
            title: Text('\$${widget.orderItem.amount.toStringAsFixed(2)}'),
            subtitle: Text(
                DateFormat('dd/MM/yyyy hh:mm').format(widget.orderItem.dateTime)),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              height: _expanded ? min(widget.orderItem.products.length * 20 + 20, 100): 0,
              child: ListView.builder(
                itemCount: widget.orderItem.products.length,
                itemBuilder: (context, index) {
                  CartInstance prod = widget.orderItem.products[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        prod.title,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${prod.quantity} x \$${prod.price}',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      )
                    ],
                  );
                },
              ),
            )
        ]),
      ),
    );
  }
}
