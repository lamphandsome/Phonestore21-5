import 'package:flutter/material.dart';
import '../models/invoice.dart';
import '../services/invoice_service.dart';
import 'order_detail_screen.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});
  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  late Future<List<Invoice>> _futureOrders;

  @override
  void initState() {
    super.initState();
    _futureOrders = InvoiceService.fetchInvoices();
  }

  String getStatusText(String status) {
    switch (status) {
      case 'PENDING': return 'Đang xử lý';
      case 'SHIPPED': return 'Đã giao';
      case 'CANCELLED': return 'Đã huỷ';
      default: return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng của tôi')),
      body: FutureBuilder<List<Invoice>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return const Center(child: Text('Lỗi tải đơn hàng'));

          final orders = snapshot.data!;
          if (orders.isEmpty) return const Center(child: Text('Bạn chưa có đơn nào.'));

          return ListView.separated(
            itemCount: orders.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final order = orders[index];
              return ListTile(
                title: Text('Mã đơn: ${order.id}'),
                subtitle: Text('Ngày: ${order.createDate} - ${getStatusText(order.status)}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(invoiceId: order.id),
                )),
              );
            },
          );
        },
      ),
    );
  }
}
