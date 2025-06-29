import 'package:flutter/material.dart';
import '../models/invoice_detail.dart';
import '../services/invoice_service.dart';

class OrderDetailScreen extends StatelessWidget {
  final int invoiceId;
  const OrderDetailScreen({super.key, required this.invoiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chi tiết đơn #$invoiceId')),
      body: FutureBuilder<List<InvoiceDetail>>(
        future: InvoiceService.fetchInvoiceDetails(invoiceId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Không thể tải chi tiết đơn'));

          final details = snapshot.data!;
          if (details.isEmpty) return const Center(child: Text('Đơn hàng không có sản phẩm'));

          return ListView.separated(
            itemCount: details.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final item = details[index];
              return ListTile(
                leading: Image.network(item.image, width: 60, height: 60, fit: BoxFit.cover),
                title: Text(item.productName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Số lượng: ${item.quantity}'),
                    Text('Đơn giá: ${item.price.toStringAsFixed(0)} đ'),
                    Text('Tổng: ${(item.price * item.quantity).toStringAsFixed(0)} đ'),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
