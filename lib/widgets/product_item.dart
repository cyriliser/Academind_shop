import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/cart_provider.dart';
import 'package:shop/providers/product_provider.dart';
import 'package:shop/screens/product_detail_screen.dart';

class ProductItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    return Consumer<ProductProvider>(
      builder: (ctx, product, child) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: GridTile(
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                    arguments: product.id);
              },
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
              ),
            ),
            footer: GridTileBar(
              backgroundColor: Colors.black87,
              leading: IconButton(
                  onPressed: () {
                    product.toggleFavouriteStatus();
                  },
                  color: Theme.of(context).colorScheme.secondary,
                  icon: Icon(
                    product.isFavourite
                        ? Icons.favorite
                        : Icons.favorite_border,
                  )),
              trailing: IconButton(
                color: Theme.of(context).colorScheme.secondary,
                icon: Icon(
                  Icons.shopping_cart,
                ),
                onPressed: () {
                  cart.addItem(product.id, product.price, product.title);
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added item to cart',
                      ),
                      duration: Duration(seconds: 2),
                      action: SnackBarAction(
                        label: 'UNDO',
                        onPressed: () {
                          cart.removeSingleItem(product.id);
                        },
                      ),
                    ),
                  );
                },
              ),
              title: Text(
                product.title,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
    );
  }
}
