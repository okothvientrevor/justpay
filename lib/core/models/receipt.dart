class Receipt {
  final String id;
  final String receiptNumber;
  final String paymentId;
  final double amount;
  final DateTime createdAt;
  final String payerName;
  final String description;
  final String? pdfUrl;

  Receipt({
    required this.id,
    required this.receiptNumber,
    required this.paymentId,
    required this.amount,
    required this.createdAt,
    required this.payerName,
    required this.description,
    this.pdfUrl,
  });
}
