import 'package:flutter/material.dart';
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
    final earnings = itemStore.ledgers
        .where((entry) => entry.owner == userId)
        .toList();

    int total = earnings.fold(0, (sum, entry) => sum + entry.amount);

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
                  child: ListView.separated(
                    itemCount: earnings.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final entry = earnings[index];
                      return ListTile(
                        title: Text(entry.description),
                        subtitle: Text(
                          '${entry.date.day}/${entry.date.month}/${entry.date.year}',
                        ),
                        trailing: Text(
                          '\$${entry.amount.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}