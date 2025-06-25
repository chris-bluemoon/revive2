import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/styled_text.dart';

import 'vacation_dates_page.dart';

class VacationPage extends StatefulWidget {
  const VacationPage({super.key});

  @override
  State<VacationPage> createState() => _VacationPageState();
}

class _VacationPageState extends State<VacationPage> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ItemStoreProvider>(context);
    final vacations = provider.renter.vacations;
    final dateFormat = DateFormat('MMM d, yyyy');
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const StyledTitle('VACATIONS'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Going somwhere? Let us know and your listings will be unavailable to rent during your chosen vacation period so you can relax and enjoy your holiday!',
              style: TextStyle(fontSize: 16, color: Colors.grey[800]),
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 32),
            if (vacations.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: vacations.length,
                  itemBuilder: (context, index) {
                    final vacation = vacations[index];
                    final key = ValueKey(
                      '${vacation['startDate']?.millisecondsSinceEpoch}_${vacation['endDate']?.millisecondsSinceEpoch}',
                    );
                    return Dismissible(
                      key: key,
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) {
                        // 1. Update UI and provider synchronously
                        final provider = Provider.of<ItemStoreProvider>(context, listen: false);
                        final updatedVacations = List<Map<String, DateTime>>.from(provider.renter.vacations);
                        updatedVacations.removeAt(index);
                        final updatedRenter = provider.renter.copyWith(vacations: updatedVacations);
                        provider.saveRenterLocal(updatedRenter);

                        // 2. Then update Firebase asynchronously (no await here)
                        Future.microtask(() async {
                          Provider.of<ItemStoreProvider>(context, listen: false).saveRenter(updatedRenter);
                          // await FirebaseFirestore.instance
                          //     .collection('renters')
                          //     .doc(updatedRenter.id)
                          //     .set(updatedRenter.toFirestore(), SetOptions(merge: true));
                        });
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        color: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero,
                        ),
                        child: ListTile(
                          title: Text(
                            '${dateFormat.format(vacation['startDate']!)} - ${dateFormat.format(vacation['endDate']!)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 24),
                child: Text(
                  'No vacation periods set.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VacationDatesPage()),
                  );
                  if (result != null &&
                      result is Map &&
                      result['start'] != null &&
                      result['end'] != null) {
                    final updatedVacations = List<Map<String, DateTime>>.from(vacations)
                      ..add({
                        'startDate': result['start'],
                        'endDate': result['end'],
                      });
                    final updatedRenter = provider.renter.copyWith(vacations: updatedVacations);
                    provider.saveRenter(updatedRenter);
                  }
                },
                child: const Text('ADD VACTION PERIOD')
              ),
            ),
          ],
        ),
      ),
    );
  }
}