import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';

// Replace this with your actual data model and fetching logic
class LedgerEntry {
  final String id;
  final String description;
  final double amount;
  final DateTime date;

  LedgerEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
  });
}

class EarningsPage extends StatelessWidget {
  const EarningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    final String userId = itemStore.renter.id;

    // Get earnings from the itemStore ledger for this user
    log('Ledger entries for user $userId and count is ${itemStore.ledgers.length}');
    for (var entry in itemStore.ledgers) {
      log('Entry: ${entry.id}, Desc: ${entry.desc}, Amount: ${entry.amount}, Date: ${entry.date}');
    }
    final earnings = itemStore.ledgers
        .where((entry) => entry.owner == userId)
        .toList();

    int total = earnings.fold(0, (sum, entry) => sum + entry.amount);

    // Group earnings by month
    final Map<String, List<dynamic>> earningsByMonth = {};
    for (var entry in earnings) {
      final date = DateTime.parse(entry.date);
      final monthKey = DateFormat('MMMM yyyy').format(date);
      earningsByMonth.putIfAbsent(monthKey, () => []).add(entry);
    }

    return Scaffold(
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
        title: const Text(
          "EARNINGS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: earnings.isEmpty
          ? const Center(child: Text('No earnings found.'))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total Earnings: \$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    children: earningsByMonth.entries.expand((entry) {
                      final month = entry.key;
                      final monthEarnings = entry.value;
                      return [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                          child: Text(
                            month,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        ...monthEarnings.map<Widget>((e) {
                          final formattedDate = DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(e.date));
                          return ListTile(
                            title: Text(e.desc),
                            subtitle: Text(formattedDate),
                            trailing: Text(
                              '\$${e.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                        const Divider(),
                      ];
                    }).toList(),
                  ),
                ),
              ],
            ),
    );
  }
}