// import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:revivals/shared/whatsapp.dart';

class SendWhatsapp extends StatelessWidget {
  const SendWhatsapp({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () async {
          try {
            await openWhatsApp(
              phone: '+65 91682725',
              text: 'Hello Unearthed Support...',
            );
          } on Exception catch (e) {
            if (context.mounted) {
              showDialog(
                  context: context,
                  builder: (context) => CupertinoAlertDialog(
                        title: const Text("Attention"),
                        content: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(e.toString()),
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
        icon: const Icon(Icons.account_box),
      ),
    );
  }
}
