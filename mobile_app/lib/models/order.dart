class Order {
  final int id;
  final List<dynamic> products;
  final double totalAmount;
  final DateTime createdAt;
  final String paymentStatus;
  final String paymentMethod;

  Order({
    required this.id,
    required this.products,
    required this.totalAmount,
    required this.createdAt,
    required this.paymentStatus,
    required this.paymentMethod,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      products: json['products'],
      totalAmount: json['totalAmount'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
      paymentStatus: json['paymentStatus'],
      paymentMethod: json['paymentMethod'],
    );
  }
}