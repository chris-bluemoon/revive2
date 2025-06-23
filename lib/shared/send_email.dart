// // import 'dart:developer';

// import 'package:flutter/material.dart';
// import 'package:mailer/mailer.dart';
// import 'package:mailer/smtp_server.dart';
// import 'package:revivals/shared/secure_repo.dart';

// class EmailComposer extends StatefulWidget {
//   EmailComposer({super.key});

//   MyStore myStore = MyStore();

//   Future<void> sendEmail2() async {
//     Future myToken = MyStore.readFromStore();
//     String? myvar = await MyStore.readFromStore();
//     final smtpServer = SmtpServer('smtp.gmail.com',
//         username: 'uneartheduser@gmail.com', password: myvar);

//     final message = Message()
//       ..from = const Address('uneartheduser@gmail.com', 'Unearthed User')
//       ..recipients.add('chris.milner@gmail.com')
//       ..subject = 'test'
//       ..text = 'test';

//     try {
//       final sendReport = await send(message, smtpServer);
//       // print('Message sent: ${sendReport.sent}');

//       // Additional code for feedback to the user
//     } catch (e) {
//       // Additional code for error handling
//     }
//   }

//   @override
//   _EmailComposerState createState() => _EmailComposerState();
// }

// class _EmailComposerState extends State<EmailComposer> {
//   final TextEditingController _toController = TextEditingController();
//   final TextEditingController _subjectController = TextEditingController();
//   final TextEditingController _bodyController = TextEditingController();
//   final TextEditingController _tokenController = TextEditingController();

//   Future<void> sendEmail() async {
//     Future myToken = MyStore.readFromStore();
//     String? myvar = await MyStore.readFromStore();

//     final smtpServer = SmtpServer('smtp.gmail.com',
//         username: 'uneartheduser@gmail.com', password: myvar);

//     final message = Message()
//       ..from = const Address('uneartheduser@gmail.com', 'Unearthed User')
//       ..recipients.add(_toController.text)
//       ..subject = _subjectController.text
//       ..text = _bodyController.text;

//     try {
//       final sendReport = await send(message, smtpServer);
//       // print('Message sent: ${sendReport.sent}');

//       // Additional code for feedback to the user
//     } catch (e) {
//       // Additional code for error handling
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Compose Email'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             TextField(
//               controller: _toController,
//               decoration: const InputDecoration(
//                 labelText: 'To',
//               ),
//             ),
//             TextField(
//               controller: _subjectController,
//               decoration: const InputDecoration(
//                 labelText: 'Subject',
//               ),
//             ),
//             TextField(
//               controller: _bodyController,
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//               decoration: const InputDecoration(
//                 labelText: 'Body',
//               ),
//             ),
//             TextField(
//               controller: _tokenController,
//               maxLines: null,
//               keyboardType: TextInputType.multiline,
//               decoration: const InputDecoration(
//                 labelText: 'token',
//               ),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 final myToken = _tokenController.text;
//                 MyStore.writeToStore(myToken);
//               },
//               child: const Text('Store Token'),
//             ),
//             ElevatedButton(
//               onPressed: () async {
//                 String? myvar = await MyStore.readFromStore();
//               },
//               child: const Text('Get Token'),
//             ),
//             ElevatedButton(
//               onPressed: sendEmail,
//               child: const Text('Send Email'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
