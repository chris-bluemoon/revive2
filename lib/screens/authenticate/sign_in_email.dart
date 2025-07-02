import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/home_page.dart';
import 'package:revivals/services/auth.dart';
import 'package:revivals/shared/animated_logo_spinner.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class SignIn extends StatefulWidget {
  final Function toggleView;

  const SignIn({required this.toggleView, super.key});

  @override
  State<SignIn> createState() => _SignIn();
}

class _SignIn extends State<SignIn> {
  bool found = false;
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = 'Error: ';

  bool ready = false;

  void handleFoundLogIn(String email) async {
    log('=== DEBUG: handleFoundLogIn called for email: $email ===');
    
    // First refresh the renters list to get the latest data from Firebase
    await Provider.of<ItemStoreProvider>(context, listen: false).fetchRentersOnce();
    
    // Debug check specific user status
    await Provider.of<ItemStoreProvider>(context, listen: false).debugCheckUserStatus(email);
    
    List<Renter> renters =
        Provider.of<ItemStoreProvider>(context, listen: false).renters;
    log('Total renters loaded: ${renters.length}');
    
    // Debug: Print all renters and their status
    for (int i = 0; i < renters.length; i++) {
      log('Renter $i: ${renters[i].email} (status: ${renters[i].status})');
    }
    
    found = false;
    bool isDeleted = false;

    for (Renter r in renters) {
      log('🔍 Checking renter: "${r.email}" against login email: "$email"');
      log('🔍 Renter status: "${r.status}" (length: ${r.status.length})');
      log('🔍 Email match: ${r.email == email}');
      log('🔍 Status check: ${r.status == 'deleted'} (comparing "${r.status}" with "deleted")');
      
      if (r.email == email) {
        log('📧 EMAIL MATCH FOUND for: $email');
        
        // Check status with multiple conditions to catch any variations
        if (r.status == 'deleted' || r.status.toLowerCase().trim() == 'deleted') {
          log('🚫 DELETED USER DETECTED: $email with status: "${r.status}"');
          isDeleted = true;
          break;
        } else {
          log('✅ ACTIVE USER FOUND: $email with status: "${r.status}"');
          found = true;
          Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(true);
          try {
            await Provider.of<ItemStoreProvider>(context, listen: false).setCurrentUser();
            log('✅ setCurrentUser completed successfully');
          } catch (e) {
            log('💥 Exception caught from setCurrentUser: $e');
            if (e.toString().contains('Account has been deleted')) {
              log('❌ DELETED USER CAUGHT BY PROVIDER: $email');
              isDeleted = true;
              found = false; // Reset found flag
              Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(false);
            } else {
              log('❌ Other error in setCurrentUser: $e');
              rethrow;
            }
          }
          break;
        }
      }
    }

    log('Final state - found: $found, isDeleted: $isDeleted');

    if (isDeleted) {
      log('🚨 DELETED USER DETECTED - RESETTING ALL PROVIDERS FOR: $email');
      
      // Reset all provider state to ensure no cached data remains
      ItemStoreProvider.resetAllProviders(context);
      
      // Reset loading state since login is rejected
      setState(() => loading = false);
      
      // Sign out from Firebase Auth since this account is deleted
      try {
        await FirebaseAuth.instance.signOut();
        log('✓ Signed out deleted user from Firebase Auth');
      } catch (e) {
        log('❌ Error signing out deleted user: $e');
      }
      
      if (context.mounted) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero, // Square corners
              ),
              title: const Text('Account Deleted'),
              content: const Text('This account has been deleted. If you believe this is an error, please contact us for assistance.'),
              actions: [
                TextButton(
                  onPressed: () {
                    log('User dismissed deleted account dialog');
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      log('🛑 RETURNING EARLY FOR DELETED USER');
      return; // Exit early, don't proceed with login
    } else if (found == false) {
      log('User not found for email: $email');
      Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(false);
      
      // Reset loading state since login failed
      setState(() => loading = false);
      
      log('Showing login error dialog');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // Square corners
            ),
            title: const Text('Login Error'),
            content: const Text('Error logging in, please contact support'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/home', // Navigate to home page
                    (route) => false,
                  );
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // User found and logged in successfully, navigate to home
      log('🏠 NAVIGATING TO HOME PAGE FOR USER: $email');
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/home', // Replace with your HomePage route name
          (route) => false,
        );
      }
    }
    // if (found == false) {
    //
    //   String jointUuid = uuid.v4();
    //   Provider.of<ItemStoreProvider>(context, listen: false).addRenter(Renter(
    //     id: jointUuid,
    //     email: email,
    //     name: 'CHRIS',
    //     size: 0,
    //     address: '',
    //     countryCode: '+66',
    //     phoneNum: '',
    //     favourites: [''],
    //     fittings: [],
    //     settings: ['BANGKOK', 'CM', 'CM', 'KG'],
    //   ));
    //   Provider.of<ItemStoreProvider>(context, listen: false).assignUser(Renter(
    //     id: jointUuid,
    //     email: email,
    //     name: 'CHRIS',
    //     size: 0,
    //     address: '',
    //     countryCode: '+66',
    //     phoneNum: '',
    //     favourites: [''],
    //     fittings: [],
    //     settings: ['BANGKOK', 'CM', 'CM', 'KG'],
    //   ));
    // }
    Provider.of<ItemStoreProvider>(context, listen: false)
        .populateFavourites();
    // Provider.of<ItemStoreProvider>(context, listen: false).populateFittings();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return loading
        ? const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: AnimatedLogoSpinner()),
          )
        : Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 70,
              systemOverlayStyle: SystemUiOverlayStyle.dark,
              leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
                  );
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    widget.toggleView();
                  },
                  child: const Text(
                    'REGISTER',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      // Welcome text
                      const Text(
                        'Welcome back',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w300,
                          color: Colors.black,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to your account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey[600],
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 40),
                      
                      // Form card
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 4),
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Email field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'EMAIL',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter your email address',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 1,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                      keyboardType: TextInputType.emailAddress,
                                      validator: (val) => val!.isEmpty ? 'Please enter your email' : null,
                                      onChanged: (val) {
                                        setState(() {
                                          email = val.toLowerCase().trim();
                                          ready = email.isNotEmpty && password.isNotEmpty;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 24),
                                
                                // Password field
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'PASSWORD',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    TextFormField(
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Enter your password',
                                        hintStyle: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(
                                            color: Colors.grey[200]!,
                                            width: 1,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.black,
                                            width: 2,
                                          ),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 1,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: const BorderSide(
                                            color: Colors.red,
                                            width: 2,
                                          ),
                                        ),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 16,
                                        ),
                                      ),
                                      obscureText: true,
                                      validator: (val) => val!.length < 6
                                          ? 'Password must be at least 6 characters'
                                          : null,
                                      onChanged: (val) {
                                        setState(() {
                                          password = val;
                                          ready = email.isNotEmpty && password.isNotEmpty;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                
                                const SizedBox(height: 16),
                                
                                // Forgot password
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () async {
                                      HapticFeedback.lightImpact();
                                      if (email.isEmpty) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('Please enter your email first'),
                                            backgroundColor: Colors.black,
                                          ),
                                        );
                                        return;
                                      }
                                      
                                      bool res = await _auth.sendPasswordReset(email);
                                      if (res == false && context.mounted) {
                                        showAlertDialogError(context);
                                      } else if (context.mounted) {
                                        showAlertDialog(context);
                                      }
                                    },
                                    child: const Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ),
                                
                                const SizedBox(height: 32),
                                
                                // Sign in button
                                SizedBox(
                                  height: 56,
                                  child: ElevatedButton(
                                    onPressed: ready ? () async {
                                      HapticFeedback.mediumImpact();
                                      if (_formKey.currentState!.validate()) {
                                        setState(() => loading = true);
                                        
                                        // Debug check before sign in
                                        final itemProvider = Provider.of<ItemStoreProvider>(context, listen: false);
                                        await itemProvider.debugCheckUserStatus(email);
                                        
                                        dynamic result = await _auth.signInWithEmailAndPassword(email, password);

                                        if (result == null) {
                                          setState(() => loading = false);
                                          if (context.mounted) {
                                            _showErrorDialog(context);
                                          }
                                          setState(() {
                                            if (_formKey.currentState != null) {
                                              _formKey.currentState!.reset();
                                            }
                                          });
                                        } else {
                                          handleFoundLogIn(email);
                                        }
                                      }
                                      ready = false;
                                    } : null,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: ready ? Colors.black : Colors.grey[300],
                                      foregroundColor: ready ? Colors.white : Colors.grey[500],
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Text(
                                      'SIGN IN',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 1.2,
                                        color: ready ? Colors.white : Colors.grey[600],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Additional help text
                      Center(
                        child: Text(
                          'Need help? Contact our support team',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  void _showErrorDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Sign In Failed',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Invalid email or password.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Please check your credentials and try again.',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
    );
  }

  showAlertDialogError(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Email Not Found',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Please check your email address and try again.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        title: const Text(
          'Password Reset Sent',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Check your email for instructions to reset your password.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      ),
    );
  }
}
