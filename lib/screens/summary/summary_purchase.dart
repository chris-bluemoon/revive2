import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/summary/delivery_radio_widget.dart';
import 'package:revivals/screens/summary/purchase_price_summary.dart';
import 'package:revivals/screens/summary/summary_image_widget.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class SummaryPurchase extends StatefulWidget {
  SummaryPurchase(this.item, this.startDate, this.endDate, this.noOfDays,
      this.price, this.status, this.symbol,
      {super.key});

  final Item item;
  final DateTime startDate;
  final DateTime endDate;
  final int noOfDays;
  final int price;
  final String status;
  final String symbol;

  final ValueNotifier<int> deliveryPrice = ValueNotifier<int>(0);

  @override
  State<SummaryPurchase> createState() => _SummaryPurchaseState();
}

class _SummaryPurchaseState extends State<SummaryPurchase> {
  // final int i;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    // int pricePerDay = widget.price~/widget.noOfDays;

    void handleSubmit(String renterId, String ownerId, String itemId,
        String startDate, String endDate, int price, String status) {
      Provider.of<ItemStoreProvider>(context, listen: false)
          .addItemRenter(ItemRenter(
        id: uuid.v4(),
        renterId: renterId,
        ownerId: ownerId,
        itemId: itemId,
        transactionType: 'purchase',
        startDate: startDate,
        endDate: endDate,
        price: price,
        status: status,
      ));
    }

    void updateDeliveryPrice(int newDeliveryPrice) {
      setState(() {
        widget.deliveryPrice.value = newDeliveryPrice;
      });
    }

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
              height: 70,
              width: 350,
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                      child: StyledHeading(
                          'Buying for ${widget.price}${globals.thb}',
                          weight: FontWeight.normal)),
                  // SizedBox(height: 5),
                  // Text('(${pricePerDay}${globals.thb} per day)', style: TextStyle(fontSize: 14)),
                ],
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
          // SizedBox(height: 20),
          DeliveryRadioWidget(updateDeliveryPrice, widget.symbol),
          Divider(
            height: 1,
            indent: 50,
            endIndent: 50,
            color: Colors.grey[300],
          ),
          ValueListenableBuilder(
              valueListenable: widget.deliveryPrice,
              builder: (BuildContext context, int val, Widget? child) {
                return PurchasePriceSummary(widget.price, val);
              }),
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
                  onPressed: () {
                    String email =
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .renter
                            .email;
                    String startDateText = widget.startDate.toString();
                    String endDateText = widget.endDate.toString();
                    handleSubmit(
                        email,
                        widget.item.owner,
                        widget.item.id,
                        startDateText,
                        endDateText,
                        widget.item.buyPrice,
                        widget.status);
                    showAlertDialog(context, widget.item.type, width);
                    // Navigator.of(context).push(MaterialPageRoute(
                    // builder: (context) => (const Congrats())));
                  },
                  child: Padding(
                    padding: EdgeInsets.all(width * 0.01),
                    child: const StyledHeading('CONFIRM', color: Colors.white),
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
