import 'package:flutter/material.dart';
import 'package:my_app/providers/products.dart';
import 'package:my_app/screens/cart_screen.dart';
import 'package:my_app/widgets/app_drawer.dart';
import 'package:my_app/widgets/badge.dart';
import 'package:provider/provider.dart';
import 'package:my_app/widgets/product_item.dart';
import '../providers/cart.dart';

enum FilterOptions { Favorites, All }

class ProductsOverviewScreen extends StatefulWidget {
  ProductsOverviewScreen({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  bool _showFavoritesOnly = false;
  bool _isInit = true;
  bool _isLoading = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((value) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final products =
        _showFavoritesOnly ? productsData.favorite_items : productsData.items;

    return Scaffold(
      appBar: AppBar(
        title: const Text('MyShop'),
        actions: [
          PopupMenuButton(
            onSelected: (FilterOptions option) {
              setState(() {
                if (option == FilterOptions.Favorites) {
                  _showFavoritesOnly = true;
                } else {
                  _showFavoritesOnly = false;
                }
              });
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: FilterOptions.Favorites,
                child: Text('Only Favorites'),
              ),
              PopupMenuItem(
                value: FilterOptions.All,
                child: Text('Show All'),
              )
            ],
          ),
          Consumer<Cart>(
            builder: (context, cart, ch) =>
                Badge(value: cart.itemCount.toString(), child: ch!),
            child: IconButton(
              icon: const Icon(Icons.shopping_cart),
              onPressed: () =>
                  {Navigator.of(context).pushNamed(CartScreen.routeName)},
            ),
          )
        ],
      ),
      drawer: AppDrawer(),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10),
              itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
                value: products[i],
                child: ProductItemWidget(),
              ),
            ),
    );
  }
}
