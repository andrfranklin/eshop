import 'dart:convert';
import 'dart:math';

import 'package:f05_eshop/data/dummy_data.dart';
import 'package:f05_eshop/model/product.dart';
import 'package:f05_eshop/model/user.dart';
import 'package:f05_eshop/utils/api.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class ProductList with ChangeNotifier {
  final _baseUrl = ApiData.baseURL;

  //https://st.depositphotos.com/1000459/2436/i/950/depositphotos_24366251-stock-photo-soccer-ball.jpg
  //https://st2.depositphotos.com/3840453/7446/i/600/depositphotos_74466141-stock-photo-laptop-on-table-on-office.jpg

  List<Product> _items = [];
  bool _showFavoriteOnly = false;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  void showFavoriteOnly() {
    _showFavoriteOnly = true;
    notifyListeners();
  }

  void showAll() {
    _showFavoriteOnly = false;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    var response = await http.get(Uri.parse('$_baseUrl/products.json'));
    Map<String, dynamic>? productList = jsonDecode(response.body);

    if (productList != null) {
      _items = productList.entries.map((entry) {
        return Product(
            id: entry.key,
            title: entry.value["title"],
            description: entry.value["description"],
            price: entry.value["price"],
            imageUrl: entry.value["imageUrl"]);
      }).toList();
      notifyListeners();
    }
  }

  Future<void> addProduct(Product product) {
    final future = http.post(Uri.parse('$_baseUrl/products.json'),
        body: jsonEncode({
          "title": product.title,
          "description": product.description,
          "price": product.price,
          "imageUrl": product.imageUrl,
          "isFavorite": product.isFavorite,
        }));
    return future.then((response) {
      //print('espera a requisição acontecer');
      print(jsonDecode(response.body));
      final id = jsonDecode(response.body)['name'];
      print(response.statusCode);
      _items.add(Product(
          id: id,
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl));
      notifyListeners();
    });
    // print('executa em sequencia');
  }

  Future<void> saveProduct(Map<String, Object> data) {
    bool hasId = data['id'] != null;

    final product = Product(
      id: hasId ? data['id'] as String : Random().nextDouble().toString(),
      title: data['name'] as String,
      description: data['description'] as String,
      price: data['price'] as double,
      imageUrl: data['imageUrl'] as String,
    );

    if (hasId) {
      return updateProduct(product);
    } else {
      return addProduct(product);
    }
  }

  Future<void> updateProduct(Product product) {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      _items[index] = product;
      notifyListeners();
    }
    return Future.value();
  }

  void removeProduct(Product product) {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      _items.removeWhere((p) => p.id == product.id);
      notifyListeners();
    }
  }

  Future<List<String>> loadFavoriteProducts(UserAccount user) async {
    var response =
        await http.get(Uri.parse('$_baseUrl/users/${user.id}/favorites.json'));
    List<dynamic>? favorites = jsonDecode(response.body);
    if (favorites != null) {
      List<String> safeFavorites = favorites
          .where((favorite) => favorite != null)
          .cast<String>()
          .toList();
      return safeFavorites;
    }

    return [];
  }
}
