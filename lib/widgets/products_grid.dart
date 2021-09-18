import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products_provider.dart';
import 'package:shop/widgets/product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool showOnlyFavourites;
  ProductsGrid(this.showOnlyFavourites);

  @override
  Widget build(BuildContext context) {
    final loadedProducts = showOnlyFavourites
        ? Provider.of<ProductsProvider>(context).favouriteItems
        : Provider.of<ProductsProvider>(context).items;

    return GridView.builder(
      padding: EdgeInsets.all(10),
      itemCount: loadedProducts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10),
      itemBuilder: (ctx, i) {
        return ChangeNotifierProvider.value(
          value: loadedProducts[i],
          child: ProductItem(),
        );
      },
    );
  }
}
