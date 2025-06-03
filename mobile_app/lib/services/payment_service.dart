import 'package:http/http.dart' as http;
import 'dart:convert';

class PaymentService {
  Future<String> createMomoPayment(double amount) async {
    final response = await http.post(
      Uri.parse('http://localhost:8080/api/momo/create-payment'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amount,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['payUrl'];
    } else {
      throw Exception('Failed to initiate Momo payment');
    }
  }
}