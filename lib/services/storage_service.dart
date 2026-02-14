// lib/services/storage_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StorageService {
  static const _storage = FlutterSecureStorage();

  // Keys
  static const String _landlordAccountKey = 'landlord_account';
  static const String _landlordProfileKey = 'landlord_profile';

  // Save landlord account data
  static Future<void> saveLandlordAccount(
    Map<String, dynamic> accountData,
  ) async {
    await _storage.write(
      key: _landlordAccountKey,
      value: jsonEncode(accountData),
    );
  }

  // Get landlord account data
  static Future<Map<String, dynamic>?> getLandlordAccount() async {
    final data = await _storage.read(key: _landlordAccountKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // Save landlord profile
  static Future<void> saveLandlordProfile(
    Map<String, dynamic> profileData,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_landlordProfileKey, jsonEncode(profileData));
  }

  // Get landlord profile
  static Future<Map<String, dynamic>?> getLandlordProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(_landlordProfileKey);
    if (data != null) {
      return jsonDecode(data);
    }
    return null;
  }

  // Check if landlord account is verified
  static Future<bool> isLandlordAccountVerified() async {
    final account = await getLandlordAccount();
    return account != null &&
        account['chargesEnabled'] == true &&
        account['payoutsEnabled'] == true;
  }

  // Clear all data (logout)
  static Future<void> clearAllData() async {
    await _storage.deleteAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
