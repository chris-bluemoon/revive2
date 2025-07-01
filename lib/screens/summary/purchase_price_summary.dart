import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/shared/styled_text.dart';

class PurchasePriceSummary extends StatelessWidget {
  const PurchasePriceSummary(this.price, {super.key});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const StyledHeading('PRICE DETAILS'),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                const StyledBody('Purchase price', color: Colors.black, weight: FontWeight.normal),
                const Expanded(child: SizedBox()),
                StyledBody('${NumberFormat('#,###').format(price)}${globals.thb}', color: Colors.black, weight: FontWeight.normal),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                const StyledHeading('Total', color: Colors.black),
                const Expanded(child: SizedBox()),
                StyledHeading('${NumberFormat('#,###').format(price)}${globals.thb}', color: Colors.black),
              ],
            ),
          ),
      ],),
    );
  }
}