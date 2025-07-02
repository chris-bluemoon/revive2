import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revivals/screens/authenticate/register_location.dart';
import 'package:revivals/shared/loading.dart';
import 'package:revivals/shared/smooth_page_route.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class RegisterName extends StatefulWidget {

  const RegisterName({required this.email, super.key});

  final String email;

  @override
  State<RegisterName> createState() => _RegisterName();
}

class _RegisterName extends State<RegisterName> {
  bool found = false;
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String name = '';
  String error = 'Error: ';
  bool ready = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return loading ? const Loading() : Scaffold(
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
                'What\'s your name?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Please enter a nickname',
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
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          maxLength: 12,
                          decoration: InputDecoration(
                            hintText: 'Max 12 chars',
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
                          validator: (val) => val!.isEmpty ? 'Enter your name' : null,
                          onChanged: (val) {
                            setState(() {
                              name = val;
                              ready = val.isNotEmpty;
                            });
                          },
                        ),
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
                              if (_formKey.currentState!.validate()) {
                                HapticFeedback.lightImpact();
                                Navigator.push(
                                  context,
                                  SmoothPageRoute(
                                    child: RegisterLocation(email: widget.email, name: name),
                                  ),
                                );
                              }
                            } : null,
                            child: const Text(
                              'Continue',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        if (error != 'Error: ') ...[
                          const SizedBox(height: 16.0),
                          Text(
                            error,
                            style: const TextStyle(color: Colors.red, fontSize: 14.0),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}