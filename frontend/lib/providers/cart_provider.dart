import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});
}

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get subtotal =>
      _items.fold(0, (sum, item) => sum + (item.product.price * item.quantity));

  double get tax => subtotal * 0.1; // example 10% tax
  double get total => subtotal + tax;

  // Add product to cart
  void addToCart(Product product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index != -1) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product, quantity: 1));
    }
    notifyListeners();
  }

  // Clear the cart
  void clearCart() {
    _items.clear();
    notifyListeners();
  }

}
