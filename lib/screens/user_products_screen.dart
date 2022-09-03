import 'package:flutter/material.dart';
import 'package:my_app/providers/products_provider.dart';
import 'package:my_app/screens/edit_product_screen.dart';
import 'package:my_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);
  static const String routeName = '/user_product';

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your products'),
        actions: [
          IconButton(
              icon: const Icon(Icons.add),
              onPressed: (() {
                Navigator.of(context).pushNamed(EditProductScreen.routeName);
              }))
        ],
      ),
      drawer: AppDrawer(),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: ListView.builder(
            itemCount: productsData.items.length,
            itemBuilder: ((context, index) => Column(
                  children: [
                    UserProductItem(
                      productsData.items[index].id,
                      productsData.items[index].title,
                      productsData.items[index].imageUrl,
                    ),
                    Divider(),
                  ],
                ))),
      ),
    );
  }
}
