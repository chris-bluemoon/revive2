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
  bool _isProcessingLogin = false; // Add this loading state

  bool showSignIn = true;

  late bool found = false;

  Future<void> handleNewLogIn(String email, String name) async {
    print('=== DEBUG: handleNewLogIn called ===');
    print('Email: $email');
    print('Name: $name');
    
    // Don't set logged in status until we verify the user is not deleted
    List<Renter> renters =
        Provider.of<ItemStoreProvider>(context, listen: false).renters;

    print('Total renters in database: ${renters.length}');
    
    // Debug: Print all renter emails to see what's available
    for (int i = 0; i < renters.length; i++) {
      print('Renter $i: ${renters[i].email} (status: ${renters[i].status})');
    }

    bool isDeleted = false;
    
    for (Renter r in renters) {
      if (r.email == email) {
        if (r.status == 'deleted') {
          print('❌ User account is deleted: $email');
          isDeleted = true;
          break;
        } else {
          print('✓ User found: ${r.email}');
          found = true;
          Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(true);
          try {
            await Provider.of<ItemStoreProvider>(context, listen: false).setCurrentUser();
          } catch (e) {
            if (e.toString().contains('Account has been deleted')) {
              print('❌ DELETED USER CAUGHT BY PROVIDER: $email');
              isDeleted = true;
              found = false; // Reset found flag
              Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(false);
            } else {
              print('❌ Other error in setCurrentUser: $e');
              rethrow;
            }
          }
          break;
        }
      } else {
        found = false;
      }
    }
    
    print('User found: $found, Is deleted: $isDeleted');
    
    if (isDeleted) {
      print('Showing deleted account error for email: $email');
      Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(false);
      
      // Sign out from Firebase Auth since this account is deleted
      try {
        await FirebaseAuth.instance.signOut();
        print('Signed out deleted user from Firebase Auth');
      } catch (e) {
        print('Error signing out deleted user: $e');
      }
      
      // Reset processing state
      setState(() {
        _isProcessingLogin = false;
      });
      
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
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      }
      return; // Exit early, don't proceed with auto-registration
    }
    
    if (found == false) {
      print('❌ User not found in database - Auto-registering new user');
      // Auto-register the new user
      final newRenter = Renter(
        id: uuid.v4(),
        email: email,
        name: name.isNotEmpty ? name : email.split('@')[0], 
        type: '', 
        size: 0, 
        address: '', 
        countryCode: '', 
        phoneNum: '', 
        favourites: [], 
        verified: '', 
        imagePath: '', 
        creationDate: DateTime.now().toString(), 
        location: '', 
        bio: '', 
        followers: [], 
        following: [], 
        avgReview: 0, 
        lastLogin: DateTime.now(), 
        vacations: [], 
        status: 'active',
      );
      
      // Add to database and local list
      await Provider.of<ItemStoreProvider>(context, listen: false).addRenter(newRenter);
      
      // Set the newly created user as current user
      final provider = Provider.of<ItemStoreProvider>(context, listen: false);
      provider.setLoggedIn(true);
      provider.setCurrentUser();
      
      found = true;
      print('✓ New user auto-registered and set as current user');
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
              Navigator.of(context).pushNamedAndRemoveUntil('/home', (Route<dynamic> route) => false);

          },
        ),
      ),
        // title: const Text('', style: TextStyle(fontSize: 22, color: Colors.black)),
        body: ValueListenableBuilder(
          valueListenable: userCredential,
          builder: (context, value, child) {
            // Show loading state when processing login after Google sign-in
            if (_isProcessingLogin) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Loading(isDialog: false),
                    SizedBox(height: 20),
                    StyledBody(
                      'Setting up your account...',
                      color: Colors.grey,
                      weight: FontWeight.normal,
                    ),
                  ],
                ),
              );
            }
            
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
                          setState(() {
                            _isProcessingLogin = true;
                          });
                          
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
                            
                            await handleNewLogIn(email, displayName);
                            
                            // Only navigate to home page if login was successful and user wasn't deleted
                            if (context.mounted && found == true && !_isProcessingLogin) {
                              Navigator.of(context).pushNamedAndRemoveUntil(
                                '/home', // Navigate to home page
                                (route) => false,
                              );
                            } else if (context.mounted && _isProcessingLogin) {
                              // Reset processing state if login failed or account was deleted
                              setState(() {
                                _isProcessingLogin = false;
                              });
                            }
                          } else {
                            // Sign-in was cancelled or failed
                            print('Google Sign-In was cancelled or failed');
                            setState(() {
                              _isProcessingLogin = false;
                            });
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
  final bool isDialog;
  const Loading({super.key, this.isDialog = true});

  @override
  Widget build(BuildContext context) {
    const spinner = SpinKitChasingDots(color: Colors.black, size: 50);
    
    if (isDialog) {
      return Container(
        color: Colors.white,
        child: const Center(child: spinner),
      );
    } else {
      return spinner;
    }
  }
}
