class Invoice {
  final int id;
  final String createDate;
  final String status;

  Invoice({
    required this.id,
    required this.createDate,
    required this.status,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'],
      createDate: json['createDate'] ?? '',
      status: json['status'] ?? '',
    );
  }
}
