import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/invoice.dart';
import '../models/invoice_detail.dart';

class InvoiceService {
  static const baseUrl = 'http://10.0.2.2:8080/api';

  static Future<bool> createInvoice(int addressId) async {
    final res = await http.post(Uri.parse('$baseUrl/invoice/user/create?idAddress=$addressId'));
    return res.statusCode == 200 || res.statusCode == 201;
  }

  static Future<List<Invoice>> fetchInvoices() async {
    final res = await http.get(Uri.parse('$baseUrl/invoice/user'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => Invoice.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi lấy danh sách hóa đơn');
    }
  }

  static Future<List<InvoiceDetail>> fetchInvoiceDetails(int invoiceId) async {
    final res = await http.get(Uri.parse('$baseUrl/invoice-detail/user?idInvoice=$invoiceId'));
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as List;
      return data.map((e) => InvoiceDetail.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi lấy chi tiết hóa đơn');
    }
  }
}
