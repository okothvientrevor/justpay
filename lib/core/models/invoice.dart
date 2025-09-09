enum InvoiceStatus { pending, paid, overdue, cancelled }

class Invoice {
  final String id;
  final String invoiceNumber;
  final double amount;
  final String description;
  final DateTime dueDate;
  final DateTime issueDate;
  final InvoiceStatus status;
  final String? tenantId;
  final String? studentId;
  final String? paymentLink;
  final String? qrCodeUrl;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.amount,
    required this.description,
    required this.dueDate,
    required this.issueDate,
    required this.status,
    this.tenantId,
    this.studentId,
    this.paymentLink,
    this.qrCodeUrl,
  });
}
