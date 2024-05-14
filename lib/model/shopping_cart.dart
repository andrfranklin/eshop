import 'dart:convert';
import 'dart:math';

import 'package:f05_eshop/model/product.dart';
import 'package:f05_eshop/model/user.dart';
import 'package:f05_eshop/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartProduct extends Product {
  int quantity = 1;

  CartProduct(Product product)
      : super(
            id: product.id,
            title: product.title,
            description: product.description,
            price: product.price,
            imageUrl: product.imageUrl,
            isFavorite: product.isFavorite);

  void addQuantity(int amount) {
    quantity += amount;
  }

  void subtractQuantity(int amount) {
    if (quantity - amount >= 0) {
      quantity -= amount;
    }
  }
}

class ShoppingCart with ChangeNotifier {
  final baseUrl = ApiData.baseURL;

  List<CartProduct> _items = [];

  List<CartProduct> get items {
    return [..._items];
  }

  bool existsInItems(Product product) {
    return _items.any((element) => element.id == product.id);
  }

  void toggleProduct(Product product) {
    // await http.post(Uri.parse('$_baseUrl/shopping_cart.json'),
    //     body: jsonEncode({
    //       "title": product.title,
    //       "description": product.description,
    //       "price": product.price,
    //       "imageUrl": product.imageUrl,
    //       "isFavorite": product.isFavorite,
    //     }));
    if (existsInItems(product)) {
      _items.removeWhere((element) => element.id == product.id);
    } else {
      _items.add(CartProduct(product));
    }
    notifyListeners();
  }

  // Future<void> saveProduct(Map<String, Object> data) {
  //   bool hasId = data['id'] != null;

  //   final product = Product(
  //     id: hasId ? data['id'] as String : Random().nextDouble().toString(),
  //     title: data['name'] as String,
  //     description: data['description'] as String,
  //     price: data['price'] as double,
  //     imageUrl: data['imageUrl'] as String,
  //   );

  //   if (hasId) {
  //     return updateProduct(product);
  //   } else {
  //     return addProduct(product);
  //   }
  // }

  void removeProduct(Product product) {
    int index = _items.indexWhere((p) => p.id == product.id);

    if (index >= 0) {
      _items.removeWhere((p) => p.id == product.id);
      notifyListeners();
    }
  }

  double totalCart() {
    double total = 0.0;
    _items.forEach((element) {
      total += element.price * element.quantity;
    });
    return total;
  }

  void decreaseQuantity(Product product) {
    CartProduct cp = _items.firstWhere((element) => element.id == product.id);

    cp.subtractQuantity(1);
    if (cp.quantity == 0) {
      removeProduct(cp);
    } else {
      notifyListeners();
    }
  }

  void increaseQuantity(Product product) {
    _items.firstWhere((element) => element.id == product.id).addQuantity(1);
    notifyListeners();
  }

  int getQuantity(Product product) {
    return _items.firstWhere((element) => element.id == product.id).quantity;
  }

  void clearItems() {
    _items.clear();
    notifyListeners();
  }

  Future<void> shop(UserAccount user) async {
    final url = '$baseUrl/users/${user.id}/cart.json';
    final response = await http.put(
      Uri.parse(url),
      body: jsonEncode(
        items
            .map((item) => {
                  'id': item.id,
                  'title': item.title,
                  'description': item.description,
                  'price': item.price,
                  'imageUrl': item.imageUrl,
                  'isFavorite': item.isFavorite,
                  'quantity': item.quantity,
                })
            .toList(),
      ),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save items');
    }

    items.clear();
    notifyListeners();
  }
}
