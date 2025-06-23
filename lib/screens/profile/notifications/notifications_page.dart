import 'package:flutter/material.dart';
import 'package:revivals/shared/styled_text.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  bool rentalsPush = true;
  bool socialPush = true;
  bool marketingPush = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: StyledTitle('NOTIFICATIONS'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // Rentals & Sales Section
          Text(
            'Rentals & Sales',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Stay on top of your rentals and resale enquies and requests.',
            style: TextStyle(color: Colors.grey[700], fontSize: 15),
          ),
          SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Push Notifications'),
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
          Divider(height: 32),

          // Social Section
          Text(
            'Social',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'Get notifified when you are featured in collections, receive new followers, likes, saves and more.',
            style: TextStyle(color: Colors.grey[700], fontSize: 15),
          ),
          SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Push Notifications'),
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
          Divider(height: 32),

          // Marketing Section
          Text(
            'Marketing',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text(
            'You heard it here first! Receive exclusive promotions, partnerships, community events and insights.',
            style: TextStyle(color: Colors.grey[700], fontSize: 15),
          ),
          SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Push Notifications'),
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