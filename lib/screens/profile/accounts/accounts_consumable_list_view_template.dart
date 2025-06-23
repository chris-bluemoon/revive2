import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/styled_text.dart';

class Accounts extends StatefulWidget {
  const Accounts({super.key});

  @override
  State<Accounts> createState() => _AccountsState();
}

class _AccountsState extends State<Accounts> {
  List<ItemRenter> myItemRenters = [];
  // List<Item> myItems = [];

  bool isDateSentToday = false;

  @override
  void initState() {
    super.initState();
    getAccounts();
  }

  String itemName = '';
  String itemType = '';
  String startDate = '';
  String endDate = '';
  String paid = '';

  getAccounts() {
    for (ItemRenter ir
        in Provider.of<ItemStoreProvider>(context, listen: false).itemRenters) {
      if (ir.ownerId ==
          Provider.of<ItemStoreProvider>(context, listen: false).renter.email) {
        myItemRenters.add(ir);
      }
    }
    myItemRenters.sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          leading: IconButton(
              icon: Icon(Icons.chevron_left, size: width * 0.08),
              onPressed: () {
                Navigator.pop(context);
              }),
          title: const StyledTitle('ACCOUNTS'),
        ),
        body: Consumer<ItemStoreProvider>(builder: (context, value, child) {
          return ListView.separated(
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemCount: myItemRenters.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(),
              itemBuilder: (BuildContext context, int index) {
                return ListTile(
                  title: Row(
                    children: [
                      StyledBody(myItemRenters[index].itemId),
                      SizedBox(width: width * 0.1),
                      StyledBody(
                        myItemRenters[index].price.toString(),
                        weight: FontWeight.normal,
                      )
                    ],
                  ),
                  subtitle: StyledBody(
                    myItemRenters[index].startDate,
                    weight: FontWeight.normal,
                  ),
                );
              });
        }));
  }
}
