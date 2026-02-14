import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class RelworxPaymentService {
  // ── Proxy server base URL ──
  // After deploying to Render, replace with your actual URL, e.g.:
  //   https://justpay-payment-proxy.onrender.com
  // TODO: Replace this after deploying the payment-server to Render
  static const String _proxyBaseUrl =
      'https://justpay-payment-proxy.onrender.com';

  /// Generate a unique reference based on current datetime
  static String generateReference() {
    final now = DateTime.now();
    return '${now.millisecondsSinceEpoch}${now.microsecond}';
  }

  /// Request a mobile money payment via proxy server
  static Future<Map<String, dynamic>> requestPayment({
    required String msisdn,
    required double amount,
    required String description,
  }) async {
    final reference = generateReference();

    try {
      final response = await http.post(
        Uri.parse('$_proxyBaseUrl/requestPayment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'amount': amount,
          'description': description,
          'reference': reference,
        }),
      );

      print(
        'Request Payment Response: ${response.statusCode} ${response.body}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        data['reference'] = reference;
        return data;
      } else {
        // Try to parse error message from response body
        String errorMsg = 'Request failed with status ${response.statusCode}';
        try {
          final errData = jsonDecode(response.body);
          if (errData['message'] != null) {
            errorMsg = errData['message'];
          }
        } catch (_) {}
        return {'success': false, 'message': errorMsg, 'reference': reference};
      }
    } catch (e) {
      print('Error requesting payment: $e');
      return {
        'success': false,
        'message': 'Network error: $e',
        'reference': reference,
      };
    }
  }

  /// Check the status of a payment request via proxy server
  static Future<Map<String, dynamic>> checkPaymentStatus({
    required String internalReference,
  }) async {
    try {
      final uri = Uri.parse(
        '$_proxyBaseUrl/checkPaymentStatus?internal_reference=$internalReference',
      );

      final response = await http.get(uri);

      print('Check Status Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Status check failed with status ${response.statusCode}',
        };
      }
    } catch (e) {
      print('Error checking payment status: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Poll payment status every 5 seconds until completed or timeout
  static Stream<Map<String, dynamic>> pollPaymentStatus({
    required String internalReference,
    Duration timeout = const Duration(minutes: 3),
    Duration interval = const Duration(seconds: 5),
  }) async* {
    final stopTime = DateTime.now().add(timeout);

    while (DateTime.now().isBefore(stopTime)) {
      await Future.delayed(interval);

      final status = await checkPaymentStatus(
        internalReference: internalReference,
      );

      yield status;

      // Check if the transaction is completed (success or failed)
      final txStatus = (status['transaction_status'] ?? '')
          .toString()
          .toLowerCase();
      if (txStatus == 'successful' ||
          txStatus == 'success' ||
          txStatus == 'completed') {
        return;
      }
      if (txStatus == 'failed' ||
          txStatus == 'cancelled' ||
          txStatus == 'rejected') {
        return;
      }
    }

    // Timeout reached
    yield {
      'success': false,
      'message': 'Payment status check timed out. Please check manually.',
      'transaction_status': 'timeout',
    };
  }
}
