import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:revivals/shared/styled_text.dart';

class RentalPriceSummary extends StatelessWidget {
  const RentalPriceSummary(this.price, this.noOfDays, this.deliveryPrice, this.symbol, {super.key});

  final int price;
  final int noOfDays;
  final int deliveryPrice;
  final String symbol;

  @override
  Widget build(BuildContext context) {
    int pricePerDay = price~/noOfDays;
    int finalPrice = price + deliveryPrice;
    double width = MediaQuery.of(context).size.width;

    // Format the price with commas and two decimal places
    final formattedPrice = NumberFormat("#,##0", "en_US").format(price);
    final formattedFinalPrice = NumberFormat("#,##0", "en_US").format(finalPrice);

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StyledHeading('PRICE DETAILS', fontSize: width * 0.045),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                StyledBody(
                  '$pricePerDay x $noOfDays days',
                  color: Colors.black,
                  weight: FontWeight.normal,
                  fontSize: width * 0.042,
                ),
                const Expanded(child: SizedBox()),
                StyledBody(
                  '฿$formattedPrice',
                  color: Colors.black,
                  weight: FontWeight.normal,
                  fontSize: width * 0.042,
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Row(
              children: [
                StyledHeading('Total', fontSize: width * 0.045),
                const Expanded(child: SizedBox()),
                StyledHeading('฿$formattedFinalPrice', fontSize: width * 0.045),
              ],
            ),
          ),
      ],),
    );
  }
}