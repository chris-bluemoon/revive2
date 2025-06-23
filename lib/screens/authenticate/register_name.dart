import 'package:flutter/material.dart';
import 'package:revivals/screens/authenticate/register_location.dart';
import 'package:revivals/services/auth.dart';
import 'package:revivals/shared/constants.dart';
import 'package:revivals/shared/loading.dart';
import 'package:revivals/shared/styled_text.dart';
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
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String name = '';
  String error = 'Error: ';
  bool ready = false;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return loading ? const Loading() : Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        // centerTitle: true,
        title: const StyledTitle('REGISTER NAME'),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: width * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StyledHeading(
              'Enter your name',
              weight: FontWeight.normal,
            ),
            Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
                child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 20),
                        TextFormField(
                          decoration: textInputDecoration.copyWith(
                            hintText: 'Name',
                          ),
                          validator: (val) =>
                              val!.isEmpty ? 'Enter your name' : null,
                          onChanged: (val) {
                            setState(() {
                              name = val;
                              ready = true;
                              if (val.isEmpty) {ready = false;}
                            });
                          },
                        ),
                      ],
                    ))),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
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
                if (!ready) Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                    },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                      side: const BorderSide(width: 1.0, color: Colors.black),
                      ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StyledHeading('CONTINUE', weight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                if (ready) Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => (RegisterLocation(email: widget.email, name: name))));
                        // Navigator.of(context).push(MaterialPageRoute(builder: (context) => (RegisterPassword(email: widget.email, name: name))));
                      }
                      // ready = false;
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                      side: const BorderSide(width: 1.0, color: Colors.black),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StyledHeading('CONTINUE', color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),   
      // bottomNavigationBar: Container(
      //   // height: 300,
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
      //     boxShadow: [
      //       BoxShadow(
      //         color: Colors.black.withOpacity(0.2),
      //         blurRadius: 10,
      //         spreadRadius: 3,
      //       )
      //     ],
      //   ),
      //   padding: const EdgeInsets.all(10),
      //   child: Row(
      //     children: [
      //       Expanded(
      //         child: OutlinedButton(
      //           onPressed: () async {
      //             if (_formKey.currentState!.validate()) {
      //               Navigator.of(context).push(MaterialPageRoute(builder: (context) => (RegisterPassword(email: widget.email, name: name))));
      //             }
      //           },
      //           style: OutlinedButton.styleFrom(
      //             padding: const EdgeInsets.all(10),
      //             backgroundColor: Colors.black,
      //             shape: RoundedRectangleBorder(
      //               borderRadius: BorderRadius.circular(1.0),
      //             ),
      //             side: const BorderSide(width: 1.0, color: Colors.black),
      //           ),
      //           child: const StyledHeading('CONTINUE', color: Colors.white),
      //         ),
      //       ),
      //     ],
      //   ),
      // ),
    );
  }
}