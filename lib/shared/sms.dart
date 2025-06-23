// import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:revivals/shared/send_sms.dart';

class Sms extends StatelessWidget {
  const Sms({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(Icons.dangerous),
          onPressed: () async {
            try {
              await openSMS(
                phone: '+66 (62) 327-1758',
                text: 'Initial text',
              );
            } on Exception {
              if (context.mounted) {
                showDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                          title: const Text("Attention"),
                          content: const Padding(
                            padding: EdgeInsets.only(top: 5),
                            child: Text(
                              'We did not find the «SMS Messenger» application on your phone, please install it and try again»',
                            ),
                          ),
                          actions: [
                            CupertinoDialogAction(
                              child: const Text('Close'),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ],
                        ));
              }
            }
          },
        )
      ],
    );
  }
}
