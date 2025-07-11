import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:carousel_slider/carousel_slider.dart';


class RentForLonger extends StatelessWidget {
  final Item item;
  final String symbol;
  final List<Map<String, dynamic>> options;
  RentForLonger({required this.item, required this.options, String? symbol, super.key})
      : symbol = symbol ?? globals.thb;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double cardWidth = width * 0.38; // Consistent width
    double cardHeight = 120; // Reduced height
    double suggestedCardHeight = 140; // Reduced height for suggested card
    return SizedBox(
      height: suggestedCardHeight,
      child: CarouselSlider(
        options: CarouselOptions(
          height: suggestedCardHeight,
          enableInfiniteScroll: false,
          viewportFraction: cardWidth / width,
          enlargeCenterPage: true,
          autoPlay: true, // Enable autoplay
          autoPlayInterval: Duration(seconds: 3), // Change interval as needed
        ),
        items: options.map((option) {
          int days = option['days'] as int;
          int price = option['price'] as int;
          String label = option['label'] as String;
          bool isSuggested = days == item.minDays + 2;
          return Container(
            width: cardWidth,
            height: isSuggested ? suggestedCardHeight : cardHeight,
            margin: EdgeInsets.symmetric(horizontal: 4), // Reduce margin
            child: Card(
              color: isSuggested ? Colors.green[50] : null,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Colors.black12),
              ),
              elevation: 2,
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 2, horizontal: 4), // Further reduce padding
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (isSuggested)
                      const Text("Suggested", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 12), textAlign: TextAlign.center),
                    if (isSuggested) const SizedBox(height: 1), // Minimal spacing
                    Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), textAlign: TextAlign.center),
                    const SizedBox(height: 2), // Minimal spacing
                    Text("${NumberFormat('#,###').format((price / days).floor())}$symbol / day", style: const TextStyle(fontSize: 11), textAlign: TextAlign.center),
                    const SizedBox(height: 2), // Minimal spacing
                    Text("${NumberFormat('#,###').format(price)}$symbol total", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
