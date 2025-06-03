import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import 'order_success_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final double totalAmount;
  final List<dynamic> products;

  const CheckoutScreen({super.key, required this.totalAmount, required this.products});

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Tổng tiền: \$${totalAmount.toStringAsFixed(2)}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final payUrl = await orderProvider.payWithMomo(totalAmount);
                await orderProvider.addOrder(products, totalAmount, 'Momo');
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const OrderSuccessScreen()),
                );
              },
              child: const Text('Thanh toán với Momo'),
            )
          ],
        ),
      ),
    );
  }
}
