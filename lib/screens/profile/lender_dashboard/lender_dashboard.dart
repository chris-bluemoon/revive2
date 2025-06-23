import 'package:flutter/material.dart';
import 'package:revivals/screens/profile/lender_dashboard/balance_page.dart';
import 'package:revivals/screens/profile/lender_dashboard/earnings_page.dart';
import 'package:revivals/screens/profile/lender_dashboard/insights_page.dart';
import 'package:revivals/screens/profile/lender_dashboard/lenders_rentals_page.dart';
import 'package:revivals/shared/styled_text.dart';

class LenderDashboard extends StatelessWidget {
  const LenderDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const StyledTitle(
          "LENDER DASHBOARD",
        ),
        elevation: 0,
      ),
      body: ListView(
        padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.06),
        children: [
          ListTile(
            leading: const Icon(Icons.account_balance_wallet),
            title: const Text('Balance'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const BalancePage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.attach_money),
            title: const Text('Earnings'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const EarningsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.insights),
            title: const Text('Insights'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const InsightsPage(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.swap_horiz),
            title: const Text('Transfers'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.assignment),
            title: const Text('Rentals/Purchases'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LendersRentalsPage(),
                ),
              );
            }
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.beach_access),
            title: const Text('Vacation Mode'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
