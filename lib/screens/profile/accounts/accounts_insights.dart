import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
// import 'package:revivals/screens/profile/edit/to_rent_edit.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AccountsInsightsPage extends StatefulWidget {
  const AccountsInsightsPage({super.key});

  @override
  State<AccountsInsightsPage> createState() => _AccountsInsightsPageState();
}

class _AccountsInsightsPageState extends State<AccountsInsightsPage> {
  @override
  void initState() {
    super.initState();
    setMonthlyAccounts();
    calculateMonthlyAccounts();
  }

  List<_SalesData> data = [
    // _SalesData('Jan', 35),
    // _SalesData('Feb', 28),
    // _SalesData('Mar', 34),
    // _SalesData('Apr', 32),
    // _SalesData('May', 40),
    // _SalesData('Jun', 40)
  ];

  // late Item mostRentedItem;
  List<ItemRenter> myAccountsHistory = [];

  Map<String, int> accountMapMonthly = {};

  int totalRentals = 0;
  int totalSales = 0;
  int returnOnInvestment = 0;
  int valueOfListings = 0;
  int responseRate = 0;
  int acceptanceRate = 0;
  String mostRentedBrand = '';
  String mostRentedItem = '';
  late Item mostRentedItemItem;
  List<String> brands = [];
  List<String> items = [];

  String zeroMonthString = '';
  DateTime zeroMonth = DateTime.now();
  bool longXseries = false;

  final value = NumberFormat("#,##0", "en_US");

  void setMonthlyAccounts() {
    // Get earliest date
    List<ItemRenter> allAccountsHistory =
        Provider.of<ItemStoreProvider>(context, listen: false).itemRenters;
    for (ItemRenter ir in allAccountsHistory) {
      if (ir.ownerId ==
          Provider.of<ItemStoreProvider>(context, listen: false).renter.email) {
        myAccountsHistory.add(ir);
        // myAccountsHistory.sort((a, b) => a.endDate.compareTo(b.endDate));
        totalRentals++;
        totalSales = totalSales + ir.price;
        for (Item i
            in Provider.of<ItemStoreProvider>(context, listen: false).items) {
          if (i.id == ir.itemId) {
            brands.add(i.brand);
          }
        }
        for (Item i
            in Provider.of<ItemStoreProvider>(context, listen: false).items) {
          if (i.id == ir.itemId) {
            items.add(i.id);
          }
        }
      }
      myAccountsHistory.sort((a, b) => a.endDate.compareTo(b.endDate));
    }

    Map<String, int> itemMap = {};
    for (var x in items) {
      itemMap[x] = !itemMap.containsKey(x) ? (1) : (itemMap[x]! + 1);
    }
    // final sortedItems = SplayTreeMap<String,dynamic>.from(itemMap, (a, b) => a.compareTo(b));
    final sortedItems = Map.fromEntries(itemMap.entries.toList()
      ..sort((e2, e1) => e1.value.compareTo(e2.value)));
    if (sortedItems.isNotEmpty) {
      mostRentedItem = sortedItems.keys.toList().first;
      mostRentedItemItem =
          Provider.of<ItemStoreProvider>(context, listen: false)
              .items
              .where((i) => i.id == mostRentedItem)
              .toList()[0];
    }

    Map<String, int> map = {};
    for (var x in brands) {
      map[x] = !map.containsKey(x) ? (1) : (map[x]! + 1);
    }
    // final sortedBrands = SplayTreeMap<String,dynamic>.from(map, (a, b) => a.compareTo(b));
    final sortedBrands = Map.fromEntries(
        map.entries.toList()..sort((e2, e1) => e1.value.compareTo(e2.value)));
    if (sortedBrands.isNotEmpty) {
      mostRentedBrand = sortedBrands.keys.toList().first;
    }

    for (Item i
        in Provider.of<ItemStoreProvider>(context, listen: false).items) {
      if (i.owner ==
          Provider.of<ItemStoreProvider>(context, listen: false).renter.id) {
        valueOfListings = valueOfListings + i.rrp;
      }
    }

    if (myAccountsHistory.isNotEmpty) {
      String earliestDateString = myAccountsHistory[0].endDate;
      String earliestMonthString = earliestDateString.substring(0, 7);
      // String nowMonth = DateFormat('yyyy-MM').format(DateTime.now());
      String nowMonth = DateFormat('yyyy-MM')
          .format(DateTime.now().add(const Duration(days: 31)));
      zeroMonth = DateFormat('yyyy-MM')
          .parse(earliestDateString)
          .subtract(const Duration(days: 1));
      DateTime tempMonth =
          DateTime(zeroMonth.year, zeroMonth.month + 12, zeroMonth.day);
      if (tempMonth.isBefore(DateTime.now())) {
        zeroMonthString = DateFormat('MMM yyyy').format(zeroMonth);
        longXseries = true;
      } else {
        zeroMonthString = DateFormat('MMM').format(zeroMonth);
      }

      // zeroMonthString = DateFormat('yyyy-MM').format(zeroMonth);
      String bucketMonth = earliestMonthString;
      while (bucketMonth != nowMonth) {
        accountMapMonthly[bucketMonth] = 0;
        DateTime nextMonth = DateFormat('yyyy-MM')
            .parse(bucketMonth)
            .add(const Duration(days: 31));
        bucketMonth = DateFormat('yyyy-MM').format(nextMonth);
      }
    }
  }

