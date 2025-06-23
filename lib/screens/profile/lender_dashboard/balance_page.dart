import 'package:flutter/material.dart';

class BalancePage extends StatelessWidget {

  const BalancePage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const double balance = 1234.56; // Example balance value
    const payouts = [ ]; // Example payouts data
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        title: const Text(
          "BALANCE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  '${balance.toStringAsFixed(2)} tbh',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Available Balance',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'BANK ACCOUNT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Add bank account logic here
                },
                child: const Text(
                  'Add',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          const SizedBox(height: 8),
          const Text(
            'PAYOUTS',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          ...payouts.map((payout) => ListTile(
                title: Text('Payout: ${payout.amount.toStringAsFixed(2)} tbh'),
                subtitle: Text(
                  '${payout.date.day}/${payout.date.month}/${payout.date.year}',
                ),
                trailing: Text(
                  payout.status,
                  style: TextStyle(
                    color: payout.status == 'Completed'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class Payout {
  final double amount;
  final DateTime date;
  final String status;

  Payout({
    required this.amount,
    required this.date,
    required this.status,
  });
}