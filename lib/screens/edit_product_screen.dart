import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shop/providers/products_provider.dart';
import '../providers/product_provider.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  const EditProductScreen({Key? key}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();
  final _form = GlobalKey<FormState>();
  var _editedProduct = ProductProvider(
    id: '',
    description: '',
    imageUrl: '',
    price: 0,
    title: '',
    isFavourite: false,
  );
  var _isInit = true;
  var _isLoading = false;
  var _initValues = {
    'title': '',
    'description': '',
    'price': 0,
    'imageUrl': '',
  };

  @override
  void dispose() {
    _imageUrlController.dispose();
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isInit = false;
      final productId = ModalRoute.of(context)!.settings.arguments;
      if (productId != null) {
        _editedProduct = Provider.of<ProductsProvider>(context, listen: false)
            .findById(productId as String);
        _initValues = {
          'title': _editedProduct.title,
          'description': _editedProduct.description,
          'price': _editedProduct.price.toString(),
          'imageUrl': '',
        };
        _imageUrlController.text = _editedProduct.imageUrl;
      }
    }
    super.didChangeDependencies();
  }

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    var isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_editedProduct.id.isEmpty) {
      try {
        await Provider.of<ProductsProvider>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (e) {
        await showDialog(
          context: context,
          builder: (ctx) {
            return AlertDialog(
              title: Text('An Error Ocured!'),
              content: Text('Something went wrong'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                  child: Text('Close'),
                )
              ],
            );
          },
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop();
      }
    } else {
      await Provider.of<ProductsProvider>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
      Navigator.of(context).pop();
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
        actions: [IconButton(onPressed: _saveForm, icon: Icon(Icons.save))],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Form(
              key: _form,
              child: ListView(
                padding: EdgeInsets.all(16),
                children: [
                  TextFormField(
                    initialValue: _initValues['title'] as String,
                    decoration: InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onSaved: (value) => _editedProduct = ProductProvider(
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                      description: _editedProduct.description,
                      title: (value != null) ? value : '',
                      imageUrl: _editedProduct.imageUrl,
                      price: _editedProduct.price,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide a value.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['price'].toString(),
                    decoration: InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    onSaved: (value) => _editedProduct = ProductProvider(
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                      description: _editedProduct.description,
                      title: _editedProduct.title,
                      imageUrl: _editedProduct.imageUrl,
                      price: (value != null) ? double.parse(value) : 0.0,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide a price.';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number.';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter a number grater tha 0.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    initialValue: _initValues['description'] as String,
                    decoration: InputDecoration(labelText: 'Description'),
                    // textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.multiline,
                    maxLines: 3,
                    onSaved: (value) => _editedProduct = ProductProvider(
                      id: _editedProduct.id,
                      isFavourite: _editedProduct.isFavourite,
                      description: (value != null) ? value : '',
                      title: _editedProduct.title,
                      imageUrl: _editedProduct.imageUrl,
                      price: _editedProduct.price,
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please provide a description.';
                      }
                      return null;
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: EdgeInsets.only(top: 8, right: 10),
                        decoration: BoxDecoration(
                          border: Border.all(
                            width: 1,
                            color: Colors.grey,
                          ),
                        ),
                        child: _imageUrlController.text.isEmpty
                            ? Text('Enter a URL')
                            : FittedBox(
                                fit: BoxFit.cover,
                                child: Image.network(_imageUrlController.text)),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration: InputDecoration(labelText: 'Image URL'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          onEditingComplete: () {
                            setState(() {});
                          },
                          focusNode: _imageUrlFocusNode,
                          onSaved: (value) => _editedProduct = ProductProvider(
                            id: _editedProduct.id,
                            isFavourite: _editedProduct.isFavourite,
                            description: _editedProduct.description,
                            title: _editedProduct.title,
                            imageUrl: (value != null) ? value : '',
                            price: _editedProduct.price,
                          ),
                          onFieldSubmitted: (_) {
                            _saveForm();
                          },
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please provide an image url.';
                            }
                            if (!value.startsWith('https') &&
                                !value.startsWith('http')) {
                              return 'Please enter a valid url.';
                            }

                            return null;
                          },
                        ),
                      )
                    ],
                  ),
                  // Expanded(
                  //   child: TextFormField(
                  //     decoration: InputDecoration(labelText: 'Image URL'),
                  //     keyboardType: TextInputType.url,
                  //     textInputAction: TextInputAction.done,
                  //     controller: _imageUrlController,
                  //     onEditingComplete: () {
                  //       setState(() {});
                  //     },
                  //   )
                  // )
                ],
              )),
    );
  }
}
