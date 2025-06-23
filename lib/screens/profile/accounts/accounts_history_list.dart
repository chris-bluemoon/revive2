import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/profile/accounts/ledger_entry_widget.dart';
import 'package:revivals/shared/styled_text.dart';


class AccountsHistoryList extends StatefulWidget {
  const AccountsHistoryList({super.key});

  @override
  State<AccountsHistoryList> createState() => _AccountsHistoryListState();
}

class _AccountsHistoryListState extends State<AccountsHistoryList> {
  

  // List<ItemRenter> myItemRenters = [];
  List<Ledger> myLedgerEntries = [];
  // List<Item> myItems = [];

  int totalSales = 0;
  final value = NumberFormat("#,##0", "en_US");


  @override
  void initState() {
    loadAccountsHistoryList();
    super.initState();
  }
  
  void loadAccountsHistoryList() {
    String userEmail = Provider.of<ItemStoreProvider>(context, listen: false).renter.email;
    // List<ItemRenter> allItemRenters = List.from(Provider.of<ItemStoreProvider>(context, listen: false).itemRenters);
    // for (ItemRenter ir in allItemRenters) {
    //   if (ir.ownerId == userEmail) {
    //       myItemRenters.add(ir);
    //       totalSales = totalSales + ir.price;
    //   }
    // }
    // myItemRenters.sort((a, b) => a.endDate.compareTo(b.endDate));
    List<Ledger> ledgerEntries = Provider.of<ItemStoreProvider>(context, listen: false).ledgers;
    for (Ledger l in ledgerEntries) {
      if (l.owner == userEmail) {
        myLedgerEntries.add(l);
        totalSales = totalSales + l.amount;
      }
    }


  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // String address = Provider.of<ItemStoreProvider>(context, listen: false).renters[0].address;
    return Column(
      children: [
        Padding(
          padding:
              EdgeInsets.fromLTRB(width * 0.05, width * 0.05, width * 0.05, 0),
          child: Row(
            children: [
              StyledBody(
                'Total Income:    \$${value.format(totalSales)}',
                weight: FontWeight.normal,
              ),
            ],
          ),
        ),
        Padding(
          padding:
              EdgeInsets.fromLTRB(width * 0.05, width * 0.05, width * 0.05, 0),
          child: Row(
            children: [
              SizedBox(
                  width: width * 0.2,
                  child: const StyledBody('Date', weight: FontWeight.normal)),
              SizedBox(
                  width: width * 0.35,
                  child: const StyledBody('Description',
                      weight: FontWeight.normal)),
              SizedBox(
                  width: width * 0.2,
                  child: const StyledBody('Amount',
                      weight: FontWeight.normal)),
              const StyledBody('Balance', weight: FontWeight.normal),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
              // padding: EdgeInsets.all(width * 0.01),
              itemCount: myLedgerEntries.length,
              itemBuilder: (BuildContext context, int index) {
                return LedgerEntryWidget(myLedgerEntries[index]);
              }),
        ),
      ],
    );
  }
}
