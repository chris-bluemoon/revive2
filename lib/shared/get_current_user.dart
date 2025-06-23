// import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';

bool loggedIn = false;

Future getCurrentUser() async {
  User? user = FirebaseAuth.instance.currentUser;
// Firebase.Auth.FirebaseUser user = auth.CurrentUser;
  // User? asda = FirebaseAuth.instance.currentUser;
  if (user != null) {
    loggedIn = true;
  } else {
    loggedIn = false;
  }
  return user;
  // return asda;
}
