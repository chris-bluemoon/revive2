import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

enum NotiType { request, accept, payment, cancel }

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('Handling a background message: ${message.messageId}');
}

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> requestPermission() async {
    await FirebaseMessaging.instance.requestPermission();
  }

  static Future<void> initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  static Future<void> init() async {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      log(' Foreground message: ${message.notification?.title}');
      showNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      log(' Notification opened app: ${message.notification?.title}');
      // You can navigate to a specific screen here if needed
    });
  }

  ///call when user login to update FCM token at firebase
  static Future<String> getFCMToken({int maxRetries = 3}) async {
    for (int attempt = 1; attempt <= maxRetries; attempt++) {
      try {
        final fcmToken = await FirebaseMessaging.instance.getToken();
        if (fcmToken != null) {
          log('FCM token retrieved successfully on attempt $attempt');
          return fcmToken.toString();
        }
      } on Exception catch (e) {
        final errorMessage = e.toString().toLowerCase();
        
        if (errorMessage.contains('service_not_available')) {
          log('FCM Service temporarily unavailable (attempt $attempt/$maxRetries). This is a transient network/Firebase issue, not a code bug.');
        } else if (errorMessage.contains('network') || errorMessage.contains('timeout')) {
          log('Network connectivity issue when getting FCM token (attempt $attempt/$maxRetries)');
        } else {
          log('Unknown FCM token error (attempt $attempt/$maxRetries): $e');
        }
        
        // If this is the last attempt, return empty string
        if (attempt == maxRetries) {
          log('Failed to get FCM token after $maxRetries attempts. App will continue to function normally without push notifications.');
          return '';
        }
        
        // Wait before retrying (exponential backoff)
        await Future.delayed(Duration(seconds: attempt * 2));
      }
    }
    return '';
  }

  ///call when user logout to delete FCM token at firebase
  static Future<void> deleteFCMToken({
    required String userId,
  }) async {
    try {
      await FirebaseFirestore.instance
          .collection('renter')
          .doc(userId)
          .update({'fcmToken': FieldValue.delete()});
      log('FCM token deleted successfully');
    } catch (e) {
      log('Failed to delete FCM token: $e');
    }
  }

  static void sendNotification(
      {required NotiType notiType,
      required String item,
      required String notiReceiverId}) async {
    String notiTitle;
    String notiBody;

    switch (notiType) {
      case NotiType.request:
        notiTitle = 'New Rent Request';
        notiBody = 'You have a new rent request for $item';
        break;
      case NotiType.accept:
        notiTitle = 'Rent Request Confirmed';
        notiBody = 'Your request for $item is confirmed';
        break;
      case NotiType.payment:
        notiTitle = 'Payment Received';
        notiBody = 'Payment for $item has been successfully received';
        break;
      case NotiType.cancel:
        notiTitle = 'Booking Cancelled';
        notiBody = 'The booking for $item has been cancelled by the renter';
        break;
    }
    String? fcmToken;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('renter')
          .doc(notiReceiverId)
          .get();
      if (doc.exists) {
        fcmToken = doc.data()?['fcmToken'];
      }
      log("fcmtoken $fcmToken $notiReceiverId $item");
      if (fcmToken == null) return;
      final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
      final callable = functions.httpsCallable('sendNotification');
      await callable.call({
        'notiTitle': notiTitle,
        'notiBody': notiBody,
        'token': fcmToken,
      });
      log('Notification sent successfully');
    } on Exception catch (e) {
      log('Error sending notification: $e');
    }
  }

  static Future<void> showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      channelDescription: 'channel description',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
        NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title,
      message.notification?.body,
      platformDetails,
    );
  }
}
