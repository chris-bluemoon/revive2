import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/services/auth.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class RegisterPassword extends StatefulWidget {
  const RegisterPassword({required this.email, required this.name, required this.location, super.key});

  final String email;
  final String name;
  final String location;

  @override
  State<RegisterPassword> createState() => _RegisterPassword();
}

class _RegisterPassword extends State<RegisterPassword> {
  bool found = false;
  final AuthService _auth = AuthService();
  bool loading = false;
  String loadingMessage = 'Creating your account...';

  // String password = '';
  bool ready = false;
  bool makeVisible = false;
  final passNotifier = ValueNotifier<PasswordStrength?>(null);
  late String password;
  double strength = 0;

  RegExp numReg = RegExp(r".*[0-9].*");
  RegExp letterReg = RegExp(r".*[A-Za-z].*");

  void checkPassword(String value) {
    password = value.trim();
    if (password.isEmpty) {
      setState(() {
        strength = 0;
      });
    } else if (password.length < 6) {
      setState(() {
        strength = 1 / 4;
        ready = false;
      });
    } else {
      if (!letterReg.hasMatch(password) || !numReg.hasMatch(password)) {
        setState(() {
          // Password length >= 8
          // But doesn't contain both letter and digit characters
          strength = 3 / 4;
          ready = true;
        });
      } else {
        // Password length >= 8
        // Password contains both letter and digit characters
        setState(() {
          strength = 1;
          ready = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    Future<void> handleNewLogIn(String email, String name, ItemStoreProvider provider) async {
      log('=== HANDLE NEW LOGIN START ===');
      log('Email: $email, Name: $name');
      
      List<Renter> renters = provider.renters;
      log('Current renters count: ${renters.length}');

      // Check if user already exists
      for (Renter r in renters) {
        log('Checking existing renter: ${r.email}, status: ${r.status}');
        if (r.email == email) {
          if (r.status == 'deleted') {
            log('User exists but account is deleted, cannot register/login');
            found = false; // Treat as if user doesn't exist, allow new registration
            break;
          } else {
            found = true;
            log('User already exists and is active, calling setCurrentUser');
            await provider.setCurrentUser();
            break;
          }
        } else {
          found = false;
        }
      }
      
      if (found == false) {
        log('User not found, creating new user');
        String jointUuid = uuid.v4();
        log('Generated UUID: $jointUuid');
        
        Renter newRenter = Renter(
          id: jointUuid,
          email: email,
          name: name,
          type: 'USER',
          size: 0,
          address: '',
          countryCode: '+66',
          phoneNum: '',
          favourites: [''],
          verified: 'not started',
          imagePath: '',
          creationDate: DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
          location: widget.location,
          bio: '',
          followers: [],
          following: [],
          avgReview: 0.0,
          lastLogin: DateTime.now(),
          status: 'active',
          vacations: [],
        );
        
        log('Created new renter object: ${newRenter.name} (${newRenter.id})');
        
        log('About to call addRenter - this will save to Firebase and assign user');
        await provider.addRenter(newRenter);
        log('addRenter completed - user should now be assigned');
      }

      log('Populating favourites...');
      provider.populateFavourites();
      log('=== HANDLE NEW LOGIN END ===');
    }

    // NEW PASSWORD CODE

    return loading
        ? Scaffold(
            backgroundColor: Colors.white,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Custom modern spinner
                  Container(
                    width: 60,
                    height: 60,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    loadingMessage,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            backgroundColor: Colors.grey[50],
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              toolbarHeight: 70,
              leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                },
              ),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Logo
                    Center(
                      child: Container(
                        width: width * 0.2,
                        height: width * 0.3,
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/logos/new_velaa_logo_transparent.png'),
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40.0),
                    
                    // Title
                    const Text(
                      'Create a secure password',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    const Text(
                      'Your password should contain at least 6 characters\nwith both letters and numbers',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 40.0),
                    
                    // Form Card
                    Card(
                      color: Colors.white,
                      elevation: 8,
                      shadowColor: Colors.black.withOpacity(0.1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    onChanged: (value) => checkPassword(value),
                                    obscureText: !makeVisible,
                                    decoration: InputDecoration(
                                      hintText: 'Password',
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: Colors.black, width: 2),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      makeVisible = !makeVisible;
                                    });
                                  },
                                  icon: Icon(
                                    makeVisible ? Icons.visibility : Icons.visibility_off,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            
                            // Password strength indicator
                            if (strength > 0) ...[
                              const SizedBox(height: 20),
                              Container(
                                width: double.infinity,
                                height: 8,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  color: Colors.grey[200],
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: strength,
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      color: strength <= 0.25
                                          ? Colors.red
                                          : strength <= 0.75
                                              ? Colors.orange
                                              : Colors.green,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                strength <= 0.25
                                    ? 'Weak password'
                                    : strength <= 0.75
                                        ? 'Good password'
                                        : 'Strong password',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: strength <= 0.25
                                      ? Colors.red
                                      : strength <= 0.75
                                          ? Colors.orange
                                          : Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 30.0),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: ready ? Colors.black : Colors.grey[300],
                                  foregroundColor: ready ? Colors.white : Colors.grey[500],
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: ready ? () async {
                                  HapticFeedback.lightImpact();
                                  if (strength == 1) {
                                    setState(() {
                                      loading = true;
                                      loadingMessage = 'Creating your account...';
                                    });
                                    dynamic result = await _auth.registerWithEmailAndPassword(
                                        widget.email, password);
                                    if (result == null) {
                                      setState(() => loading = false);
                                      if (context.mounted) {
                                        showDialog(
                                          barrierDismissible: false,
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                            ),
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.black,
                                                  foregroundColor: Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.of(context).pushReplacementNamed('/login');
                                                },
                                                child: const Text('OK'),
                                              ),
                                            ],
                                            backgroundColor: Colors.white,
                                            title: const Text(
                                              "Email already exists",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 18,
                                                color: Colors.black,
                                              ),
                                            ),
                                            content: const Text(
                                              "This email is already registered. Please try logging in instead.",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                    } else {
                                      // Store provider reference to avoid deactivated widget error
                                      final provider = Provider.of<ItemStoreProvider>(context, listen: false);
                                      
                                      // Keep loading state while setting up user
                                      setState(() {
                                        loadingMessage = 'Setting up your profile...';
                                      });
                                      try {
                                        await handleNewLogIn(widget.email, widget.name, provider);
                                        // Only navigate if the context is still mounted
                                        if (context.mounted) {
                                          setState(() {
                                            loadingMessage = 'Welcome! Taking you to the app...';
                                          });
                                          // Small delay to show the welcome message
                                          await Future.delayed(const Duration(milliseconds: 500));
                                          // Reset loading state before navigation
                                          setState(() => loading = false);
                                          Navigator.of(context)
                                              .pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);
                                        }
                                      } catch (error) {
                                        log('Error during user setup: $error');
                                        if (context.mounted) {
                                          setState(() => loading = false);
                                          // Show error dialog if needed
                                        }
                                      }
                                    }
                                  }
                                } : null,
                                child: const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
                  // Container(
                  //     padding:
                  //         EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.1),
                  //     child: Form(
                  //         key: _formKey,
                  //         child: Column(
                  //           children: <Widget>[
                  //             const SizedBox(height: 20),
                  //             TextFormField(
                  //               decoration: textInputDecoration.copyWith(
                  //                 hintText: 'Password',
                  //               ),
                  //               obscureText: true,
                  //               validator: (val) =>
                  //                   val!.isEmpty ? 'Enter a valid password' : null,
                  //               onChanged: (value) {
                  //
                  //
                  //                   passNotifier.value = PasswordStrength.calculate(text: value);
                  //                   password = value;
                  //                   if (PasswordStrength.calculate(text: value) == PasswordStrength.medium) {
                  //
                  //                     ready = true;
                  //                   } else {
                  //                     ready = false;
                  //                   }
                  //               },
                  //             ),
                  //             SizedBox(height: width * 0.03),
                  //             PasswordStrengthChecker(strength: passNotifier),
                  //
  }
}
