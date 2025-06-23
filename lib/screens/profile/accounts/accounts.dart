import 'package:flutter/material.dart';
import 'package:revivals/screens/profile/accounts/accounts_history_list.dart';
import 'package:revivals/screens/profile/accounts/accounts_insights.dart';
import 'package:revivals/shared/styled_text.dart';

class Accounts extends StatelessWidget {
  const Accounts( {super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          // automaticallyImplyLeading: false,
          bottom: TabBar(
            // indicatorColor: Colors.black,
            // labelColor: Colors.black,
            labelStyle: TextStyle(fontSize: width*0.03),
            tabs: const [
              Tab(text: 'HISTORY'),
              Tab(text: 'INSIGHTS'),
            ],
          ),
          title: const StyledTitle('MY ACCOUNTS'),
                      leading: IconButton(
          icon: Container(
              padding: EdgeInsets.fromLTRB(width * 0.02, 0, 0, 0),
              child: Icon(Icons.chevron_left, size: width*0.08),
          ), 
          onPressed: () {
              Navigator.pop(context);
          },
        ),
        ),
        body:  const TabBarView(
          children: [
            AccountsHistoryList(),
            AccountsInsightsPage(),
          ] 
        ),
      ),
    );
  }
}