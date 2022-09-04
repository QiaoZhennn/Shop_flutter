import 'package:flutter/material.dart';
import 'package:my_app/providers/products.dart';
import 'package:my_app/screens/edit_product_screen.dart';
import 'package:my_app/widgets/app_drawer.dart';
import 'package:provider/provider.dart';

import '../widgets/user_product_item.dart';

class UserProductsScreen extends StatelessWidget {
  const UserProductsScreen({Key? key}) : super(key: key);
  static const String routeName = '/user_product';
  Future<void> _refreshProducts(BuildContext ctx) async {
    // must listen = false, otherwise will infinite loop
    await Provider.of<Products>(ctx, listen: false).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) {
    // final productsData = Provider.of<Products>(context);
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
      body: FutureBuilder(
        future: _refreshProducts(context),
        builder: (ctx, snapshot) =>
            snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : RefreshIndicator(
                    onRefresh: () => _refreshProducts(ctx),
                    child: Consumer<Products>(
                      builder: (ctx, productsData, _) => Padding(
                        padding: EdgeInsets.all(8),
                        child: ListView.builder(
                            itemCount: productsData.items.length,
                            itemBuilder: ((ctx, index) => Column(
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
                    ),
                  ),
      ),
    );
  }
}
