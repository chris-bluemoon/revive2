import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';


class RentForLonger extends StatelessWidget {
  final Item item;
  final String symbol;
  RentForLonger({required this.item, String? symbol, super.key})
      : symbol = symbol ?? globals.thb;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: width * 0.00),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 1st card: minDays
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black12),
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: width * 0.01),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.01),
                child: Column(
                  children: [
                    Text("${item.minDays} days", style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("${NumberFormat('#,###').format(item.rentPriceDaily)}$symbol / day"),
                    const SizedBox(height: 6),
                    Text("${NumberFormat('#,###').format(item.rentPriceDaily * item.minDays)}$symbol total"),
                  ],
                ),
              ),
            ),
          ),
          // 2nd card: Weekly (7 days)
          Expanded(
            child: Card(
              color: Colors.green[50],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black12),
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: width * 0.01),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.01),
                child: Column(
                  children: [
                    const Text("Suggested", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    const SizedBox(height: 4),
                    const Text("7 Days", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("${NumberFormat('#,###').format((item.rentPrice7 / 7).floor())}$symbol / day"),
                    const SizedBox(height: 6),
                    Text("${NumberFormat('#,###').format(item.rentPrice7)}$symbol total"),
                  ],
                ),
              ),
            ),
          ),
          // 3rd card: 14 Days
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black12),
              ),
              elevation: 2,
              margin: EdgeInsets.symmetric(horizontal: width * 0.01),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.01),
                child: Column(
                  children: [
                    const Text("14 Days", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("${NumberFormat('#,###').format((item.rentPrice14 / 14).floor())}$symbol / day"),
                    const SizedBox(height: 6),
                    Text("${NumberFormat('#,###').format(item.rentPrice14)}$symbol total"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
