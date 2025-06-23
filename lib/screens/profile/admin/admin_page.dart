import 'package:flutter/material.dart';
import 'package:revivals/shared/item_results.dart';

class AdminPage extends StatelessWidget {
  const AdminPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'ADMIN PANEL',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.rate_review),
            title: const Text('Review Submissions'),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) => const ItemResults('status', 'submitted')
              ));
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}