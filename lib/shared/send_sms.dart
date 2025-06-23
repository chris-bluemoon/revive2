import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

/// A utility method to open SMS Messenger on different devices
/// Optionality you can add [text] message
Future<void> openSMS({
  required String phone,
  String? text,
  LaunchMode mode = LaunchMode.externalApplication,
}) async {
  final String effectivePhone = Platform.isAndroid
      ? phone.replaceAll('-', ' ')
      : phone.replaceFirst('+', '');

  final String effectiveText =
      Platform.isAndroid ? '?body=$text' : '&body=$text';

  final String url = 'sms:$effectivePhone';

  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse('$url$effectiveText'), mode: mode);
  } else {
    throw Exception('openSMS could not launching url: $url');
  }
}