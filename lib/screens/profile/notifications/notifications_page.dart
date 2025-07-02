import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: const StyledTitle('NOTIFICATIONS'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          // Rentals & Sales Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.shopping_bag, color: Colors.black87),
                      SizedBox(width: 12),
                      Text(
                        'Rentals & Sales',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Stay on top of your rentals and resale enquies and requests.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Switch(
                      value: rentalsPush,
                      onChanged: (val) async {
                        HapticFeedback.lightImpact();
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
                ],
              ),
            ),
          ),

          // Social Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.people, color: Colors.black87),
                      SizedBox(width: 12),
                      Text(
                        'Social',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Get notifified when you are featured in collections, receive new followers, likes, saves and more.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Switch(
                      value: socialPush,
                      onChanged: (val) async {
                        HapticFeedback.lightImpact();
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
                ],
              ),
            ),
          ),

          // Marketing Section
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.campaign, color: Colors.black87),
                      SizedBox(width: 12),
                      Text(
                        'Marketing',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You heard it here first! Receive exclusive promotions, partnerships, community events and insights.',
                    style: TextStyle(color: Colors.grey[700], fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Switch(
                      value: marketingPush,
                      onChanged: (val) async {
                        HapticFeedback.lightImpact();
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
            ),
          ),
        ],
      ),
    );
  }}