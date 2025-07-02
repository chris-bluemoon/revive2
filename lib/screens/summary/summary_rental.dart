import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/summary/rental_price_summary.dart';
import 'package:revivals/screens/summary/summary_image_widget.dart';
import 'package:revivals/services/notification_service.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class SummaryRental extends StatefulWidget {
  const SummaryRental(this.item, this.startDate, this.endDate, this.noOfDays,
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
  State<SummaryRental> createState() => _SummaryRentalState();
}

class _SummaryRentalState extends State<SummaryRental> {
  // final int i;

  @override
  Widget build(BuildContext context) {
    int pricePerDay = widget.price ~/ widget.noOfDays;

    Future<void> handleSubmit(String renterId, String ownerId, String itemId,
        String startDate, String endDate, int price, String status) async {
      await Provider.of<ItemStoreProvider>(context, listen: false)
          .addItemRenter(ItemRenter(
        id: uuid.v4(),
        renterId: renterId,
        ownerId: ownerId,
        itemId: itemId,
        transactionType: 'rental',
        startDate: startDate,
        endDate: endDate,
        price: price,
        status: status,
      ));
    }

    double width = MediaQuery.of(context).size.width;

    // Format the pricePerDay with commas and two decimal places
    final formattedPricePerDay =
        NumberFormat("#,##0", "en_US").format(pricePerDay);

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
          icon: Icon(Icons.chevron_left, size: width * 0.08, color: Colors.black),
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
                child: Icon(Icons.close, size: width * 0.06, color: Colors.black),
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
                    
                    // Date Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.calendar_month_outlined, 
                               size: width * 0.06, 
                               color: Colors.grey.shade600),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const StyledBody('Rental Period', 
                                               fontSize: 12, 
                                               color: Colors.grey),
                                const SizedBox(height: 4),
                                StyledBody(
                                  '${DateFormat.yMMMd().format(widget.startDate)} - ${DateFormat.yMMMd().format(widget.endDate)}',
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
                    
                    // Location Section
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
                                                 fontSize: 12, 
                                                 color: Colors.grey),
                                  const SizedBox(height: 4),
                                  StyledBody(
                                    Provider.of<ItemStoreProvider>(context, listen: false)
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
                    const StyledHeading('Rental Details', weight: FontWeight.bold),
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
                          (widget.noOfDays > 1)
                              ? Text(
                                  'Renting for ${widget.noOfDays} days (at $formattedPricePerDay${widget.symbol} per day)',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                )
                              : Text(
                                  'Renting for ${widget.price}${widget.symbol}',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: width * 0.04,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    RentalPriceSummary(
                      widget.price,
                      widget.noOfDays,
                      0, // delivery fee is now always 0
                      widget.symbol,
                    ),
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
            padding: EdgeInsets.symmetric(
                vertical: 20, horizontal: width * 0.05),
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
                  ItemStoreProvider itemStoreProvider =
                      Provider.of<ItemStoreProvider>(context, listen: false);
                  String renterId = itemStoreProvider.renter.id;
                  String startDateText = widget.startDate.toString();
                  String endDateText = widget.endDate.toString();
                  String ownerId = '';
                  for (Renter r in itemStoreProvider.renters) {
                    if (r.id == widget.item.owner) {
                      ownerId = r.id;
                    }
                  }
                  NotificationService.sendNotification(
                    notiType: NotiType.request,
                    item: widget.item.name,
                    notiReceiverId: ownerId,
                  );
                  await handleSubmit(
                      renterId,
                      ownerId,
                      widget.item.id,
                      startDateText,
                      endDateText,
                      widget.price,
                      widget.status);
                  if (!context.mounted) return;
                  await showAlertDialog(
                    context,
                    widget.item.type,
                  );
                },
                child: const Text(
                  'CONFIRM RENTAL',
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

  Future showAlertDialog(BuildContext context, String itemType) {
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
          "Request Sent!",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
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
              "Your ${itemType.toLowerCase()} rental request has been sent to the lender.",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "You'll receive a notification once confirmed.",
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
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
