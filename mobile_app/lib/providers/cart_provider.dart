import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  List<CartItem> _items = [];
  List<CartItem> get items => _items;

  double get totalPrice => _items.fold(0, (sum, item) => sum + item.price * item.quantity);

  Future<void> fetchCart() async {
    _items = await CartService.fetchCartItems();
    notifyListeners();
  }

  Future<void> removeItem(int id) async {
    await CartService.deleteCartItem(id);
    await fetchCart();
  }

  Future<void> increase(int id) async {
    await CartService.increaseItem(id);
    await fetchCart();
  }

  Future<void> decrease(int id) async {
    await CartService.decreaseItem(id);
    await fetchCart();
  }
}