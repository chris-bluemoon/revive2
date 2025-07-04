import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revivals/screens/profile/renter_dashboard/renters_transactions_page.dart';
import 'package:revivals/shared/smooth_page_route.dart';
import 'package:revivals/shared/styled_text.dart';

class RenterDashboard extends StatelessWidget {
  const RenterDashboard({super.key});

  void _navigateWithFeedback(BuildContext context, Widget destination) {
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      SmoothTransitions.luxury(destination),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const StyledTitle(
          "RENTER DASHBOARD",
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 20),
        children: [
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              leading: const Icon(Icons.assignment, color: Colors.black87),
              title: const Text('Rentals/Purchases', style: TextStyle(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.chevron_right, color: Colors.black54),
              onTap: () => _navigateWithFeedback(context, const RentersRentalsPage()),
            ),
          ),
        ],
      ),
    );
  }
}
