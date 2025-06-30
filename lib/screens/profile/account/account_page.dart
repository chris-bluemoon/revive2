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
    
    return Consumer<ItemStoreProvider>(
      builder: (context, provider, child) {
        Renter renter = provider.renter;
        
        return WillPopScope(
          onWillPop: () async {
            log('WillPopScope triggered - loggedIn: ${provider.loggedIn}, userName: ${provider.renter.name}');
            // Check if user is still logged in when trying to go back
            if (!provider.loggedIn || provider.renter.name == 'no_user') {
              log('Redirecting to sign-in from WillPopScope');
              // If not logged in, redirect to sign-in instead of going back
              Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (route) => false);
              return false; // Prevent default back navigation
            }
            return true; // Allow normal back navigation
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: Icon(Icons.chevron_left, size: width * 0.08),
                onPressed: () {
                  log('Back chevron pressed - loggedIn: ${provider.loggedIn}, userName: ${provider.renter.name}');
                  // Check if user is still logged in when trying to go back
                  if (!provider.loggedIn || provider.renter.name == 'no_user') {
                    log('Redirecting to sign-in from back chevron');
                    // If not logged in, redirect to sign-in instead of going back
                    Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (route) => false);
                  } else {
                    // Normal back navigation
                    Navigator.of(context).pop();
                  }
                },
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
                    // ListTile(
                    //   leading: const Icon(Icons.person),
                    //   title: const Text('Personal Information'),
                    //   trailing: const Icon(Icons.chevron_right),
                    //   onTap: () {},
                    // ),
                    // const Divider(),
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
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context, Renter renter) {
    showDialog(
      context: context,
      builder: (context) => _DeleteAccountDialog(renter: renter),
    );
  }
}

class _DeleteAccountDialog extends StatefulWidget {
  final Renter renter;

  const _DeleteAccountDialog({required this.renter});

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  bool _isDeleting = false;
  String _statusMessage = '';

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: _isDeleting
          ? Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                const SizedBox(height: 16),
                Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            )
          : const Column(
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
      actions: _isDeleting
          ? null
          : [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              TextButton(
                onPressed: _handleDeleteAccount,
                child: const Text(
                  'CONFIRM',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            ],
    );
  }

  Future<void> _handleDeleteAccount() async {
    // Store references before async operations
    final provider = Provider.of<ItemStoreProvider>(context, listen: false);
    final navigator = Navigator.of(context);

    setState(() {
      _isDeleting = true;
      _statusMessage = 'Updating account status...';
    });

    try {
      log('Starting account deletion process for user: ${widget.renter.email}');
      
      setState(() {
        _statusMessage = 'Deleting account and cleaning up data...';
      });
      
      // Use the fast status update method instead of full renter update
      await provider.updateRenterStatus('deleted');
      log('Renter status updated to deleted in Firebase and cleaned up from follow lists');
      
      setState(() {
        _statusMessage = 'Logging out...';
      });
      
      // Set logged in status to false and clear user session
      provider.setLoggedIn(false);
      log('Logged in status set to ${provider.loggedIn}');
      
      // Close this dialog and the account page immediately to prevent back navigation issues
      setState(() {
        _statusMessage = 'Redirecting...';
      });
      
      // Small delay to show the redirecting message
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Navigate to sign-in page and clear entire navigation stack immediately
      // This prevents any back navigation to the profile page
      navigator.pushNamedAndRemoveUntil(
        '/sign_in', 
        (Route<dynamic> route) => false, // This clears ALL routes
      );
      
      // Sign out from Firebase Auth in the background after navigation
      FirebaseAuth.instance.signOut().then((_) {
        log('Firebase Auth sign out completed');
      }).catchError((e) {
        log('Firebase Auth sign out error: $e');
      });
      
      log('Navigation completed - should be on sign-in page with cleared history');
      
    } catch (error) {
      log('Error during account deletion: $error');
      
      if (mounted) {
        setState(() {
          _isDeleting = false;
          _statusMessage = '';
        });
        
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Error'),
            content: const Text('Failed to delete account. Please try again.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
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