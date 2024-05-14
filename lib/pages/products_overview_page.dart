import 'package:f05_eshop/model/product_list.dart';
import 'package:f05_eshop/model/shopping_cart.dart';
import 'package:f05_eshop/model/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/product_grid.dart';
import '../utils/app_routes.dart';

enum FilterShowOptions {
  Favorite,
  All,
  Cart,
  UserSignUp,
  UserSignIn,
  UserSignOut
}

class ProductsOverviewPage extends StatefulWidget {
  ProductsOverviewPage({Key? key}) : super(key: key);

  @override
  State<ProductsOverviewPage> createState() => _ProductsOverviewPageState();
}

class _ProductsOverviewPageState extends State<ProductsOverviewPage> {
  FilterShowOptions _whatShow = FilterShowOptions.All;
  @override
  Widget build(BuildContext context) {
    final myCartProvider = Provider.of<ShoppingCart>(context);
    final userAccountProvider = Provider.of<UserAccountProvider>(context);

    //final provider = Provider.of<ProductList>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Minha Loja'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              setState(() {
                _whatShow = FilterShowOptions.Cart;
              });
            },
          ),
          IconButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.PRODUCT_FORM,
                );
              },
              icon: const Icon(Icons.add)),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: FilterShowOptions.Favorite,
                child: Text('Somente Favoritos'),
              ),
              const PopupMenuItem(
                value: FilterShowOptions.All,
                child: Text('Todos'),
              ),
              if (userAccountProvider.getUser() == null)
                const PopupMenuItem(
                  value: FilterShowOptions.UserSignUp,
                  child: Text('Cadastro de usuário'),
                ),
              if (userAccountProvider.getUser() == null)
                const PopupMenuItem(
                  value: FilterShowOptions.UserSignIn,
                  child: Text('Login'),
                ),
              if (userAccountProvider.getUser() != null)
                const PopupMenuItem(
                  value: FilterShowOptions.UserSignOut,
                  child: Text('Sair'),
                ),
            ],
            onSelected: (FilterShowOptions selectedValue) {
              if (selectedValue == FilterShowOptions.UserSignUp) {
                Navigator.of(context).pushNamed(
                  AppRoutes.USER_SIGN_UP_FORM,
                );
              }

              if (selectedValue == FilterShowOptions.UserSignIn) {
                Navigator.of(context).pushNamed(
                  AppRoutes.USER_SIGN_IN_FORM,
                );
              }

              if (selectedValue == FilterShowOptions.UserSignOut) {
                userAccountProvider.logOut();
                myCartProvider.clearItems();
              }

              setState(() {
                if (selectedValue == FilterShowOptions.Favorite) {
                  //provider.showFavoriteOnly();
                  _whatShow = FilterShowOptions.Favorite;
                } else {
                  //provider.showAll();
                  _whatShow = FilterShowOptions.All;
                }
              });
            },
          ),
        ],
      ),
      body: ProductGrid(_whatShow),
      bottomNavigationBar: _whatShow == FilterShowOptions.Cart
          ? BottomAppBar(
              child: Container(
                height: 50.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                          'Total: R\$ ${myCartProvider.totalCart().toStringAsFixed(2)}'),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: ElevatedButton(
                        onPressed: () {
                          try {
                            myCartProvider.shop(userAccountProvider.getUser()!);
                            setState(() {
                              _whatShow = FilterShowOptions.All;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Operação realizada com sucesso!'),
                              ),
                            );
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Ops! Algo deu errado'),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red, // White text color
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(8.0), // Rounded borders
                          ),
                        ),
                        child: Text('Comprar'),
                      ),
                    )
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
