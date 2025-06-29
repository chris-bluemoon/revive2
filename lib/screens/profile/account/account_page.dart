import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/profile/account/vacation_page.dart';
import 'package:revivals/screens/profile/edit_profile_page.dart';
import 'package:revivals/shared/styled_text.dart';


class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  Future<String> _getVersion() async {
    final info = await PackageInfo.fromPlatform();
    return 'v${info.version}+${info.buildNumber}';
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    Renter renter = Provider.of<ItemStoreProvider>(context, listen: false).renter;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const StyledTitle(
          "ACCOUNT",
        ),
        elevation: 0,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 40), // Add padding so version is not overlapped
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.04), // 4% of screen height
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Profile'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditProfilePage(renter: renter)),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person),
                title: const Text('Personal Information'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              // const Divider(),
              // ListTile(
                // leading: const Icon(Icons.straighten),
                // title: const Text('Size Preferences'),
                // trailing: const Icon(Icons.chevron_right),
                // onTap: () {},
              // ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.beach_access),
                title: const Text('Vacation Mode'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VacationPage()),
                  ); 
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.red),
                ),
                trailing: const Icon(Icons.chevron_right, color: Colors.red),
                onTap: () => _showDeleteAccountDialog(context, renter),
              ),
            ],
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: FutureBuilder<String>(
                future: _getVersion(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
                    return Text(
                      snapshot.data!,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, Renter renter) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Are you sure?",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "This will delete all your data and cancel any existing bookings.",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: Colors.black),
            ),
          ),
          TextButton(
            onPressed: () async {
              // When the user presses CONFIRM to delete account:
              final updatedRenter = renter.copyWith(status: 'deleted');
              Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(false);
              log('Logged in status set to ${Provider.of<ItemStoreProvider>(context, listen: false).loggedIn}');
              await Provider.of<ItemStoreProvider>(context, listen: false).saveRenter(updatedRenter);

              Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false); 
            },
            child: const Text(
              'CONFIRM',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> reauthenticateAndDeleteUser(String email, String password) async {
  try {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Re-authenticate
    final credential = EmailAuthProvider.credential(email: email, password: password);
    await user.reauthenticateWithCredential(credential);

    // Now delete
    await user.delete();
  } catch (e) {
    print('Error deleting user: $e');
    rethrow;
  }
}