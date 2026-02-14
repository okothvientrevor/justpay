import 'package:flutter/material.dart';
import 'dart:async';
import '../../services/relworx_payment_service.dart';

class MakePaymentPage extends StatefulWidget {
  const MakePaymentPage({Key? key}) : super(key: key);

  @override
  State<MakePaymentPage> createState() => _MakePaymentPageState();
}

class _MakePaymentPageState extends State<MakePaymentPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _contactController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isProcessing = false;
  String _statusMessage = '';
  StreamSubscription? _pollSubscription;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pollSubscription?.cancel();
    _contactController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _submitPayment() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isProcessing = true;
      _statusMessage = 'Initiating payment request...';
    });

    final contact = _contactController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final description = _descriptionController.text.trim().isNotEmpty
        ? _descriptionController.text.trim()
        : 'Payment Request';

    // Step 1: Request payment
    final result = await RelworxPaymentService.requestPayment(
      msisdn: contact,
      amount: amount,
      description: description,
    );

    if (result['success'] != true) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '';
      });
      _showResultDialog(
        success: false,
        message: result['message'] ?? 'Payment request failed.',
      );
      return;
    }

    final internalReference = result['internal_reference'] ?? '';

    if (internalReference.isEmpty) {
      setState(() {
        _isProcessing = false;
        _statusMessage = '';
      });
      _showResultDialog(
        success: false,
        message: 'No reference received from payment gateway.',
      );
      return;
    }

    setState(() {
      _statusMessage = 'Payment request sent. Checking status...';
    });

    // Step 2: Poll for payment status every 5 seconds
    _pollSubscription =
        RelworxPaymentService.pollPaymentStatus(
          internalReference: internalReference,
        ).listen(
          (status) {
            final txStatus = (status['transaction_status'] ?? 'pending')
                .toString()
                .toLowerCase();

            setState(() {
              _statusMessage = 'Status: ${_formatStatus(txStatus)}';
            });

            if (txStatus == 'successful' ||
                txStatus == 'success' ||
                txStatus == 'completed') {
              _pollSubscription?.cancel();
              // Now send the payment to the recipient
              _sendPaymentToRecipient(contact, amount, description);
            } else if (txStatus == 'failed' ||
                txStatus == 'cancelled' ||
                txStatus == 'rejected') {
              _pollSubscription?.cancel();
              setState(() {
                _isProcessing = false;
                _statusMessage = '';
              });
              _showResultDialog(
                success: false,
                message: 'Payment failed: ${status['message'] ?? txStatus}',
              );
            } else if (txStatus == 'timeout') {
              _pollSubscription?.cancel();
              setState(() {
                _isProcessing = false;
                _statusMessage = '';
              });
              _showResultDialog(
                success: false,
                message:
                    'Payment status check timed out. Please verify manually.',
              );
            }
          },
          onError: (e) {
            _pollSubscription?.cancel();
            setState(() {
              _isProcessing = false;
              _statusMessage = '';
            });
            _showResultDialog(
              success: false,
              message: 'Error checking payment status: $e',
            );
          },
        );
  }

  Future<void> _sendPaymentToRecipient(
    String recipientMsisdn,
    double amount,
    String description,
  ) async {
    setState(() {
      _statusMessage = 'Sending payment to recipient...';
    });

    final sendResult = await RelworxPaymentService.sendPayment(
      msisdn: recipientMsisdn,
      amount: amount,
      description: description.isNotEmpty
          ? description
          : 'Payment from JustPay',
    );

    setState(() {
      _isProcessing = false;
      _statusMessage = '';
    });

    if (sendResult['success'] == true) {
      _showResultDialog(
        success: true,
        message: 'Payment sent successfully to $recipientMsisdn!',
      );
    } else {
      _showResultDialog(
        success: false,
        message:
            'Failed to send payment: ${sendResult['message'] ?? 'Unknown error'}',
      );
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'pending':
        return 'Waiting for confirmation...';
      case 'processing':
        return 'Processing payment...';
      case 'successful':
      case 'success':
      case 'completed':
        return 'Payment successful!';
      case 'failed':
        return 'Payment failed';
      case 'cancelled':
        return 'Payment cancelled';
      case 'timeout':
        return 'Timed out';
      default:
        return 'Checking... ($status)';
    }
  }

  void _showResultDialog({required bool success, required String message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: success
                    ? Colors.green.withOpacity(0.15)
                    : Colors.red.withOpacity(0.15),
              ),
              child: Icon(
                success ? Icons.check_circle : Icons.error,
                size: 64,
                color: success ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              success ? 'Payment Successful!' : 'Payment Failed',
              style: TextStyle(
                color: success ? Colors.green : Colors.red,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: success
                      ? const Color(0xFF38EF7D)
                      : const Color(0xFF3FE0F6),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context); // close dialog
                  if (success) {
                    Navigator.pop(context); // go back to home
                  }
                },
                child: Text(
                  success ? 'Back to Home' : 'Try Again',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1F2E),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Make Payment',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4FACFE), Color(0xFF00F2FE)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4FACFE).withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.phone_android,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Mobile Money Payment',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Request payment via mobile money',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Contact field
                const Text(
                  'Recipient Contact',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _contactController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: '+256XXXXXXXXX',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: const Icon(
                      Icons.phone,
                      color: Color(0xFF3FE0F6),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF3FE0F6)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the contact number';
                    }
                    if (!value.trim().startsWith('+')) {
                      return 'Please include country code (e.g. +256...)';
                    }
                    if (value.trim().length < 10) {
                      return 'Please enter a valid phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Amount field
                const Text(
                  'Amount (UGX)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'Enter amount',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: const Icon(
                      Icons.payments_outlined,
                      color: Color(0xFF38EF7D),
                    ),
                    prefixText: 'UGX ',
                    prefixStyle: const TextStyle(
                      color: Color(0xFF38EF7D),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF38EF7D)),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an amount';
                    }
                    final amount = double.tryParse(value.trim());
                    if (amount == null || amount <= 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Description field
                const Text(
                  'Description (Optional)',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 2,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  decoration: InputDecoration(
                    hintText: 'e.g. Rent payment for January',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 24),
                      child: Icon(
                        Icons.description_outlined,
                        color: Color(0xFF4FACFE),
                      ),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF1E293B),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.white.withOpacity(0.1),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF4FACFE)),
                    ),
                  ),
                ),
                const SizedBox(height: 36),

                // Processing status
                if (_isProcessing) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF3FE0F6).withOpacity(0.3),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            color: Color(0xFF3FE0F6),
                            strokeWidth: 3,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _statusMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Please wait, do not close this page.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.4),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Submit button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _submitPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3FE0F6),
                      disabledBackgroundColor: Colors.grey.shade800,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
                    ),
                    child: Text(
                      _isProcessing ? 'Processing...' : 'Send Payment Request',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Cancel button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: _isProcessing
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: BorderSide(color: Colors.white.withOpacity(0.2)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('Cancel', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
