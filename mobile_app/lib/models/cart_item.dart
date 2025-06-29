class CartItem {
  final int id;
  final String productName;
  final String imageUrl;
  final double price;
  int quantity;

  CartItem({
    required this.id,
    required this.productName,
    required this.imageUrl,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      productName: json['product']['name'],
      imageUrl: json['product']['image'],
      price: json['product']['price'].toDouble(),
      quantity: json['quantity'],
    );
  }
}