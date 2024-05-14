import 'package:f05_eshop/model/shopping_cart.dart';
import 'package:f05_eshop/model/user.dart';
import 'package:f05_eshop/pages/products_overview_page.dart';
import 'package:f05_eshop/utils/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../model/product.dart';

class ProductItem extends StatelessWidget {
  final FilterShowOptions whatShow;

  const ProductItem({super.key, required this.whatShow});
  @override
  Widget build(BuildContext context) {
    //PEGANDO CONTEUDO PELO PROVIDER
    //
    final product = Provider.of<Product>(
      context,
    );

    final myCartProvider = Provider.of<ShoppingCart>(context);
    final userAccountProvider = Provider.of<UserAccountProvider>(context);

    //final product = context.watch<Product>();

    var isFavorite =
        context.select<Product, bool>((produto) => produto.isFavorite);

    return ClipRRect(
      //corta de forma arredondada o elemento de acordo com o BorderRaius
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        footer: GridTileBar(
          backgroundColor: Colors.black87,
          leading: whatShow != FilterShowOptions.Cart
              ? IconButton(
                  onPressed: () {
                    //adicionando metodo ao clique do botão
                    product.toggleFavorite();
                    userAccountProvider.toggleFavoritesOnAccount(product);
                  },
                  //icon: Icon(Icons.favorite),
                  //pegando icone se for favorito ou não
                  icon: Consumer<Product>(
                    builder: (context, product, child) {
                      print(product.isFavorite);
                      return Icon(
                        product.isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                      );
                    },
                  ),
                  //isFavorite ? Icons.favorite : Icons.favorite_border),
                  color: Theme.of(context).colorScheme.secondary,
                )
              : null,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: whatShow == FilterShowOptions.Cart
              ? Row(
                  children: <Widget>[
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        myCartProvider.decreaseQuantity(product);
                      },
                    ),
                    Text('${myCartProvider.getQuantity(product)}',
                        style: const TextStyle(color: Colors.white)),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        myCartProvider.increaseQuantity(product);
                      },
                    ),
                  ],
                )
              : IconButton(
                  onPressed: () {
                    if (userAccountProvider.getUser() == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Faça login para continuar')));
                      return;
                    }
                    myCartProvider.toggleProduct(product);
                  },
                  icon: Consumer<Product>(
                    builder: (context, product, child) => Icon(
                        myCartProvider.existsInItems(product)
                            ? Icons.shopping_cart
                            : Icons.shopping_cart_outlined),
                  ),
                  color: Theme.of(context).colorScheme.secondary),
        ),
        header: whatShow == FilterShowOptions.Cart
            ? Row(
                children: <Widget>[
                  Expanded(
                      child: Text('R\S ${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(shadows: [
                            Shadow(color: Colors.white, blurRadius: 1)
                          ]))),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      fixedSize: const Size(10,
                          10), // Ajuste para centralizar o ícone, considerando um tamanho maior
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: EdgeInsets
                          .zero, // Remova qualquer padding para centralizar o ícone
                    ),
                    onPressed: () {
                      myCartProvider.removeProduct(product);
                    },
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.grey,
                    ),
                  ),
                ],
              )
            : Container(),
        child: GestureDetector(
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
          onTap: () {
            Navigator.of(context)
                .pushNamed(AppRoutes.PRODUCT_DETAIL, arguments: product);
          },
        ),
      ),
    );
  }
}
