import 'package:f05_eshop/components/product_item.dart';
import 'package:f05_eshop/model/shopping_cart.dart';
import 'package:f05_eshop/pages/products_overview_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/product.dart';
import '../model/product_list.dart';

class ProductGrid extends StatelessWidget {
  final FilterShowOptions _whatShow;
  ProductGrid(this._whatShow);
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductList>(context);
    final myCartProvider = Provider.of<ShoppingCart>(context);

    final List<Product> loadedProducts = _whatShow == FilterShowOptions.Favorite
        ? provider.favoriteItems
        : _whatShow == FilterShowOptions.All
            ? provider.items
            : _whatShow == FilterShowOptions.Cart
                ? myCartProvider.items
                : [];

    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: loadedProducts.length,
      //# ProductItem vai receber a partir do Provider
      itemBuilder: (ctx, i) => ChangeNotifierProvider.value(
        //create: (ctx) => Product(),
        value: loadedProducts[i],
        //child: ProductItem(product: loadedProducts[i]),
        child: ProductItem(
          whatShow: _whatShow,
        ),
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //2 produtos por linha
        childAspectRatio: 3 / 2, //diemnsao de cada elemento
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
    );
  }
}
