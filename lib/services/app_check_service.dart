import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart';

class AppCheckService {
  static Future<void> initialize() async {
    await FirebaseAppCheck.instance.activate(
      // For Android, use Play Integrity in production, debug for development
      androidProvider: kDebugMode 
          ? AndroidProvider.debug 
          : AndroidProvider.playIntegrity,
      // For iOS, use DeviceCheck in production, debug for development  
      appleProvider: kDebugMode 
          ? AppleProvider.debug 
          : AppleProvider.deviceCheck,
      // For Web, use reCAPTCHA (you'll need to replace with your actual site key)
      webProvider: ReCaptchaV3Provider('6LeIxAcTAAAAAJcZVRqyHh71UMIEGNQ_MXjiZKhI'), // This is a test key
    );
  }

  // Method to get App Check token (useful for debugging)
  static Future<String?> getToken() async {
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      return token;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting App Check token: $e');
      }
      return null;
    }
  }

  // Method to set token auto refresh (optional)
  static void setTokenAutoRefreshEnabled(bool enabled) {
    FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(enabled);
  }
}
