import 'package:flutter/material.dart';
import 'package:revivals/shared/styled_text.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool rentalsPush = true;
  bool socialPush = true;
  bool marketingPush = true;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const StyledTitle('NOTIFICATIONS'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Rentals & Sales Section
          const Text(
            'Rentals & Sales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Stay on top of your rentals and resale enquies and requests.',
            style: TextStyle(color: Colors.grey[700], fontSize: 15),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Push Notifications'),
            trailing: Switch(
              value: rentalsPush,
              onChanged: (val) async {
                setState(() {
                  rentalsPush = val;
                });
                if (!val) {
                  // await FirebaseMessaging.instance.setAutoInitEnabled(false);
                } else {
                  // await FirebaseMessaging.instance.setAutoInitEnabled(true);
                }
              },
            ),
          ),
          const Divider(height: 32),

          // Social Section
          const Text(
            'Social',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Get notifified when you are featured in collections, receive new followers, likes, saves and more.',
            style: TextStyle(color: Colors.grey[700], fontSize: 15),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Push Notifications'),
            trailing: Switch(
              value: socialPush,
              onChanged: (val) async {
                setState(() {
                  socialPush = val;
                });
                if (!val) {
                  // await FirebaseMessaging.instance.setAutoInitEnabled(false);
                } else {
                  // await FirebaseMessaging.instance.setAutoInitEnabled(true);
                }
              },
            ),
          ),
          const Divider(height: 32),

          // Marketing Section
          const Text(
            'Marketing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You heard it here first! Receive exclusive promotions, partnerships, community events and insights.',
            style: TextStyle(color: Colors.grey[700], fontSize: 15),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Push Notifications'),
            trailing: Switch(
              value: marketingPush,
              onChanged: (val) async {
                setState(() {
                  marketingPush = val;
                });
                if (!val) {
                  // await FirebaseMessaging.instance.setAutoInitEnabled(false);
                } else {
                  // await FirebaseMessaging.instance.setAutoInitEnabled(true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }}