import 'package:flutter/material.dart';
import 'package:my_app/screens/order_screen.dart';
import 'package:my_app/screens/user_products_screen.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        AppBar(
          title: Text('Hello'),
          automaticallyImplyLeading: false,
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.shop),
          title: Text('Shop'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        ListTile(
          leading: Icon(Icons.credit_card),
          title: Text('Orders'),
          onTap: () {
            Navigator.pushReplacementNamed(context, OrderScreen.routeName);
          },
        ),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage Products'),
          onTap: () {
            Navigator.pushReplacementNamed(
                context, UserProductsScreen.routeName);
          },
        )
      ]),
    );
  }
}
