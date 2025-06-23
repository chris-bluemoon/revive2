import 'package:flutter/material.dart';

class Filter {
  List? filters;

  Map<Color, bool> colourMap = {
    Colors.black: false,
    Colors.white: false,
    Colors.blue: false,
    Colors.green: false,
    Colors.pink: false,
    Colors.grey: false,
    Colors.brown: false,
    Colors.yellow: false,
    Colors.purple: false,
    Colors.red: false,
    Colors.lime: false,
    Colors.cyan: false,
  };

  Map<String, bool> sizeMap = {
    'XXS': false,
    'XS': false,
    'S': false,
    'M': false,
    'L': false,
    'XL': false
  };

  Map<String, bool> lengthMap = {
    'SHORT': false,
    'MEDIUM': false,
    'LONG': false
  };

  Map<String, bool> printMap = {
    'ETHNIC': false,
    'BOHO': false,
    'PREPPY': false,
    'FLORAL': false,
    'ABSTRACT': false,
    'STRIPES': false,
    'DOTS': false,
    'TEXTURED': false,
    'NONE': false
  };
  Map<String, bool> sleeveMap = {
    'SLEEVELESS': false,
    'SHORT SLEEVE': false,
    '3/4 SLEEVE': false,
    'LONG SLEEVE': false
  };

  RangeValues rangeValues = const RangeValues(0, 10000);

  Widget myCircle(Color colour, bool selected) {
    return Container(
      margin: const EdgeInsets.all(10),
      width: 50.0,
      height: 50.0,
      decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colour,
          border: Border.all(color: Colors.black)),
      child: (selected)
          ? const Icon(Icons.check_circle_rounded, color: Colors.white)
          : null,
    );
  }

  List<Widget> generateColours() {
    List<Widget> circles = [];
    colourMap.forEach((key, value) {
      circles.add(myCircle(key, value));
    });
    return circles;
  }

  void setFilters() {
    filters!.add(colourMap);
    filters!.add(sizeMap);
    filters!.add(printMap);
    filters!.add(lengthMap);
    filters!.add(sleeveMap);
    filters!.add(rangeValues);
  }

}
