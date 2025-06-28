import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
      imageUrl:
          (doc.data() != null &&
                  (doc.data() as Map<String, dynamic>).containsKey('imageUrl'))
              ? doc['imageUrl']
              : 'https://nbwjmjcsysehkhfwhqcz.supabase.co/storage/v1/object/public/img//load_image.jpg',
    );
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class Cart extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount {
    double total = 0;
    for (var item in _items) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  void addItem(Product product) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );
    if (existingItemIndex != -1) {

      _items[existingItemIndex].quantity++;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void increaseItemQuantity(String productId) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == productId,
    );
    if (existingItemIndex != -1) {
      _items[existingItemIndex].quantity++;
      notifyListeners();
    }
  }

  void decreaseItemQuantity(String productId) {
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == productId,
    );
    if (existingItemIndex != -1) {
      if (_items[existingItemIndex].quantity > 1) {
        _items[existingItemIndex].quantity--;
      } else {
        removeItem(productId);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  final ValueNotifier<int> _itemCountNotifier = ValueNotifier<int>(0);

  ValueNotifier<int> get itemCountNotifier => _itemCountNotifier;

  void _updateItemCount() {
    _itemCountNotifier.value = items.length;
  }

  @override
  void notifyListeners() {
    _updateItemCount();
    super.notifyListeners();
  }
}
