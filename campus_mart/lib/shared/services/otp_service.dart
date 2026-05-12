import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class OTPService {
  // ⚠️ GET YOUR API KEY FROM: https://www.fast2sms.com/
  // It's free to sign up and gives you some testing credits.
  static const String _apiKey = 'YOUR_FAST2SMS_API_KEY_HERE';
  static const String _baseUrl = 'https://www.fast2sms.com/dev/bulkV2';

  /// Generates a random 6-digit OTP
  static String generateOTP() {
    final random = Random();
    String otp = '';
    for (int i = 0; i < 6; i++) {
      otp += random.nextInt(10).toString();
    }
    return otp;
  }

  /// Sends OTP via Fast2SMS
  static Future<bool> sendSMS({
    required String phoneNumber,
    required String otpCode,
  }) async {
    // If it's a test/placeholder key, just print for console and return true
    if (_apiKey == 'YOUR_FAST2SMS_API_KEY_HERE') {
      debugPrint('--- [TEST MODE] ---');
      debugPrint('Sending OTP $otpCode to $phoneNumber');
      debugPrint('Get a real key at fast2sms.com to send actual messages.');
      return true;
    }

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl?authorization=$_apiKey&route=otp&variables_values=$otpCode&numbers=$phoneNumber'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['return'] == true;
      }
      return false;
    } catch (e) {
      debugPrint('Error sending SMS: $e');
      return false;
    }
  }
}
