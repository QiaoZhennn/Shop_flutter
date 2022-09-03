import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart.dart';

class CartItem extends StatelessWidget {
  final CartInstance cart_instance;
  CartItem(this.cart_instance);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(cart_instance.id),
      background: Container(
        color: Theme.of(context).colorScheme.primary,
        alignment: Alignment.centerRight,
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 40,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        Provider.of<Cart>(context, listen: false)
            .removeItem(cart_instance.productId);
      },
      confirmDismiss: (direction) => showDialog(
          context: context,
          builder: (context) => AlertDialog(
                title: const Text('Are u sure?'),
                content: const Text('Do you want to remove the item from cart'),
                actions: [
                  ElevatedButton(
                      onPressed: (() {
                        Navigator.of(context).pop(false);
                      }),
                      child: const Text('No')),
                  ElevatedButton(
                      onPressed: (() {
                        Navigator.of(context).pop(true);
                      }),
                      child: const Text('Yes')),
                ],
              )),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
        child: Padding(
          padding: EdgeInsets.all(8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: FittedBox(child: Text('\$${cart_instance.price}')),
            ),
            title: Text(cart_instance.title),
            subtitle: Text(
                'Total: \$${cart_instance.price * cart_instance.quantity}'),
            trailing: Text('${cart_instance.quantity} x'),
          ),
        ),
      ),
    );
  }
}
