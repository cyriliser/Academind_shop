import 'package:flutter/cupertino.dart';

class ProductProvider with ChangeNotifier {
  final String id;
  final String description;
  final String title;
  final String imageUrl;
  final double price;
  bool isFavourite;
  ProductProvider({
    required this.id,
    required this.description,
    required this.title,
    required this.imageUrl,
    required this.price,
    this.isFavourite = false,
  });

  void toggleFavouriteStatus() {
    isFavourite = !isFavourite;
    notifyListeners();
  }
}
