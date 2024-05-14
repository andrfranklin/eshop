import 'dart:convert';

import 'package:f05_eshop/model/product.dart';
import 'package:f05_eshop/model/product_list.dart';
import 'package:f05_eshop/utils/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserAccount {
  String? id;
  String email;
  String password;

  UserAccount({required this.email, required this.password, this.id});
}

class UserAccountProvider with ChangeNotifier {
  final _baseUrl = ApiData.baseURL;
  UserAccount? _user;
  final ProductList productList;

  UserAccountProvider({required this.productList});

  Future<bool> checkEmailExists(String email) async {
    var response = await http.get(Uri.parse('$_baseUrl/users.json'));
    var userList = jsonDecode(response.body);
    if (userList != null) {
      userList = Map<String, dynamic>.from(userList)
          .map((key, value) => MapEntry(
              key, {'email': value['email'], 'password': value['password']}))
          .values
          .toList();
    } else {
      userList = [];
    }
    return userList.any((user) => user['email'] == email);
  }

  Future<void> registerUser(String email, String password) async {
    if (!await checkEmailExists(email)) {
      await http.post(Uri.parse('$_baseUrl/users.json'),
          body: jsonEncode({"email": email, 'password': password}));
      notifyListeners();
    } else {
      throw Exception("Email already exists!");
    }
  }

  Future<void> login(String email, String password) async {
    var response = await http.get(Uri.parse('$_baseUrl/users.json'));
    Map<String, dynamic>? userResponse = jsonDecode(response.body);

    List<Map<String, dynamic>> userList = [];
    if (userResponse != null) {
      userList = Map<String, dynamic>.from(userResponse)
          .map((key, value) => MapEntry(key, {
                'id': key,
                'email': value['email'],
                'password': value['password']
              }))
          .values
          .toList();
    } else {
      userList = [];
    }

    try {
      var userExist = userList.firstWhere(
          (user) => user['email'] == email && user['password'] == password);
      _user =
          UserAccount(email: email, password: password, id: userExist['id']);
      List<String> favorites = await productList.loadFavoriteProducts(_user!);
      productList.items.forEach((element) {
        if (favorites.contains(element.id)) {
          Product temp = element;
          temp.isFavorite = true;
          productList.updateProduct(temp);
        }
      });
    } catch (e) {
      throw Exception("User not found!");
    }
  }

  Future<void> toggleFavoritesOnAccount(Product product) async {
    if (_user != null) {
      List<String> favorites = await productList.loadFavoriteProducts(_user!);
      if (!favorites.contains(product.id)) {
        await http.put(Uri.parse('$_baseUrl/users/${_user!.id}/favorites.json'),
            body: jsonEncode([...favorites, product.id]));
      } else {
        int index = favorites.indexOf(product.id);

        await http.delete(
            Uri.parse('$_baseUrl/users/${_user!.id}/favorites/$index.json'));
      }
    }
  }

  UserAccount? getUser() {
    return _user;
  }

  void logOut() {
    _user = null;
    notifyListeners();
  }
}
