import 'package:flutter/material.dart';

class FittingHomeWidget extends StatelessWidget {
  const FittingHomeWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Image.asset('assets/img/backgrounds/3.jpg'),
    );
  }
}
