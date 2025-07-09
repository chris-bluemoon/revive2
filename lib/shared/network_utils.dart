import 'dart:io';


class NetworkUtils {
  static Future<bool> hasInternetConnection({Duration timeout = const Duration(seconds: 5)}) async {
    try {
      final result = await InternetAddress.lookup('example.com').timeout(timeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (e) {
      // Handles TimeoutException and any other exception
      return false;
    }
  }
}
