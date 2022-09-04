import 'package:flutter/material.dart';
import 'package:my_app/screens/order_screen.dart';
import 'package:my_app/screens/user_products_screen.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';

class AppDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(children: [
        AppBar(
          title: Text('Hello'),
          automaticallyImplyLeading: false,
        ),
        ListTile(
          leading: Icon(Icons.shop),
          title: Text('Shop'),
          onTap: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.credit_card),
          title: Text('Orders'),
          onTap: () {
            Navigator.pushReplacementNamed(context, OrderScreen.routeName);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.edit),
          title: Text('Manage Products'),
          onTap: () {
            Navigator.pushReplacementNamed(
                context, UserProductsScreen.routeName);
          },
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.logout),
          title: Text('Logout'),
          onTap: () {
            Navigator.of(context).pop();
            Navigator.pushReplacementNamed(context, '/');
            Provider.of<Auth>(context, listen: false).logout();
          },
        )
      ]),
    );
  }
}
