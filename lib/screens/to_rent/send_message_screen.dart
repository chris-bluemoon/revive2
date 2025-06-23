import 'package:flutter/material.dart';
import 'package:revivals/screens/to_rent/user_card.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class SendMessageScreen extends StatefulWidget {
  final String to;
  final String subject;

  const SendMessageScreen({
    super.key,
    required this.to,
    required this.subject,
  });

  @override
  State<SendMessageScreen> createState() => _SendMessageScreenState();
}

class _SendMessageScreenState extends State<SendMessageScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        centerTitle: true,
        title: const StyledTitle('MESSAGES'),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
        child: Column(
          children: [
            const Expanded(child: Center(child: StyledBody('No Previous Messages'))),
            UserCard(widget.to, 'At Home'),
            SizedBox(height: width * 0.02),
            // SendMessage2('Can Delete', widget.to, widget.subject, 'No Previous Messages'),
          ],
        )
      )
    );
  }
}
