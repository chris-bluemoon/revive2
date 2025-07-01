import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/summary/purchase_price_summary.dart';
import 'package:revivals/screens/summary/summary_image_widget.dart';
import 'package:revivals/services/notification_service.dart';
import 'package:revivals/services/stripe_sevice.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class SummaryPurchase extends StatefulWidget {
  const SummaryPurchase(this.item, this.startDate, this.endDate, this.noOfDays,
      this.price, this.status, this.symbol,
      {super.key});

  final Item item;
  final DateTime startDate;
  final DateTime endDate;
  final int noOfDays;
  final int price;
  final String status;
  final String symbol;

  @override
  State<SummaryPurchase> createState() => _SummaryPurchaseState();
}

class _SummaryPurchaseState extends State<SummaryPurchase> {
  // final int i;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    // int pricePerDay = widget.price~/widget.noOfDays;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: const StyledTitle('REVIEW AND PAY'),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              onPressed: () =>
                  {Navigator.of(context).popUntil((route) => route.isFirst)},
              icon: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, width * 0.01, 0),
                child: Icon(Icons.close, size: width * 0.06),
              )),
        ],
        // bottom: PreferredSize(
        //     preferredSize: const Size.fromHeight(4.0),
        //     child: Container(
        //       color: Colors.grey[300],
        //       height: 1.0,
        //     )),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          SummaryImageWidget(widget.item),
          const SizedBox(height: 20),
          // Row(
          //   children: [
          //     const SizedBox(width: 20),
          //     const Icon(Icons.calendar_month_outlined),
          //     const SizedBox(width: 20),
          //     StyledBody(DateFormat.yMMMd().format(widget.startDate)),

          //   ],),
          // const SizedBox(height: 20),
          // const Row(
          //   children: [
          //     SizedBox(width: 20),
          //     Icon(Icons.location_pin),
          //     SizedBox(width: 20),
          //     Text('Bangkok, Thailand', style: TextStyle(fontSize: 14)),
          //   ],),
          const SizedBox(height: 40),
          Center(
            child: Container(
              color: Colors.grey[200],
              height: 50,
              width: 300,
              padding: const EdgeInsets.all(8),
              child: Center(
                child: StyledHeading(
                    'Buying ${widget.item.name} for ${NumberFormat('#,###').format(widget.price)}${globals.thb}',
                    weight: FontWeight.normal),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Divider(
            height: 1,
            indent: 50,
            endIndent: 50,
            color: Colors.grey[200],
          ),
          // Remove delivery section
          Divider(
            height: 1,
            indent: 50,
            endIndent: 50,
            color: Colors.grey[300],
          ),
          PurchasePriceSummary(widget.price),
          const Expanded(child: SizedBox()),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Padding(
                padding: const EdgeInsets.all(20),
                child: ElevatedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                    side: const BorderSide(width: 1.0, color: Colors.black),
                  ),
                  onPressed: () async {
                    // Use Stripe payment logic similar to renters_rentals_page
                    try {
                      print('Starting payment process for amount: ${widget.item.buyPrice}');
                      bool success = await StripeService.instance
                          .makePayment(widget.item.buyPrice);
                      
                      print('Payment result: $success');
                      
                      if (success) {
                        print('Payment successful, proceeding with notifications and records');
                        // Send notification to the owner
                        NotificationService.sendNotification(
                          notiType: NotiType.payment,
                          item: widget.item.name,
                          notiReceiverId: widget.item.owner,
                        );
                        
                        if (!context.mounted) return;
                        
                        // Create the item renter record
                        String email =
                            Provider.of<ItemStoreProvider>(context, listen: false)
                                .renter
                                .email;
                        String startDateText = widget.startDate.toString();
                        String endDateText = widget.endDate.toString();
                        
                        final newItemRenter = ItemRenter(
                          id: uuid.v4(),
                          renterId: email,
                          ownerId: widget.item.owner,
                          itemId: widget.item.id,
                          transactionType: 'purchase',
                          startDate: startDateText,
                          endDate: endDateText,
                          price: widget.item.buyPrice,
                          status: 'paid', // Set to paid since payment was successful
                        );
                        
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .addItemRenter(newItemRenter);
                        
                        // Create ledger entry
                        ItemStoreProvider itemStore =
                            Provider.of<ItemStoreProvider>(context, listen: false);
                        Ledger newLedgerEntry = Ledger(
                          id: uuid.v4(),
                          itemRenterId: newItemRenter.id,
                          owner: widget.item.owner,
                          date: DateTime.now().toIso8601String(),
                          type: "purchase",
                          desc: "Payment for purchase of ${widget.item.name}",
                          amount: widget.item.buyPrice,
                          balance: itemStore.getBalance() + widget.item.buyPrice,
                        );
                        itemStore.addLedger(newLedgerEntry);
                        
                        // Show success dialog
                        showAlertDialog(context, widget.item.type, width);
                      } else {
                        print('Payment failed - StripeService returned false');
                        if (!context.mounted) return;
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment failed. Please try again.'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e, stackTrace) {
                      print('Error in payment process: $e');
                      print('Stack trace: $stackTrace');
                      
                      if (!context.mounted) return;
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Payment error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.01),
                    child: const StyledHeading('MAKE PAYMENT', color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

//showAlertDialog(BuildContext context) {
//  // Create button
//  Widget okButton = ElevatedButton(
//    child: const Center(child: Text("OK")),
//    onPressed: () {
//      // Navigator.of(context).pop();
//      Navigator.of(context).popUntil((route) => route.isFirst);
//    },
//  );
//    // Create AlertDialog
//  AlertDialog alert = AlertDialog(
//    title: const Center(child: Text("Congratulations")),
//    content: const Text("      Your item is being prepared"),
//    actions: [
//      okButton,
//    ],
//                shape: const RoundedRectangleBorder(
//              borderRadius: BorderRadius.all(Radius.circular(20.0)),
//            ),
//  );
//    showDialog(
//    context: context,
//    builder: (BuildContext context) {
//      return alert;
//    },
//  );
//}
  showAlertDialog(BuildContext context, String itemType, double width) {
    // Create button
    Widget okButton = ElevatedButton(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(color: Colors.white),
        foregroundColor: Colors.white, //change background color of button
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        side: const BorderSide(width: 1.0, color: Colors.black),
      ),
      onPressed: () {
        // Navigator.of(context).pop();
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: const Center(child: StyledBody("OK", color: Colors.white)),
    );
    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      title: const Center(child: StyledHeading("Thank you!")),
      content: SizedBox(
        height: width * 0.15,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBody("Your $itemType is being prepared,",
                    weight: FontWeight.normal),
                // Text("Your $itemType is being prepared,"),
                // Text("please check your email for confirmation."),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBody("Please check your", weight: FontWeight.normal),
                // Text("Your $itemType is being prepared,"),
                // Text("please check your email for confirmation."),
              ],
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StyledBody("email for details.", weight: FontWeight.normal),
                // Text("Your $itemType is being prepared,"),
                // Text("please check your email for confirmation."),
              ],
            ),
          ],
        ),
      ),
      actions: [
        okButton,
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
