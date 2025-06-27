import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String description;
  final String imageUrl; 

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.imageUrl, 
  });

  factory Product.fromDocument(DocumentSnapshot doc) {
  return Product(
    id: doc.id,
    name: doc['name'] ?? 'No Name',
    price: (doc['price'] ?? 0).toDouble(),
    description: doc['description'] ?? 'No description available',
    imageUrl: (doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('imageUrl'))
        ? doc['imageUrl']
        : 'https://nbwjmjcsysehkhfwhqcz.supabase.co/storage/v1/object/public/img//load_image.jpg', 
  );
}
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class Cart with ChangeNotifier {
  final List<CartItem> _items = [];
  final ValueNotifier<int> itemCountNotifier = ValueNotifier<int>(0);

  List<CartItem> get items => _items;

  void addItem(Product product) {
    final existingItem = _items.firstWhere(
      (item) => item.product.id == product.id,
      orElse: () => CartItem(product: product, quantity: 0),
    );

    if (existingItem.quantity > 0) {
      existingItem.quantity++;
    } else {
      _items.add(CartItem(product: product));
    }
    itemCountNotifier.value = _items.length; 
    notifyListeners();
  }

  double get totalAmount {
    // ignore: avoid_types_as_parameter_names
    return _items.fold(0.0, (sum, item) => sum + (item.product.price * item.quantity));
  }

  void clear() {
    _items.clear();
    itemCountNotifier.value = 0;
    notifyListeners();
  }
}