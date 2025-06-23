import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/styled_text.dart';

class LedgerEntryWidget extends StatelessWidget {
  LedgerEntryWidget(this.ledgerEntry, {super.key});

  final Ledger ledgerEntry;

  late String itemType;
  late String itemName;
  late String renterName;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    DateTime convertedDate =
        DateFormat('yyyy-MM-dd HH:mm:ss').parse(ledgerEntry.date);
    for (Renter r
        in Provider.of<ItemStoreProvider>(context, listen: false).renters) {
      if (r.email == ledgerEntry.owner) {
        renterName = r.name;
      }
    }
    // for (Item i in Provider.of<ItemStoreProvider>(context, listen: false).items) {
    //   if (i.id == itemRenter.itemId) {
    //     itemType = i.type;
    //     itemName = i.name;
    //   }
    // }
    return Row(
      children: [
        Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                  width * 0.05, width * 0.01, width * 0.05, 0),
              child: Container(
                color: Colors.grey[100],
                child: Row(
                  children: [
                    SizedBox(
                        width: width * 0.2,
                        child: StyledBody(
                            DateFormat('yMd').format(convertedDate),
                            color: Colors.grey,
                            weight: FontWeight.normal)),
                    SizedBox(
                        width: width * 0.35,
                        child: StyledBody(ledgerEntry.desc,
                            color: Colors.grey, weight: FontWeight.normal)),
                    SizedBox(
                        width: width * 0.2,
                        child: StyledBody(ledgerEntry.amount.toString(),
                            color: Colors.grey, weight: FontWeight.normal)),
                  ],
                ),
              ),
            ),
            // StyledBody('Price ${price.toString()}${globals.thb}', color: Colors.grey, weight: FontWeight.normal),
          ],
        )
      ],
    );
  }
}
