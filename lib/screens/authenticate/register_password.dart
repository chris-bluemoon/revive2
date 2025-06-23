import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:password_strength_checker/password_strength_checker.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/services/auth.dart';
import 'package:revivals/shared/loading.dart';
import 'package:revivals/shared/styled_text.dart';
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
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

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

    void handleNewLogIn(String email, String name) {
      List<Renter> renters =
          Provider.of<ItemStoreProvider>(context, listen: false).renters;

      for (Renter r in renters) {
        if (r.email == email) {
          found = true;

          Provider.of<ItemStoreProvider>(context, listen: false)
              .setCurrentUser();
          break; // fixed this
        } else {
          found = false;
        }
      }
      if (found == false) {
        String jointUuid = uuid.v4();
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
        );
        
        Provider.of<ItemStoreProvider>(context, listen: false).addRenter(newRenter);

      }

      Provider.of<ItemStoreProvider>(context, listen: false)
          .populateFavourites();

      // Provider.of<ItemStoreProvider>(context, listen: false).populateFittings();
    }

    // NEW PASSWORD CODE

    return loading
        ? const Loading()
        : Scaffold(
            key: _formKey,
            appBar: AppBar(
              toolbarHeight: width * 0.2,
              // centerTitle: true,
              title: const StyledTitle('REGISTER PASSWORD'),
              leading: IconButton(
                icon: Icon(Icons.chevron_left, size: width * 0.08),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            body: Padding(
              padding:
                  EdgeInsets.symmetric(vertical: 0, horizontal: width * 0.04),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StyledHeading(
                    'Create a password that contains:',
                    weight: FontWeight.normal,
                  ),
                  SizedBox(height: width * 0.01),
                  const StyledHeading('- At least 6 characters',
                      weight: FontWeight.normal),
                  const StyledHeading('- Both letters and numbers',
                      weight: FontWeight.normal),
                  Padding(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (value) => checkPassword(value),
                                obscureText: (makeVisible) ? false : true,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Password',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12.0)),
                                    borderSide: BorderSide(color: Colors.grey),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12.0)),
                                    borderSide: BorderSide(color: Colors.black),
                                  ),
                                ),
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  setState(() {
                                    makeVisible = !makeVisible;
                                  });
                                },
                                icon: (makeVisible)
                                    ? const Icon(Icons.visibility)
                                    : const Icon(Icons.visibility_off))
                          ],
                        ),
                        const SizedBox(
                          height: 30,
                        ),
                        // The strength indicator bar
                        if (strength > 0)
                          Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: strength <= 1 / 4
                                  ? Colors.red
                                  : strength == 2 / 4
                                      ? Colors.yellow
                                      : strength == 3 / 4
                                          ? Colors.yellow
                                          : Colors.green,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.white,
                              ),
                              child: LinearProgressIndicator(
                                borderRadius: BorderRadius.circular(5),
                                value: strength,
                                backgroundColor: Colors.white,
                                color: strength <= 1 / 4
                                    ? Colors.red
                                    : strength == 2 / 4
                                        ? Colors.yellow
                                        : strength == 3 / 4
                                            ? Colors.yellow
                                            : Colors.green,
                                minHeight: 15,
                              ),
                            ),
                          ),
                        SizedBox(
                          height: width * 0.1,
                        ),

                        // The message about the strength of the entered password
                        SizedBox(
                          height: width * 0.1,
                        ),
                        // This button will be enabled if the password strength is medium or beyond
                      ],
                    ),
                  )
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
                  //           ],
                  //         ))),
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
                          child: StyledHeading('CREATE ACCOUNT',
                              weight: FontWeight.bold, color: Colors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(width: 5),
                  if (ready)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          // if (_formKey.currentState!.validate()) {
                          if (strength == 1) {
                            setState(() => loading = true);
                            dynamic result =
                                await _auth.registerWithEmailAndPassword(
                                    widget.email, password);
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
                                        Navigator.of(context).pushReplacementNamed('/login');
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
  child: Text(
    "Email already exists, try logging in",
    textAlign: TextAlign.center,
    style: TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 18,
      color: Colors.black,
    ),
  ),
),
                                ),
                              );
                              }
                              setState(() {
                                _formKey.currentState!.reset();
                              });
                            } else {
                              handleNewLogIn(widget.email, widget.name);
if(context.mounted) {
                              Navigator.of(context)
                                  // .popUntil((route) => route.isFirst);}
                                  .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);}
                            }
                          }
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
                          child: StyledHeading('CREATE ACCOUNT',
                              color: Colors.white),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
  }
}
