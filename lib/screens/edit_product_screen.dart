import 'package:flutter/material.dart';
import 'package:my_app/providers/products.dart';
import 'package:provider/provider.dart';

class EditProductScreen extends StatefulWidget {
  const EditProductScreen({Key? key}) : super(key: key);
  static const String routeName = '/edit_product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _descriptionFocusNode = FocusNode();
  final _imageUrlFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _form = GlobalKey<FormState>();
  ProductItem _editedProduct =
      ProductItem(id: "", title: "", description: "", price: 0.0, imageUrl: "");
  bool _isInit = true;
  bool _isEdit = true;
  bool _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      Object? args = ModalRoute.of(context)?.settings.arguments;
      if (args == null) {
        _isEdit = false;
        return;
      }
      final String productId = args as String;
      // final String productId = settings.arguments as String;
      _editedProduct = Provider.of<Products>(context).findById(productId);
      _imageUrlController.text = _editedProduct.imageUrl;
      _isInit = false;
    }
    super.didChangeDependencies();
  }

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {});
    }
  }

  Future<void> _saveForm() async {
    final isValidated = _form.currentState!.validate();
    if (!isValidated) {
      return;
    }
    _form.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    if (_isEdit) {
      await Provider.of<Products>(context, listen: false)
          .editProduct(_editedProduct);
    } else {
      try {
        await Provider.of<Products>(context, listen: false)
            .addProduct(_editedProduct);
      } catch (error) {
        await showDialog<Null>(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: const Text('An error occured'),
                  content: Text(error.toString()),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('OK'))
                  ],
                ));
      }
    }
    setState(() {
      _isLoading = false;
    });
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Product'),
        actions: [
          IconButton(onPressed: _saveForm, icon: const Icon(Icons.save))
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Form(
                key: _form,
                child: ListView(children: [
                  TextFormField(
                    initialValue: _editedProduct.title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    textInputAction: TextInputAction.next,
                    onFieldSubmitted: ((value) {
                      FocusScope.of(context).requestFocus(_priceFocusNode);
                    }),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Must enter title";
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _editedProduct.title = newValue ?? "";
                    },
                  ),
                  TextFormField(
                    initialValue: _editedProduct.price.toString(),
                    decoration: const InputDecoration(labelText: 'Price'),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                    focusNode: _priceFocusNode,
                    onFieldSubmitted: ((value) {
                      FocusScope.of(context)
                          .requestFocus(_descriptionFocusNode);
                    }),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Must enter price";
                      }
                      double? v = double.tryParse(value);
                      if (v == null || v < 0) {
                        return "Invalid input";
                      }
                      return null;
                    },
                    onSaved: (newValue) {
                      _editedProduct.price =
                          newValue == null ? 0.0 : double.parse(newValue);
                    },
                  ),
                  TextFormField(
                    initialValue: _editedProduct.description,
                    decoration: const InputDecoration(labelText: 'Description'),
                    maxLines: 3,
                    keyboardType: TextInputType.multiline,
                    focusNode: _descriptionFocusNode,
                    onSaved: (newValue) {
                      _editedProduct.description = newValue ?? "";
                    },
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        margin: const EdgeInsets.only(top: 8, right: 10),
                        decoration: BoxDecoration(
                            border: Border.all(width: 1, color: Colors.grey)),
                        child: Container(
                          child: _imageUrlController.text.isEmpty
                              ? Text('Enter a URL')
                              : FittedBox(
                                  fit: BoxFit.contain,
                                  child:
                                      Image.network(_imageUrlController.text),
                                ),
                        ),
                      ),
                      Expanded(
                        child: TextFormField(
                          decoration:
                              const InputDecoration(labelText: 'Image URL'),
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocusNode,
                          onFieldSubmitted: ((value) {
                            setState(() {});
                            _saveForm();
                          }),
                          onSaved: (newValue) {
                            _editedProduct.imageUrl = newValue ?? "";
                          },
                        ),
                      ),
                    ],
                  ),
                ]),
              ),
            ),
    );
  }
}
