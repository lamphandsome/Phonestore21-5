import 'package:flutter/material.dart';

class OrderSuccessScreen extends StatelessWidget {
  const OrderSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thành công')),
      body: const Center(
        child: Text('Đơn hàng đã được tạo và thanh toán thành công!'),
      ),
    );
  }
}