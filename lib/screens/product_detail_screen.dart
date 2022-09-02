import 'package:flutter/material.dart';
import 'package:my_app/providers/products_provider.dart';
import 'package:provider/provider.dart';
import 'package:my_app/providers/products_provider.dart';

class ProductDetailScreen extends StatelessWidget {
  static const String routeName = '/product_detail';

  const ProductDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final String productId =
        ModalRoute.of(context)!.settings.arguments as String;
    final loadedProduct = Provider.of<ProductsProvider>(context, listen: false)
        .findById(productId);
    return Scaffold(
      appBar: AppBar(title: Text(loadedProduct.title)),
    );
  }
}
