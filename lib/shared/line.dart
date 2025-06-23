import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// A utility method to open WhatsApp on different devices
/// Optionality you can add [text] message
// Future<void> openLineApp({
//   required String phone,
//   String? text,
//   LaunchMode mode = LaunchMode.externalApplication,
// }) async {
//   final String textIOS = text != null ? Uri.encodeFull('?text=$text') : '';
//   final String textAndroid = text != null ? Uri.encodeFull('&text=$text') : '';

//   // https://line.me/R/
//   // https://liff.line.me/
//   final String urlIOS = 'https://wa.me/$phone$textIOS';
//   final String urlAndroid = 'liff.line.me:://send/?phone=$phone$textAndroid';

//   String effectiveURL = Platform.isIOS ? urlIOS : urlAndroid;
//   // effectiveURL = 'https://line.me/R/';
//   // effectiveURL2 = 'https://line.me/R/oaMessage/ZnlhXmE';
//   // effectiveURL = 'https://liff.line.me/';
//   effectiveURL = 'http://line.me/ti/p/~chris-mbfc';
//   effectiveURL = 'http://line.me/ti/p/~isabellachsz';
//   effectiveURL = 'http://line.me/ti/p/@447qtapp';
//   // effectiveURL = 'http://line.me/ti/p/~UnearthedCollections';
//   // effectiveURL = 'https://line.me/R/oaMessage/@chris-mbfc/?Hello';

//   if (await canLaunchUrl(Uri.parse(effectiveURL))) {
//     await launchUrl(Uri.parse(effectiveURL));
//   } else {
//     throw Exception('openLineApp could not launching url: $effectiveURL');
//   }
// }

// const String lineUrl = 'https://line.me/ti/p/ITjc1QnYkW';

// Future<void> openLineApp() async {
//   final Uri uri = Uri.parse('https://line.me/ti/p/ITjc1QnYkW');
//   if (await canLaunchUrl(uri)) {
//     await launchUrl(uri, mode: LaunchMode.platformDefault);
//   } else {
//     throw 'Could not launch LINE link';
//   }
// }

Future<void> openLineApp(BuildContext context) async {
  final Uri lineAppUri =
      Uri.parse('https://lin.ee/aiEjhM1'); // Deep link to open LINE
  final Uri fallbackWebUri =
      Uri.parse('https://line.me/ti/p/ITjc1QnYkW'); // Fallback LINE URL
  final Uri lineStoreAndroid = Uri.parse(
      'https://play.google.com/store/apps/details?id=jp.naver.line.android'); // LINE app download link
  final Uri lineStoreIOS =
      Uri.parse('https://apps.apple.com/app/line/id443904275');
  if (await canLaunchUrl(lineAppUri)) {
    await launchUrl(lineAppUri, mode: LaunchMode.externalApplication);
  } else if (await canLaunchUrl(fallbackWebUri)) {
    // Open the LINE profile in a browser as fallback
    await launchUrl(fallbackWebUri, mode: LaunchMode.externalApplication);
  } else {
    // If all fails, redirect to download LINE from Play Store
    if (Platform.isAndroid && await canLaunchUrl(lineStoreAndroid)) {
      await launchUrl(lineStoreAndroid, mode: LaunchMode.externalApplication);
    } else if (Platform.isIOS && await canLaunchUrl(lineStoreIOS)) {
      await launchUrl(lineStoreIOS, mode: LaunchMode.externalApplication);
    } else {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Unable to open LINE or its download page.')),
      );
    }
  }
}
