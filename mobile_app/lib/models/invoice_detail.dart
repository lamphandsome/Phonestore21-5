class InvoiceDetail {
  final String productName;
  final int quantity;
  final double price;
  final String image;

  InvoiceDetail({
    required this.productName,
    required this.quantity,
    required this.price,
    required this.image,
  });

  factory InvoiceDetail.fromJson(Map<String, dynamic> json) {
    return InvoiceDetail(
      productName: json['product']['name'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
      image: json['product']['image'] ?? '',
    );
  }
}
