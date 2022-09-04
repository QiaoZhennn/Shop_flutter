import 'package:flutter/material.dart';
import 'package:my_app/widgets/cart_item.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';
import '../providers/orders.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';
  const CartScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(title: Text('Your Cart')),
      body: Column(children: [
        Card(
          margin: EdgeInsets.all(15),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  const Spacer(),
                  Chip(
                    label: Text(
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: Theme.of(context).primaryTextTheme.titleSmall,
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  OrderButton(cart: cart)
                ]),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: ListView.builder(
                itemCount: cart.itemCount,
                itemBuilder: ((context, index) =>
                    CartItem(cart.items.values.toList()[index]))))
      ]),
    );
  }
}

class OrderButton extends StatefulWidget {
  const OrderButton({
    Key? key,
    required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> {
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: (widget.cart.totalAmount <= 0 || _isLoading) ? null : () async {
        setState(() {
          _isLoading = true;
        });
        await Provider.of<Orders>(context, listen: false).addOrder(
            widget.cart.items.values.toList(), widget.cart.totalAmount);
        widget.cart.clearCart();
        setState(() {
          _isLoading = false;
        });
      },
      child: _isLoading ? const CircularProgressIndicator() : const Text('Order Now'),
    );
  }
}
