import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/summary/summary_purchase.dart';
import 'package:revivals/screens/to_rent/rent_this_with_date_selecter.dart';
import 'package:revivals/shared/smooth_page_route.dart';

class ToRentBottomBar extends StatelessWidget {
  final Item item;
  final bool isOwner;
  final bool isSubmission;
  const ToRentBottomBar({required this.item, required this.isOwner, required this.isSubmission, super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final store = Provider.of<ItemStoreProvider>(context, listen: false);
    if (isSubmission) {
      // Admin view: show ACCEPT/REJECT buttons
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, -4), // Drop shadow above the bar
            ),
          ],
          border: const Border(
            top: BorderSide(
              color: Color(0xFFE0E0E0), // Light grey border
              width: 1.5,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(width * 0.04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: width * 0.04),
                  ),
                  onPressed: () {
                    item.status = 'accepted';
                    store.saveItem(item);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('ACCEPT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              SizedBox(width: width * 0.04),
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: width * 0.04),
                  ),
                  onPressed: () {
                    item.status = 'denied';
                    store.saveItem(item);
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('REJECT', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      );
    } else if (!isOwner) {
      // Normal user view: show rent/buy buttons
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.12),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, -4), // Drop shadow above the bar
            ),
          ],
          border: const Border(
            top: BorderSide(
              color: Color(0xFFE0E0E0), // Light grey border
              width: 1.5,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(width * 0.04),
          child: Row(
            children: [
              // Left half: empty or BUY button
              Expanded(
                child: (item.bookingType == 'buy' || item.bookingType == 'both')
                    ? ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(vertical: width * 0.04),
                        ),
                        onPressed: () {
                          if (!store.loggedIn) {
                            // You may want to show a dialog here
                            return;
                          }
                          Navigator.of(context).push(SmoothTransitions.luxury(
                            SummaryPurchase(
                              item,
                              DateTime.now(),
                              DateTime.now().add(const Duration(days: 1)),
                              1,
                              item.buyPrice,
                              'pending',
                              '\u0e3f', // THB symbol as placeholder
                            ),
                          ));
                        },
                        child: const Text('BUY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      )
                    : const SizedBox.shrink(),
              ),
              SizedBox(width: width * 0.04),
              // Right half: RENT button always
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: EdgeInsets.symmetric(vertical: width * 0.04),
                  ),
                  onPressed: () {
                    if (!store.loggedIn) {
                      // You may want to show a dialog here
                      return;
                    }
                    Navigator.of(context).push(SmoothTransitions.luxury(RentThisWithDateSelecter(item)));
                  },
                  child: Text(
                    'RENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.05, // Slightly bigger and relative to screen width
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      // Owner view: no action buttons
      return const SizedBox.shrink();
    }
  }
}
