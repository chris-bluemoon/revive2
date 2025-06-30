import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
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

  void handleNewLogIn(String email, String name) {
    Provider.of<ItemStoreProvider>(context, listen: false).setLoggedIn(true);
    List<Renter> renters =
        Provider.of<ItemStoreProvider>(context, listen: false).renters;

    for (Renter r in renters) {
      if (r.email == email && r.status != 'deleted') {
        found = true;

        Provider.of<ItemStoreProvider>(context, listen: false).setCurrentUser();
        break; // fixed this
      } else {
        found = false;
      }
    }
    if (found == false) {
      String jointUuid = uuid.v4();
      Provider.of<ItemStoreProvider>(context, listen: false).addRenter(Renter(
        id: jointUuid,
        email: email,
        name: name,
        type: 'USER',
        size: 0,
        address: '',
        countryCode: '',
        phoneNum: '',
        favourites: [''],
        verified: 'not started',
        imagePath: '',
        creationDate: DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
        location: '', // <-- Add this line
        bio: '',
        followers: [],
        following: [],
        status: 'active', 
        avgReview: 0, 
        lastLogin: DateTime.now(), 
        vacations: [], // <-- Added status field
      ));

      // userLoggedIn = true;
      Provider.of<ItemStoreProvider>(context, listen: false).assignUser(Renter(
        id: jointUuid,
        email: email,
        name: name,
        type: 'USER',
        size: 0,
        address: '',
        countryCode: '',
        phoneNum: '',
        favourites: [''],
        verified: 'not started',
        imagePath: '',
        creationDate: DateFormat('yyyy-MM-dd – kk:mm').format(DateTime.now()),
        location: '', // <-- Add this line
        bio: '',
        followers: [],
        following: [],
        status: 'not active', 
        avgReview: 0, 
        lastLogin: DateTime.now(),
        vacations: [], // <-- Added status field
      ));
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
                          if (userCredential.value != null && context.mounted) {
                            hideProgressDialogue(context);

                            handleNewLogIn(userCredential.value.user!.email,
                                userCredential.value.user!.displayName);
                            // Navigator.pop(context);
                            showDialog(
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
                                      // Navigator.pop(context);
                                      Navigator.of(context)
                                          .popUntil((route) => route.isFirst);
                                      // Navigator.push(context, MaterialPageRoute(builder: (BuildContext context) => const Profile()));
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
                                    // Flexible(child: Text("Successfully logged in", style: TextStyle(fontSize: 22, color: Colors.black))),
                                    Flexible(
                                        child: StyledHeading(
                                            "Successfully logged in",
                                            weight: FontWeight.normal)),
                                  ],
                                ),
                              ),
                            );
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
    // Commented out below 2 lines and replaced with profile/email googleAuth, seems to work and no longer getting platform exception
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;
    // GoogleSignInAuthentication? googleAuth = await (await GoogleSignIn(
    //   scopes: ["profile", "email"],
    // ).signIn())
    //     ?.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    return await FirebaseAuth.instance.signInWithCredential(credential);
  } on Exception catch (e) {
    // TODO
    print('exception->$e');
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
