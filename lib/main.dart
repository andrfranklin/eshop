import 'package:f05_eshop/model/shopping_cart.dart';
import 'package:f05_eshop/model/user.dart';
import 'package:f05_eshop/pages/product_detail_page.dart';
import 'package:f05_eshop/pages/product_form_page.dart';
import 'package:f05_eshop/pages/products_overview_page.dart';
import 'package:f05_eshop/pages/user_sign_in.dart';
import 'package:f05_eshop/pages/user_sign_up.dart';
import 'package:f05_eshop/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'model/product_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final ProductList productListProvider = ProductList();
  await productListProvider.loadProducts();
  runApp(
    ChangeNotifierProvider(
      create: (context) => productListProvider,
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final ProductList productListProvider = ProductList();
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ShoppingCart()),
        ChangeNotifierProvider(
            create: (context) =>
                UserAccountProvider(productList: productListProvider)),
      ],
      child: MaterialApp(
        title: 'Minha Loja',
        theme: ThemeData(
            fontFamily: 'Lato',
            //primarySwatch: Colors.pink,
            colorScheme: ThemeData().copyWith().colorScheme.copyWith(
                primary: Colors.pink, secondary: Colors.orangeAccent)),
        home: ProductsOverviewPage(),
        routes: {
          AppRoutes.PRODUCT_DETAIL: (ctx) => ProductDetailPage(),
          AppRoutes.PRODUCT_FORM: (context) => ProductFormPage(),
          AppRoutes.USER_SIGN_UP_FORM: (context) => UserSignUpPage(),
          AppRoutes.USER_SIGN_IN_FORM: (context) => UserSignInPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
