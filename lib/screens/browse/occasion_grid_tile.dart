import 'package:flutter/material.dart';

class OccasionGridTile extends StatelessWidget {
  OccasionGridTile(this.occasion, {super.key});

  final String occasion;
  late String formattedOccasion;

  String setItemImage() {
    formattedOccasion = occasion.replaceAll(RegExp(' +'), '_');
    return 'assets/img/items/${formattedOccasion}_transparent.png';
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: width*0.3,
          height: width*0.16,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            // border: Border.all(
              // color: Colors.red,
            // ),
            borderRadius: const BorderRadius.all(Radius.circular(5))
          ),
          child: Column(
            children: [
              Image.asset(setItemImage(), height: width*0.16),
            ],
          )

        ),
      ],
    );
  }
}