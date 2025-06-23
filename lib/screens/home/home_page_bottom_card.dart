import 'package:flutter/material.dart';
import 'package:revivals/shared/styled_text.dart';

class HomePageBottomCard extends StatelessWidget {
  const HomePageBottomCard(this.text, {super.key});
 
  final String text;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return SizedBox(
      // height: 120,
      width: width*0.3,
      // height: width*0.7,
      // height: height*0.05,
      child: Card(
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
        color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: 
            StyledBodyCenter(text, color: Colors.white),
        ),
            ),
      )
    );
  }
}