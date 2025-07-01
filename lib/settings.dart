import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.width * 0.2,
        title: const Text('Settings'),
      ),
      body: const Center(
        child: Text(
          'This is the dummy Settings page.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}