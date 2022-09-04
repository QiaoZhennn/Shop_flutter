import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:my_app/api_keys.dart';
import 'package:my_app/models/http_exception.dart';

class ProductItem with ChangeNotifier {
  String id;
  String title;
  String description;
  double price;
  String imageUrl;
  bool isFavorite;

  ProductItem(
      {required this.id,
      required this.title,
      required this.description,
      required this.price,
      required this.imageUrl,
      this.isFavorite = false});

  Future<void> toggleFavoriteStatus(String? token, String? userId) async {
    final oldStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url = DB_BASE + 'userFavorites/$userId/${id}.json?auth=$token';
    try {
      final response =
          await http.put(Uri.parse(url), body: json.encode(isFavorite));
      if (response.statusCode >= 400) {
        isFavorite = oldStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = oldStatus;
      notifyListeners();
    }
  }
}

class Products with ChangeNotifier {
  final String? _authToken;
  final String? _userId;
  List<ProductItem> _items = [];
  Products(this._authToken, this._userId, this._items);

  var _showFavoriteOnly = false;

  List<ProductItem> get items {
    return [..._items];
  }

  List<ProductItem> get favorite_items {
    return _items.where((element) => element.isFavorite).toList();
  }

  ProductItem findById(String id) {
    return _items.firstWhere((element) => element.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$_userId"' : '';
    String url = DB_BASE + 'products.json?auth=$_authToken&$filterString';
    try {
      final response = await http.get(Uri.parse(url));
      final extractedData = json.decode(response.body);
      if (extractedData == null) {
        return;
      }
      url = DB_BASE + 'userFavorites/$_userId.json?auth=$_authToken';
      final favoriteResponse = await http.get(Uri.parse(url));
      final favoriteData = json.decode(favoriteResponse.body);
      final List<ProductItem> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(ProductItem(
          id: prodId,
          title: prodData['title'],
          description: prodData['description'],
          price: prodData['price'],
          imageUrl: prodData['imageUrl'],
          isFavorite:
              favoriteData == null ? false : favoriteData[prodId] ?? false,
        ));
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> addProduct(ProductItem product) async {
    final url = DB_BASE + 'products.json?auth=$_authToken';
    try {
      final response = await http.post(Uri.parse(url),
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': _userId
          }));

      final newProduct = ProductItem(
          id: json.decode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (error) {
      throw error;
    }
  }

  Future<void> editProduct(ProductItem product) async {
    final int idx = _items.indexWhere((element) => element.id == product.id);
    if (idx < 0) {
      return Future.value();
    }
    final url = DB_BASE + 'products/${product.id}.json?auth=$_authToken';
    await http.patch(Uri.parse(url),
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price
        }));
    _items[idx] = product;
    notifyListeners();
    return Future.value();
  }

  Future<void> deleteProduct(String id) async {
    final url = DB_BASE + 'products/${id}.json?auth=$_authToken';

    final existingProductIndex =
        _items.indexWhere((element) => element.id == id);
    ProductItem existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final res = await http.delete(Uri.parse(url));
    if (res.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Could not delete product");
    }
  }
}
