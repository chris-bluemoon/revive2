import 'package:flutter/material.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/shared/styled_text.dart';

class PurchasePriceSummary extends StatelessWidget {
  const PurchasePriceSummary(this.price, this.deliveryPrice, {super.key});

  final int price;
  final int deliveryPrice;

  @override
  Widget build(BuildContext context) {
    int finalPrice = price + deliveryPrice;
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
                StyledBody('$price${globals.thb}', color: Colors.black, weight: FontWeight.normal),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                const StyledBody('Delivery fee', color: Colors.black, weight: FontWeight.normal),
                const Expanded(child: SizedBox()),
                StyledBody('$deliveryPrice${globals.thb}', color: Colors.black, weight: FontWeight.normal),
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
                StyledHeading('$finalPrice${globals.thb}', color: Colors.black),
              ],
            ),
          ),
      ],),
    );
  }
}