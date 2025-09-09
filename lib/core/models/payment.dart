enum PaymentMethod { mobileMoney, bankTransfer, cash, card }

enum PaymentProvider { mtn, airtel, bank, paystack }

enum PaymentStatus { pending, completed, failed, reversed }

class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime paymentDate;
  final PaymentMethod method;
  final PaymentProvider provider;
  final String reference;
  final PaymentStatus status;

  Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.method,
    required this.provider,
    required this.reference,
    required this.status,
  });
}
