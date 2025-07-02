import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revivals/screens/authenticate/register_name.dart';
import 'package:revivals/shared/animated_logo_spinner.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Register extends StatefulWidget {
  final Function toggleView;

  const Register({required this.toggleView, super.key});

  @override
  State<Register> createState() => _Register();
}

class _Register extends State<Register> {
  bool found = false;
  // final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = 'Error: ';
  bool ready = false;

  bool isValidEmail(emailString) {
    final bool emailValid = RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(emailString);

    // return emailValid;
    return emailValid;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return loading
        ? Scaffold(
            backgroundColor: Colors.grey.shade50,
            body: const Center(child: FastLogoSpinner()),
          )
        : Scaffold(
            backgroundColor: Colors.grey.shade50,
            appBar: AppBar(
              toolbarHeight: width * 0.2,
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.02),
                  child: TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      widget.toggleView();
                    },
                    child: const Text(
                      'SIGN IN',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                )
              ],
            ),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  Card(
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome to VELAA',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your email to get started',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 32),
                          Form(
                            key: _formKey,
                            child: TextFormField(
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputDecoration(
                                labelText: 'Email Address',
                                labelStyle: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                                hintText: 'Enter your email',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.black),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[300]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.black, width: 2),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              ),
                              validator: (val) =>
                                  (val!.isEmpty || !isValidEmail(val.trim()))
                                      ? 'Enter a valid email'
                                      : null,
                              onChanged: (val) {
                                setState(() {
                                  email = val.trim();
                                  ready = val.isNotEmpty && isValidEmail(val.trim());
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: ready 
                                  ? () async {
                                      HapticFeedback.lightImpact();
                                      if (_formKey.currentState!.validate()) {
                                        Navigator.of(context).push(MaterialPageRoute(
                                          builder: (context) => RegisterName(email: email.toLowerCase()),
                                        ));
                                      }
                                    }
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: ready ? Colors.black : Colors.grey[300],
                                foregroundColor: ready ? Colors.white : Colors.grey[600],
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
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
          );
  }
}
