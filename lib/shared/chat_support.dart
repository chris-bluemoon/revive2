import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:revivals/shared/line.dart';

/// Opens a chat with support via LINE app
/// Shows appropriate error dialog if the operation fails
Future<void> chatWithUsLine(BuildContext context) async {
  try {
    await openLineApp(context);
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
        ),
      );
    }
  }
}