  void calculateMonthlyAccounts() {
    for (ItemRenter ir in myAccountsHistory) {
      for (var v in accountMapMonthly.keys) {
        String monthEndDate = ir.endDate.substring(0, 7);
        if (monthEndDate == v) {
          int newValue = accountMapMonthly[v]! + ir.price;
          accountMapMonthly[v] = newValue;
        }
      }
    }
    data.add(_SalesData(zeroMonthString, 0));
    accountMapMonthly.forEach((key, value) {
      DateTime month = DateFormat('yyyy-MM').parse(key);
      String stringMonth1 = '';
      String stringMonth2 = '';
      if (longXseries == true) {
        stringMonth1 = DateFormat('MMM yyyy').format(month);
      } else {
        stringMonth2 = DateFormat('MMM').format(month);
      }
      if (accountMapMonthly.length > 12) {
        data.add(_SalesData(stringMonth1, value));
      } else {
        data.add(_SalesData(stringMonth2, value));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SingleChildScrollView(
      child: Column(children: [
        //Initialize the chart widget
        SizedBox(height: width * 0.04),
        SfCartesianChart(
            primaryXAxis: const CategoryAxis(),
            // Chart title
            title: const ChartTitle(text: 'All Rental Income Per Month'),
            // Enable legend
            legend: const Legend(isVisible: true),
            // Enable tooltip
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<_SalesData, String>>[
              LineSeries<_SalesData, String>(
                dataSource: data,
                xValueMapper: (_SalesData sales, _) => sales.month,
                yValueMapper: (_SalesData sales, _) => sales.sales,
                name: 'Income',
                // Enable data label
                // dataLabelSettings: const DataLabelSettings(isVisible: true)
              )
            ]),
        Divider(indent: width * 0.1, endIndent: width * 0.1),
        SizedBox(height: width * 0.04),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(width * 0.02),
                child: ListTile(
                  title: const StyledBody('Total Rentals',
                      weight: FontWeight.normal),
                  subtitle: StyledBody(totalRentals.toString()),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(width * 0.02),
                child: ListTile(
                  // dense: true,
                  title: const StyledBody('Total Sales',
                      weight: FontWeight.normal),
                  subtitle: StyledBody('\$${value.format(totalSales)}'),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(width * 0.02),
                child: ListTile(
                  title: const StyledBody('Return on Investment',
                      weight: FontWeight.normal),
                  subtitle: const StyledBody('15%'),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(width * 0.02),
                child: ListTile(
                  // dense: true,
                  title: const StyledBody('Value of Listings',
                      weight: FontWeight.normal),
                  subtitle: StyledBody('\$${value.format(valueOfListings)}'),
                  // subtitle: Row(
                  //   crossAxisAlignment: CrossAxisAlignment.center,
                  //   children: [
                  //     const StyledBody('\$'),
                  //     AnimatedDigitWidget(
                  //       // key: const ValueKey('teal'),
                  //       value: value.format(valueOfListings),
                  //       textStyle: const TextStyle(
                  //         fontSize: 30,
                  //         fontWeight: FontWeight.bold,
                  //       ),
                  //     ),
                  //   ],
                  // ),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(width * 0.02),
                child: ListTile(
                  title: const StyledBody('Response Rate',
                      weight: FontWeight.normal),
                  subtitle: const StyledBody('94%'),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(width * 0.02),
                child: ListTile(
                  // dense: true,
                  title: const StyledBody('Acceptance Rate',
                      weight: FontWeight.normal),
                  subtitle: const StyledBody('85%'),
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
        // SizedBox(height: width * 0.04),
        // Divider(height: width * 0.1, indent: width * 0.1, endIndent: width * 0.1),
        // Padding(
        //   padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
        //   child: Row(
        //     children: [
        //       const StyledBody('Your most rented brand', weight: FontWeight.normal,),
        //       const Expanded(child: SizedBox()),
        //       StyledBody(mostRentedBrand),
        //     ],),
        // ),
        // // Divider(height: width * 0.1, indent : width * 0.1, endIndent: width * 0.1),
        // SizedBox(height: width * 0.01),
        // Padding(
        //   padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
        //   child: Row(
        //     children: [
        //       const StyledBody('Your most popular listing', weight: FontWeight.normal,),
        //       const Expanded(child: SizedBox()),
        //       IconButton(
        //         onPressed: () {
        //           Navigator.of(context).push(MaterialPageRoute(
        //                       builder: (context) =>
        //                           (ToRentEdit(mostRentedItemItem))));
        //         },
        //         padding: EdgeInsets.zero,
        //         icon: Icon(Icons.chevron_right_outlined, size: width * 0.08)
        //       ),
        //     ],),
        // ),
      ]),
    );
  }
}

class _SalesData {
  _SalesData(this.month, this.sales);

  final String month;
  final int sales;
}
