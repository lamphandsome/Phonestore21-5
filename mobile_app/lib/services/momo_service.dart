import 'dart:convert';
import 'package:http/http.dart' as http;

class MomoService {
  static const String momoUrl = 'http://<your_backend_ip>:8080/api/urlpayment';

  static Future<String> createPaymentUrl({
    required String returnUrl,
    required String notifyUrl,
    required int shipCost,
    String? voucherCode,
  }) async {
    final data = {
      'returnUrl': returnUrl,
      'notifyUrl': notifyUrl,
      'shipCost': shipCost,
      'codeVoucher': voucherCode,
    };

    final response = await http.post(
      Uri.parse(momoUrl),
      body: jsonEncode(data),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return jsonData['payUrl'] ?? '';
    } else {
      throw Exception('MoMo payment failed');
    }
  }
}
