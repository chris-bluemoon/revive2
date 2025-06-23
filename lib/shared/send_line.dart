// import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:revivals/shared/line.dart';

class SendLine extends StatelessWidget {
  const SendLine({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () async {
          try {
            await openLineApp(context
                // phone: '+660623271758',
                // text: 'Initial text',
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
