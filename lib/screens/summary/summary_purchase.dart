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
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: const StyledTitle('REVIEW AND PAY'),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon:
              Icon(Icons.chevron_left, size: width * 0.08, color: Colors.black),
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
                child:
                    Icon(Icons.close, size: width * 0.06, color: Colors.black),
              )),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(width * 0.05),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item Summary Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SummaryImageWidget(widget.item),
                    const SizedBox(height: 20),

                    // Purchase Details Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.shopping_bag_outlined,
                              size: width * 0.06, color: Colors.grey.shade600),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const StyledBody('Purchase Details',
                                    fontSize: 12, color: Colors.grey),
                                const SizedBox(height: 4),
                                StyledBody(
                                  'Buying ${widget.item.name}',
                                  fontSize: width * 0.04,
                                  weight: FontWeight.w600,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Location Section (if available)
                    if (Provider.of<ItemStoreProvider>(context, listen: false)
                                .renter
                                .location !=
                            null &&
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .renter
                            .location
                            .toString()
                            .trim()
                            .isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.location_pin,
                                size: width * 0.06,
                                color: Colors.grey.shade600),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const StyledBody('Delivery Location',
                                      fontSize: 12, color: Colors.grey),
                                  const SizedBox(height: 4),
                                  StyledBody(
                                    Provider.of<ItemStoreProvider>(context,
                                            listen: false)
                                        .renter
                                        .location
                                        .toString(),
                                    fontSize: width * 0.04,
                                    weight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Price Details Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const StyledHeading('Purchase Summary',
                        weight: FontWeight.bold),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Purchase Price',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.035,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${NumberFormat('#,###').format(widget.price)}${globals.thb}',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: width * 0.06,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    PurchasePriceSummary(widget.price),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding:
                EdgeInsets.symmetric(vertical: 20, horizontal: width * 0.05),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
                onPressed: () async {
                  // _showPaymentMethodBottomSheet(context);
                  // Use Stripe payment logic similar to renters_rentals_page
                  try {
                    print(
                        'Starting payment process for amount: ${widget.item.buyPrice}');
                    bool success = await StripeService.instance
                        .makeCardPayment(widget.item.buyPrice);

                    print('Payment result: $success');

                    if (success) {
                      print(
                          'Payment successful, proceeding with notifications and records');
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
                        status:
                            'paid', // Set to paid since payment was successful
                      );

                      Provider.of<ItemStoreProvider>(context, listen: false)
                          .addItemRenter(newItemRenter);

                      // Create ledger entry
                      ItemStoreProvider itemStore =
                          Provider.of<ItemStoreProvider>(context,
                              listen: false);
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
                child: const Text(
                  'MAKE PAYMENT',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ),
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
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      onPressed: () {
        Navigator.of(context).popUntil((route) => route.isFirst);
      },
      child: const Text(
        "CONTINUE",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );

    // Create AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      title: const Center(
        child: Text(
          "Payment Successful!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: width * 0.25,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              "Your ${itemType.toLowerCase()} has been purchased successfully.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Please check your email for purchase confirmation and delivery details.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: okButton,
        ),
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
