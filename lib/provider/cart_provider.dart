import 'package:app_uas/provider/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

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
