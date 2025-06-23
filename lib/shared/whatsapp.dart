import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// A utility method to open WhatsApp on different devices
/// Optionality you can add [text] message
Future<void> openWhatsApp({
  required String phone,
  String? text,
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  final String textIOS = text != null ? Uri.encodeFull('?text=$text') : '';
  final String textAndroid = text != null ? Uri.encodeFull('&text=$text') : '';

  // whatsapp://send?phone=$phone
  final String urlIOS = 'https://wa.me/$phone$textIOS';
  final String urlAndroid = 'whatsapp://send/?phone=$phone$textAndroid';

  final String effectiveURL = Platform.isIOS ? urlIOS : urlAndroid;

  if (await canLaunchUrl(Uri.parse(effectiveURL))) {
    await launchUrl(Uri.parse(effectiveURL), mode: mode);
  } else {
    throw Exception('openWhatsApp could not launching url: $effectiveURL');
  }
}