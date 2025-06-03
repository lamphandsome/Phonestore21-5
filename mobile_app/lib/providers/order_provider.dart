import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/payment_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OrderProvider with ChangeNotifier {
  final List<Order> _orders = [];
  final PaymentService _paymentService = PaymentService();

  List<Order> get orders => [..._orders];

  Future<void> addOrder(List<dynamic> products, double totalAmount, String paymentMethod) async {
    final now = DateTime.now();
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/invoice'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'products': products,
        'totalAmount': totalAmount,
        'createdAt': now.toIso8601String(),
        'paymentStatus': 'Pending',
        'paymentMethod': paymentMethod,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final newOrder = Order.fromJson(data);
      _orders.add(newOrder);
      notifyListeners();
    } else {
      throw Exception('Failed to create order');
    }
  }

  Future<String> payWithMomo(double amount) async {
    return await _paymentService.createMomoPayment(amount);
  }
}