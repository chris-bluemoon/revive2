import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class InsightsPage extends StatelessWidget {
  const InsightsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: true);
    final ledgers = itemStore.ledgers;

    // Most rented item logic
    final Map<String, int> itemCounts = {};
    for (var ledger in ledgers) {
      if (ledger.type == 'rental') {
        itemCounts[ledger.desc] = (itemCounts[ledger.desc] ?? 0) + 1;
      }
    }
    String mostRentedItem = '';
    int mostRentedCount = 0;
    if (itemCounts.isNotEmpty) {
      final sorted = itemCounts.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      mostRentedItem = sorted.first.key;
      mostRentedCount = sorted.first.value;
    }

    // Earnings by month
    final Map<String, int> earningsByMonth = {};
    int rentalCount = 0;
    int rentalTotal = 0;
    for (var ledger in ledgers) {
      if (ledger.type == 'rental') {
        final date = DateTime.parse(ledger.date);
        final monthKey = DateFormat('yyyy-MM').format(date);
        earningsByMonth[monthKey] = (earningsByMonth[monthKey] ?? 0) + (ledger.amount as int);
        rentalTotal += ledger.amount as int;
        rentalCount++;
      }
    }

    final double avgRentalPrice = rentalCount > 0 ? rentalTotal / rentalCount : 0;

    final List<MonthEarnings> data = earningsByMonth.entries
        .map((e) => MonthEarnings(DateFormat('yyyy-MM').parse(e.key), e.value))
        .toList()
      ..sort((a, b) => a.monthDate.compareTo(b.monthDate));

    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const StyledTitle('INSIGHTS'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ledgers.isEmpty
            ? const Center(child: Text('No data available.'))
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Most Rented Item:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    mostRentedItem.isNotEmpty
                        ? '$mostRentedItem ($mostRentedCount rentals)'
                        : 'No rentals yet.',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Average Rental Price: ฿${avgRentalPrice.toStringAsFixed(2)}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Earnings by Month',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  SizedBox(
                    height: 220,
                    child: SfCartesianChart(
                      primaryXAxis: const CategoryAxis(),
                      series: <CartesianSeries<MonthEarnings, String>>[
                        ColumnSeries<MonthEarnings, String>(
                          dataSource: data,
                          xValueMapper: (MonthEarnings me, _) => me.month,
                          yValueMapper: (MonthEarnings me, _) => me.earnings,
                          dataLabelSettings: const DataLabelSettings(isVisible: true),
                          color: Colors.blue,
                          // Add baht symbol to data labels
                          dataLabelMapper: (MonthEarnings me, _) => '฿${me.earnings}',
                        )
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class MonthEarnings {
  final DateTime monthDate;
  final int earnings;
  MonthEarnings(this.monthDate, this.earnings);

  String get month => DateFormat('MMM yy').format(monthDate);
}