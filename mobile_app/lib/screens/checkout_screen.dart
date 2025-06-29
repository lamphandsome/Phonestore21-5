import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/cart_provider.dart';
import '../services/invoice_service.dart';
import '../services/momo_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String selectedMethod = 'cod';
  final int fakeAddressId = 1;
  bool isPlacingOrder = false;

  void _placeOrder() async {
    setState(() => isPlacingOrder = true);
    final total = Provider.of<CartProvider>(context, listen: false).totalPrice;

    if (selectedMethod == 'cod') {
      final success = await InvoiceService.createInvoice(fakeAddressId);
      _showSnackBar(success ? 'Đặt hàng thành công (COD)' : 'Đặt hàng thất bại!');
      if (success) Navigator.pop(context);
    } else {
      try {
        final momoUrl = await MomoService.createPaymentUrl(
          returnUrl: 'https://yourapp.com/momo-return',
          notifyUrl: 'https://yourapp.com/momo-notify',
          shipCost: 20000,
        );
        if (await canLaunchUrl(Uri.parse(momoUrl))) {
          await launchUrl(Uri.parse(momoUrl), mode: LaunchMode.externalApplication);
        } else {
          _showSnackBar('Không mở được MoMo');
        }
      } catch (e) {
        _showSnackBar('Lỗi thanh toán MoMo');
      }
    }

    setState(() => isPlacingOrder = false);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final total = cart.totalPrice;

    return Scaffold(
      appBar: AppBar(title: const Text('Xác nhận thanh toán')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Địa chỉ nhận hàng', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            const Text('123 Nguyễn Văn Cừ, Hà Nội (ID: 1)'),
            const SizedBox(height: 20),
            const Text('Phương thức thanh toán', style: TextStyle(fontWeight: FontWeight.bold)),
            RadioListTile(value: 'cod', groupValue: selectedMethod, onChanged: (val) => setState(() => selectedMethod = val!), title: const Text('COD')),
            RadioListTile(value: 'momo', groupValue: selectedMethod, onChanged: (val) => setState(() => selectedMethod = val!), title: const Text('MoMo')),
            const SizedBox(height: 20),
            Text('Tổng tiền: ${total.toStringAsFixed(0)} đ', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isPlacingOrder ? null : _placeOrder,
                child: isPlacingOrder
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Xác nhận đặt hàng'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
