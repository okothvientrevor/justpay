// lib/services/payment_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaymentService {
  // Update this with your actual Railway URL after deployment
  static const String baseUrl =
      'https://justpay-backend-production.up.railway.app/api/payments';

  // Test backend connectivity
  static Future<bool> testBackendConnection() async {
    try {
      print('Testing backend connection to: $baseUrl/test-connection');

      final response = await http
          .get(
            Uri.parse('$baseUrl/test-connection'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('Backend response status: ${response.statusCode}');
      print('Backend response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      return false;
    } catch (e) {
      print('Backend connection error: $e');
      return false;
    }
  }

  // Health check
  static Future<bool> healthCheck() async {
    try {
      print('Health check to: $baseUrl/../health');

      final response = await http
          .get(
            Uri.parse('${baseUrl.replaceAll('/api/payments', '')}/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('Health check response status: ${response.statusCode}');
      print('Health check response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'OK';
      }
      return false;
    } catch (e) {
      print('Health check error: $e');
      return false;
    }
  }

  // 1. Create landlord account
  static Future<Map<String, dynamic>?> createLandlordAccount({
    required String email,
    required String firstName,
    required String lastName,
    String? businessName,
    String country = 'US',
  }) async {
    try {
      print('Creating landlord account for: $email');

      final response = await http
          .post(
            Uri.parse('$baseUrl/create-landlord-account'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'firstName': firstName,
              'lastName': lastName,
              'businessName': businessName,
              'country': country,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Create account response status: ${response.statusCode}');
      print('Create account response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] ? data['landlord'] : null;
      } else {
        print('Error creating landlord account: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error creating landlord account: $e');
      return null;
    }
  }

  // 2. Get landlord onboarding link
  static Future<String?> getLandlordOnboardingLink(String accountId) async {
    try {
      print('Getting onboarding link for account: $accountId');

      final response = await http
          .post(
            Uri.parse('$baseUrl/landlord-onboarding-link'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'accountId': accountId}),
          )
          .timeout(const Duration(seconds: 30));

      print('Onboarding link response status: ${response.statusCode}');
      print('Onboarding link response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ? data['onboardingUrl'] : null;
      }
      return null;
    } catch (e) {
      print('Error getting onboarding link: $e');
      return null;
    }
  }

  // 3. Get landlord account status
  static Future<Map<String, dynamic>?> getLandlordAccountStatus(
    String accountId,
  ) async {
    try {
      print('Getting account status for: $accountId');

      final response = await http
          .get(
            Uri.parse('$baseUrl/landlord-account/$accountId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 30));

      print('Account status response status: ${response.statusCode}');
      print('Account status response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ? data['landlord'] : null;
      }
      return null;
    } catch (e) {
      print('Error getting account status: $e');
      return null;
    }
  }

  // 4. Create rent payment (invoice)
  static Future<Map<String, dynamic>?> createRentPayment({
    required double amount,
    required String landlordAccountId,
    required String description,
    String? tenantEmail,
    String? propertyAddress,
    String? rentPeriod,
    double applicationFeePercentage = 2.9,
  }) async {
    try {
      print('Creating rent payment for amount: \$${amount}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/create-rent-payment'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'amount': amount,
              'currency': 'usd',
              'description': description,
              'landlordAccountId': landlordAccountId,
              'tenantEmail': tenantEmail,
              'propertyAddress': propertyAddress,
              'rentPeriod': rentPeriod,
              'applicationFeePercentage': applicationFeePercentage,
            }),
          )
          .timeout(const Duration(seconds: 30));

      print('Create payment response status: ${response.statusCode}');
      print('Create payment response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['success'] ? data['rentPayment'] : null;
      } else {
        print('Error creating rent payment: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network error creating rent payment: $e');
      return null;
    }
  }

  // 5. Get landlord dashboard link
  static Future<String?> getLandlordDashboardLink(String accountId) async {
    try {
      print('Getting dashboard link for account: $accountId');

      final response = await http
          .post(
            Uri.parse('$baseUrl/landlord-dashboard-link'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'accountId': accountId}),
          )
          .timeout(const Duration(seconds: 30));

      print('Dashboard link response status: ${response.statusCode}');
      print('Dashboard link response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ? data['dashboardUrl'] : null;
      }
      return null;
    } catch (e) {
      print('Error getting dashboard link: $e');
      return null;
    }
  }
}
