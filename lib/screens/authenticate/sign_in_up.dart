import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/authenticate/authenticate.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

// Join millions of Happy Users
// Rest assured, your data remains secure, and you will not be subjected to any spam!
// Continue with one of these:

var uuid = const Uuid();

class GoogleSignInScreen extends StatefulWidget {
  const GoogleSignInScreen({super.key});

  @override
  State<GoogleSignInScreen> createState() => _GoogleSignInScreenState();
}

class _GoogleSignInScreenState extends State<GoogleSignInScreen> {
  ValueNotifier userCredential = ValueNotifier('');

  bool showSignIn = true;

  late bool found = false;

  void handleNewLogIn(String email, String name) async {
    print('=== DEBUG: handleNewLogIn called ===');
    print('Email: $email');
    print('Name: $name');
    
    Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(true);
    List<Renter> renters =
        Provider.of<ItemStoreProvider>(context, listen: false).renters;

    print('Total renters in database: ${renters.length}');
    
    // Debug: Print all renter emails to see what's available
    for (int i = 0; i < renters.length; i++) {
      print('Renter $i: ${renters[i].email} (status: ${renters[i].status})');
    }

    for (Renter r in renters) {
      if (r.email == email && r.status != 'deleted') {
        print('✓ User found: ${r.email}');
        found = true;

        Provider.of<ItemStoreProvider>(context, listen: false).setCurrentUser();
        break; // fixed this
      } else {
        found = false;
      }
    }
    
    print('User found: $found');
    
    if (found == false) {
      // Auto-register the new user
      final newRenter = Renter(
        id: uuid.v4(),
        email: email,
        name: name ?? email.split('@')[0], type: '', size: 0, address: '', countryCode: '', phoneNum: '', favourites: [], verified: '', imagePath: '', creationDate: '', location: '', bio: '', followers: [], following: [], avgReview: 0, lastLogin: DateTime.now(), vacations: [], status: 'active',
        // ... other required fields
      );
      
      // Add to database and local list
      await Provider.of<ItemStoreProvider>(context, listen: false).addRenter(newRenter);
      found = true;
    }

    Provider.of<ItemStoreProvider>(context, listen: false).populateFavourites();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          title: const StyledTitle('SIGN IN/UP'),
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: width * 0.08),
            onPressed: () {
              Navigator.of(context).pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);

          },
        ),
      ),
        // title: const Text('', style: TextStyle(fontSize: 22, color: Colors.black)),
        body: ValueListenableBuilder(
          valueListenable: userCredential,
          builder: (context, value, child) {
            if (userCredential.value == '' || userCredential.value == null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                      child: SizedBox(
                    width: width * 0.8,
                    child: SignInButton(Buttons.Email, 
                    onPressed: () {Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                      const Authenticate()
                                    )
                                  );}
                    ),
                      )),
                  SizedBox(height: width * 0.05),
                  Center(
                    child: SizedBox(
                      width: width * 0.8,
                      child: SignInButton(
                        Buttons.Google,
                        onPressed: () async {
                          showDialogue(context);
                          userCredential.value = await signInWithGoogle();
                          hideProgressDialogue(context);
                          
                          print('=== DEBUG: Google Sign-In Result ===');
                          print('userCredential.value: ${userCredential.value}');
                          
                          if (userCredential.value != null && context.mounted) {
                            final email = userCredential.value.user!.email;
                            final displayName = userCredential.value.user!.displayName;
                            print('Email from Google: $email');
                            print('Display Name from Google: $displayName');
                            
                            handleNewLogIn(email, displayName);
                            
                            // Only show success dialog if user was found (found == true)
                            if (found == true) {
                              showDialog(
                                barrierDismissible: false,
                                context: context,
                                builder: (_) => AlertDialog(
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero), // Square corners
                                  actions: [
                                    ElevatedButton(
                                      style: ButtonStyle(
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
                                        Navigator.of(context).pop(); // Close dialog
                                        Navigator.of(context).pushNamedAndRemoveUntil(
                                          '/', // Navigate to home page
                                          (route) => false,
                                        );
                                      },
                                      child: const StyledHeading('OK',
                                          weight: FontWeight.normal,
                                          color: Colors.white),
                                    ),
                                  ],
                                  backgroundColor: Colors.white,
                                  title: const Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Flexible(
                                          child: StyledHeading(
                                              "Successfully logged in",
                                              weight: FontWeight.normal)),
                                    ],
                                  ),
                                ),
                              );
                            }
                          } else {
                            // Sign-in was cancelled or failed
                            print('Google Sign-In was cancelled or failed');
                            if (context.mounted) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero, // Square corners
                                    ),
                                    title: const Text('Sign-In Failed'),
                                    content: const Text('Google Sign-In failed. Please check your internet connection and try again.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
                          }
                        },
                      ),
                    ),
                  )
                ],
              );
            } else {
              //
              return const Text('');
              // showSuccessfulLogin();
            }
          },
        ));
  }
}

// showSuccessfulLogin() {

// }
Future<dynamic> signInWithGoogle() async {
  try {
    // Initialize GoogleSignIn with proper iOS configuration
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      // Use the client ID from Info.plist for iOS
      clientId: '973384003437-2vuflvrrv8j2n17ug63vn36c5ka8bodt.apps.googleusercontent.com',
    );
    
    // Sign out first to ensure clean state
    await googleSignIn.signOut();
    
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    
    // Check if user cancelled the sign-in
    if (googleUser == null) {
      print('Google Sign-In was cancelled by user');
      return null;
    }
    
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    
    // Check if authentication tokens are available
    if (googleAuth.accessToken == null && googleAuth.idToken == null) {
      print('Error: No authentication tokens received from Google');
      return null;
    }
    
    print('Access Token: ${googleAuth.accessToken != null ? "Available" : "Null"}');
    print('ID Token: ${googleAuth.idToken != null ? "Available" : "Null"}');
    
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } catch (e) {
    print('Google Sign-In exception: $e');
    // Handle specific network errors
    if (e.toString().contains('network') || e.toString().contains('connection')) {
      print('Network error during Google Sign-In. Please check your internet connection.');
    }
    return null;
  }
}

Future<bool> signOutFromGoogle() async {
  try {
    await FirebaseAuth.instance.signOut();
    return true;
  } on Exception catch (_) {
    return false;
  }
}

void showDialogue(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) => const Loading(),
  );
}

void hideProgressDialogue(BuildContext context) {
  Navigator.of(context).pop(const Loading());
}

class Loading extends StatelessWidget {
  const Loading({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: const Center(
        child: SpinKitChasingDots(color: Colors.black, size: 50),
      ),
    );
  }
}
