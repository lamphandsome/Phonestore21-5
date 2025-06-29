import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/cart_item.dart';

class CartService {
  static const String baseUrl = 'http://<your_backend_ip>:8080/api/cart/user';

  static Future<List<CartItem>> fetchCartItems() async {
    final res = await http.get(Uri.parse('$baseUrl/my-cart'));
    if (res.statusCode == 200) {
      final List<dynamic> jsonData = json.decode(res.body);
      return jsonData.map((item) => CartItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to fetch cart items');
    }
  }

  static Future<void> deleteCartItem(int id) async {
    await http.delete(Uri.parse('$baseUrl/delete?id=$id'));
  }

  static Future<void> increaseItem(int id) async {
    await http.get(Uri.parse('$baseUrl/up-cart?id=$id'));
  }

  static Future<void> decreaseItem(int id) async {
    await http.get(Uri.parse('$baseUrl/down-cart?id=$id'));
  }
}
