import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/home_page.dart';
import 'package:revivals/services/auth.dart';
import 'package:revivals/shared/constants.dart';
import 'package:revivals/shared/loading.dart';
import 'package:revivals/shared/styled_text.dart';
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
    // First refresh the renters list to get the latest data from Firebase
    await Provider.of<ItemStoreProvider>(context, listen: false).fetchRentersOnce();
    
    List<Renter> renters =
        Provider.of<ItemStoreProvider>(context, listen: false).renters;
    found = false;
    bool isDeleted = false;

    for (Renter r in renters) {
      log('Checking renter: ${r.email} against status: ${r.status}');
      if (r.email == email) {
        if (r.status == 'deleted') {
          log('User account is deleted: $email');
          isDeleted = true;
          break;
        } else {
          found = true;
          Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(true);
          Provider.of<ItemStoreProvider>(context, listen: false)
              .setCurrentUser();
          break;
        }
      }
    }

    if (isDeleted) {
      log('Showing deleted account error for email: $email');
      Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(false);
      
      // Reset loading state since login is rejected
      setState(() => loading = false);
      
      // Sign out from Firebase Auth since this account is deleted
      try {
        await FirebaseAuth.instance.signOut();
        log('Signed out deleted user from Firebase Auth');
      } catch (e) {
        log('Error signing out deleted user: $e');
      }
      
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Account Deleted'),
            content: const Text('This account has been deleted. If you believe this is an error, please contact us for assistance.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
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
            title: const Text('Login Error'),
            content: const Text('Error logging in, please contact support'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/', // Navigate to home page
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
      if (context.mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/', // Replace with your HomePage route name
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
        ? const Loading()
        : Scaffold(
            appBar: AppBar(
              toolbarHeight: width * 0.2,
              // centerTitle: true,
              title: const StyledTitle('SIGN IN'),
              leading: IconButton(
                icon: Icon(Icons.chevron_left, size: width * 0.08),
                onPressed: () {
                  // Remove all routes and push the home page with bottom nav bar
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const HomePage()), // Replace HomePage with your home widget
                    (route) => false,
                  );
                },
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: 0.0, horizontal: width * 0.02),
                  child: GestureDetector(
                    onTap: () {
                      widget.toggleView();
                    },
                    child: Row(
                      children: [
                        const StyledBody('REGISTER', weight: FontWeight.normal),
                        SizedBox(width: width * 0.01),
                        Icon(Icons.person, size: width * 0.05)
                      ],
                    ),
                  ),
                )
              ],
            ),
            body: Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StyledHeading(
                    'Enter your email and password',
                    weight: FontWeight.normal,
                  ),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 30, horizontal: 50),
                      child: Form(
                          key: _formKey,
                          child: Column(
                            children: <Widget>[
                              const SizedBox(height: 20),
                              TextFormField(
                                decoration: textInputDecoration.copyWith(
                                  hintText: 'Email',
                                ),
                                validator: (val) =>
                                    val!.isEmpty ? 'Enter an email' : null,
                                onChanged: (val) {
                                  setState(() {
                                    email = val.toLowerCase(); // Always store as lowercase
                                    ready = true;
                                  });
                                },
                              ),
                              const SizedBox(height: 20),
                              TextFormField(
                                  decoration: textInputDecoration.copyWith(
                                    hintText: 'Password',
                                  ),
                                  validator: (val) => val!.length < 6
                                      ? 'Enter a password at least 6 chars long'
                                      : null,
                                  obscureText: true,
                                  onChanged: (val) {
                                    setState(() {
                                      password = val;
                                      ready = true;
                                    });
                                  }),
                              SizedBox(height: width * 0.05),
                              GestureDetector(
                                  onTap: () async {
                                    bool res =
                                        await _auth.sendPasswordReset(email);

                                    if (res == false && context.mounted) {
                                      showAlertDialogError(context);
                                    }
                                  },
                                  child:
                                      const StyledBody('Forgotten password?')),
                            ],
                          ))),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border:
                    Border.all(color: Colors.black.withOpacity(0.3), width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 3,
                  )
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  if (!ready)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                          side:
                              const BorderSide(width: 1.0, color: Colors.black),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: StyledHeading('SIGN IN',
                              weight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(width: 5),
                  if (ready)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => loading = true);
                            dynamic result = await _auth
                                .signInWithEmailAndPassword(email, password);

                            if (result == null) {
                              setState(() => loading = false);
                              if(context.mounted){showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(0))),
                                  actions: [
                                    // ElevatedButton(
                                    // onPressed: () {cancelLogOut(context);},
                                    // child: const Text('CANCEL', style: TextStyle(color: Colors.black)),),
                                    ElevatedButton(
                                      style: ButtonStyle(
                                          foregroundColor:
                                              WidgetStateProperty.all(
                                                  Colors.white),
                                          backgroundColor:
                                              const WidgetStatePropertyAll<Color>(
                                                  Colors.black),
                                          shape: WidgetStateProperty.all<
                                                  RoundedRectangleBorder>(
                                              const RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.all(
                                                      Radius.circular(0)),
                                                  side: BorderSide(
                                                      color: Colors.black)))),
                                      onPressed: () {
                                        setState(() {
                                          Navigator.pop(context);
                                        });
                                        // goBack(context);
                                      },
                                      child: const StyledHeading(
                                        'OK',
                                        weight: FontWeight.normal,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                  backgroundColor: Colors.white,
                                  title: const Center(
                                      child: Column(
                                        children: [
                                          Text("Invalid Username/Password",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                                          SizedBox(height: 8),
                                          Text("Please try again or contact us",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.normal)), 
                                        ],
                                      ),
                                  ),
                                ),
                              );
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
                          // ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        },
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(1.0),
                          ),
                          side:
                              const BorderSide(width: 1.0, color: Colors.black),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: StyledHeading('SIGN IN', color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
  }

  showAlertDialogError(BuildContext context) {
    // Create button
    double width = MediaQuery.of(context).size.width;

    Widget okButton = ElevatedButton(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(color: Colors.white),
        foregroundColor: Colors.white, //change background color of button
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(-1.0),
        ),
        side: const BorderSide(width: 0.0, color: Colors.black),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        // Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: const Center(child: StyledBody("OK", color: Colors.white)),
    );
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Center(child: StyledHeading('EMAIL NOT FOUND')),
      content: SizedBox(
        height: width * 0.1,
        child: const Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBody('Please check email', weight: FontWeight.normal),
                // Text("Your $itemType is being prepared,"),
                // Text("please check your email for confirmation."),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBody('and try again', weight: FontWeight.normal),
                // Text("Your $itemType is being prepared,"),
                // Text("please check your email for confirmation."),
              ],
            ),
          ],
        ),
      ),
      actions: [
        okButton,
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(-1.0)),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog(BuildContext context) {
    // Create button
    double width = MediaQuery.of(context).size.width;

    Widget okButton = ElevatedButton(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(color: Colors.white),
        foregroundColor: Colors.white, //change background color of button
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(-1.0),
        ),
        side: const BorderSide(width: 0.0, color: Colors.black),
      ),
      onPressed: () {
        Navigator.of(context).pop();
        // Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: const Center(child: StyledBody("OK", color: Colors.white)),
    );
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      title: const Center(child: StyledHeading('PASSWORD RESET SENT')),
      content: SizedBox(
        height: width * 0.1,
        child: const Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBody('Check your registered', weight: FontWeight.normal),
                // Text("Your $itemType is being prepared,"),
                // Text("please check your email for confirmation."),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBody('email to reset password',
                    weight: FontWeight.normal),
                // Text("Your $itemType is being prepared,"),
                // Text("please check your email for confirmation."),
              ],
            ),
          ],
        ),
      ),
      actions: [
        okButton,
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(-1.0)),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
