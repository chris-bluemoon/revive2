import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/styled_text.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage(
      {required this.setFilter, required this.setValues, super.key});

  final Function setValues;
  final Function setFilter;

  @override
  State<FiltersPage> createState() => _FiltersPage();
}

class _FiltersPage extends State<FiltersPage> {
  int noOfFilters = 0;
  final double width =
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;

  Widget mySize(String size, bool selected) {
    return GestureDetector(
        onTap: () {
          setState(() {
            sizeMap[size] = !selected;
          });
        },
        child: Container(
            margin: const EdgeInsets.all(10),
            width: width * 0.04,
            height: width * 0.04,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (selected) ? Colors.black : Colors.white,
                border: Border.all(color: Colors.black)),
            child: (selected)
                ? Center(
                    child: StyledBody(size,
                        color: Colors.white, weight: FontWeight.normal))
                : Center(
                    child: StyledBody(size,
                        color: Colors.black, weight: FontWeight.normal))));
  }

  Widget myCircle(Color colour, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          colourMap[colour] = !selected;
        });
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        width: width * 0.03,
        height: width * 0.03,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colour,
          border: Border.all(color: Colors.black),
        ),
        child: (selected)
            ? Center(
                child: (colour == Colors.white)
                    ? const Icon(Icons.check_circle_outline, color: Colors.black, size: 18)
                    : const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              )
            : null,
      ),
    );
  }

  Widget myLength(String length, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          lengthMap[length] = !selected;
        });
      },
      child: Container(
          margin: const EdgeInsets.all(10),
          width: width * 0.06,
          height: width * 0.03,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: (selected) ? Colors.black : Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: (selected)
              ? Center(
                  child: StyledBody(length.toUpperCase(),
                      color: Colors.white, weight: FontWeight.normal))
              : Center(
                  child: StyledBody(length.toUpperCase(),
                      weight: FontWeight.normal))),
    );
  }

  Widget myPrint(String print, bool selected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          printMap[print] = !selected;
        });
      },
      child: Container(
          margin: const EdgeInsets.all(10),
          width: width * 0.09,
          height: width * 0.03,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: (selected) ? Colors.black : Colors.white,
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(12),
          ),
          child: (selected)
              ? Center(
                  child: StyledBody(print.toUpperCase(),
                      color: Colors.white, weight: FontWeight.normal))
              : Center(
                  child: StyledBody(print.toUpperCase(),
                      weight: FontWeight.normal))),
    );
  }

  Widget mySleeve(String sleeve, bool selected) {
    return GestureDetector(
        onTap: () {
          setState(() {
            sleeveMap[sleeve] = !selected;
          });
        },
        child: Container(
            margin: const EdgeInsets.all(10),
            width: width * 0.12,
            height: width * 0.03,
            // height: 51.0,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: (selected) ? Colors.black : Colors.white,
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(12),
            ),
            child: (selected)
                ? Center(
                    child: StyledBody(sleeve.toUpperCase(),
                        color: Colors.white, weight: FontWeight.normal),
                  )
                : Center(
                    child: StyledBody(
                      sleeve.toUpperCase(),
                      weight: FontWeight.normal,
                    ),
                  )));
  }

  Map<Color, bool> colourMap = {
    Colors.black: false,
    Colors.white: false,
    Colors.blue: false,
    Colors.red: false,
    Colors.green: false,
    Colors.yellow: false,
    Colors.grey: false,
    Colors.brown: false,
    Colors.purple: false,
    Colors.pink: false,
    Colors.cyan: false,
  };

  Map<String, bool> sizeMap = {
    '4': false,
    '6': false,
    '8': false,
    '10': false,
  };

  bool filterOn = false;
  bool getFilterOn() {
    log('Colour filter is: ${colourFilter.toString()}');
    if (colourFilter == false &&
        sizeFilter == false &&
        (rangeVals.start == 0 && rangeVals.end == 10000) &&
        lengthFilter == false &&
        printFilter == false &&
        sleeveFilter == false) {
      filterOn = false;
      return filterOn;
    }
    filterOn = true;
    return filterOn;
  }

  bool colourFilter = false;
  List<String> getColours() {
    List<String> returnColours = [];
    colourMap.forEach((key, value) {
      if (value == true) {
        colourFilter = true;
        switch (key) {
          case Colors.black:
            returnColours.add('Black');
            break;
          case Colors.white:
            returnColours.add('White');
            break;
          case Colors.blue:
            returnColours.add('Blue');
            break;
          case Colors.red:
            returnColours.add('Red');
            break;
          case Colors.green:
            returnColours.add('Green');
            break;
          case Colors.yellow:
            returnColours.add('Yellow');
            break;
          case Colors.grey:
            returnColours.add('Grey');
            break;
          case Colors.brown:
            returnColours.add('Brown');
            break;
          case Colors.purple:
            returnColours.add('Purple');
            break;
          case Colors.pink:
            returnColours.add('Pink');
            break;
          case Colors.cyan:
            returnColours.add('Cyan');
            break;
        }
      }
    });
    if (colourFilter == true) {
      noOfFilters++;
    }
    if (returnColours.isEmpty) {
      colourFilter = false;
      colourMap.forEach((key, value) {
        switch (key) {
          case Colors.black:
            returnColours.add('Black');
            break;
          case Colors.white:
            returnColours.add('White');
            break;
          case Colors.blue:
            returnColours.add('Blue');
            break;
          case Colors.red:
            returnColours.add('Red');
            break;
          case Colors.green:
            returnColours.add('Green');
            break;
          case Colors.yellow:
            returnColours.add('Yellow');
            break;
          case Colors.grey:
            returnColours.add('Grey');
            break;
          case Colors.brown:
            returnColours.add('Brown');
            break;
          case Colors.purple:
            returnColours.add('Purple');
            break;
          case Colors.pink:
            returnColours.add('Pink');
            break;
          case Colors.cyan:
            returnColours.add('Cyan');
            break;
        }
      });
    }
    return returnColours;
  }

  bool sizeFilter = false;
  List<String> getSizes() {
    List<String> returnSizes = [];
    sizeMap.forEach((key, value) {
      if (value == true) {
        sizeFilter = true;
        returnSizes.add(key);
      }
    });
    if (sizeFilter == true) {
      noOfFilters++;
    }
    if (returnSizes.isEmpty) {
      sizeFilter = false;
      sizeMap.forEach((key, value) {
        returnSizes.add(key);
      });
    }
    return returnSizes;
  }

  bool priceFilter = false;
  RangeValues getPrices() {
    // RangeValues rangeValues = const RangeValues(0, 10000);
    if (rangeVals.start > 0 || rangeVals.end < 10000) {
      noOfFilters++;
      priceFilter = true;
    }
    if (rangeVals.start == 0 && rangeVals.end == 10000) {
      priceFilter = false;
    }
    return rangeVals;
  }

  bool lengthFilter = false;
  List<String> getLengths() {
    List<String> returnLengths = [];
    lengthMap.forEach((key, value) {
      if (value == true) {
        lengthFilter = true;
        returnLengths.add(key);
      }
    });
    if (lengthFilter == true) {
      noOfFilters++;
    }
    if (returnLengths.isEmpty) {
      lengthFilter = false;
      lengthMap.forEach((key, value) {
        returnLengths.add(key);
      });
    }
    return returnLengths;
  }

  bool printFilter = false;
  List<String> getPrints() {
    List<String> returnPrints = [];
    printMap.forEach((key, value) {
      if (value == true) {
        printFilter = true;
        returnPrints.add(key);
      }
    });
    if (printFilter == true) {
      noOfFilters++;
    }
    if (returnPrints.isEmpty) {
      printFilter = false;
      printMap.forEach((key, value) {
        returnPrints.add(key);
      });
    }
    return returnPrints;
  }

  bool sleeveFilter = false;
  List<String> getSleeves() {
    List<String> returnSleeves = [];
    sleeveMap.forEach((key, value) {
      if (value == true) {
        sleeveFilter = true;
        returnSleeves.add(key);
      }
    });
    if (sleeveFilter == true) {
      noOfFilters++;
    }
    if (returnSleeves.isEmpty) {
      sleeveFilter = false;
      sleeveMap.forEach((key, value) {
        returnSleeves.add(key);
      });
    }
    return returnSleeves;
  }
  // TODO: To add a filter, add a getPrints, add to setValues as parameter, add to Occassions page setValues and IF statement, add to getFilterOn, add to database
  // Map<String, bool> sizeMap = {
  //   'XXS': false,
  //   'XS': false,
  //   'S': false,
  //   'M': false,
  //   'L': false,
  //   'XL': false
  // };

  Map<String, bool> lengthMap = {'mini': false, 'midi': false, 'long': false};

  Map<String, bool> printMap = {
    'enthic': false,
    'boho': false,
    'preppy': false,
    'floral': false,
    'abstract': false,
    'stripes': false,
    'dots': false,
    'textured': false,
    'none': false
  };
  Map<String, bool> sleeveMap = {
    'sleeveless': false,
    'short sleeve': false,
    '3/4 sleeve': false,
    'long sleeve': false
  };

  List<Widget> generateLengths() {
    List<Widget> lengths = [];
    lengthMap.forEach((key, value) {
      lengths.add(myLength(key, value));
    });
    return lengths;
  }

  List<Widget> generatePrints() {
    List<Widget> prints = [];
    printMap.forEach((key, value) {
      prints.add(myPrint(key, value));
    });
    return prints;
  }

  List<Widget> generateSleeves() {
    List<Widget> sleeves = [];
    sleeveMap.forEach((key, value) {
      sleeves.add(mySleeve(key, value));
    });
    return sleeves;
  }

  List<Widget> generateSizes() {
    List<Widget> sizes = [];
    sizeMap.forEach((key, value) {
      sizes.add(mySize(key, value));
      // sizes.add(mySize(key, value));
    });

    return sizes;
  }

  List<Widget> generateColours() {
    List<Widget> circles = [];
    colourMap.forEach((key, value) {
      circles.add(myCircle(key, value));
    });
    return circles;
  }

  RangeValues rangeVals = const RangeValues(0, 10000);
  RangeLabels rangeLabels = const RangeLabels('0', '10000');

  List resetValues() {
    rangeVals = const RangeValues(0, 10000);
    rangeLabels = const RangeLabels('0', '10000');
    colourMap.updateAll((name, value) => value = false);
    sizeMap.updateAll((name, value) => value = false);
    rangeVals = const RangeValues(0, 10000);
    lengthMap.updateAll((name, value) => value = false);
    printMap.updateAll((name, value) => value = false);
    sleeveMap.updateAll((name, value) => value = false);
    List a = [];
    a.add(colourMap);
    a.add(sizeMap);
    a.add(lengthMap);
    a.add(printMap);
    a.add(sleeveMap);
    return a;
  }

  @override
  void initState() {
    // resetValues();
    Map<String, bool> sizesFromStore =
        Provider.of<ItemStoreProvider>(context, listen: false).sizesFilter;
    Map<Color, bool> coloursFromStore =
        Provider.of<ItemStoreProvider>(context, listen: false).coloursFilter;
    Map<String, bool> lengthsFromStore =
        Provider.of<ItemStoreProvider>(context, listen: false).lengthsFilter;
    Map<String, bool> printsFromStore =
        Provider.of<ItemStoreProvider>(context, listen: false).printsFilter;
    Map<String, bool> sleevesFromStore =
        Provider.of<ItemStoreProvider>(context, listen: false).sleevesFilter;
    RangeValues rangeValuesFromStore =
        Provider.of<ItemStoreProvider>(context, listen: false)
            .rangeValuesFilter;
    sizeMap = Map<String, bool>.from(sizesFromStore);
    colourMap = Map<Color, bool>.from(coloursFromStore);
    lengthMap = Map<String, bool>.from(lengthsFromStore);
    // printMap = Map<String, bool>.from(printsFromStore);
    // sleeveMap = Map<String, bool>.from(sleevesFromStore);
    rangeVals = rangeValuesFromStore;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // setFilters(Provider.of<ItemStoreProvider>(context, listen: false).filters);
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: const StyledTitle('FILTER'),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.close, size: width * 0.08),
          onPressed: () {
            resetValues();
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.02),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Divider(),
            const StyledHeading('COLOUR'),
            SizedBox(height: width * 0.02),
            Padding(
              padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
              child: Wrap(
                direction: Axis.horizontal,
                children: generateColours(),
              ),
            ),
            SizedBox(height: width * 0.05),
            const Divider(),
            const StyledHeading('SIZE'),
            SizedBox(height: width * 0.02),
            Padding(
              padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
              child: Wrap(
                direction: Axis.horizontal,
                // children: generateSizes([]),
                children: generateSizes(),
              ),
            ),
            SizedBox(height: width * 0.05),
            const Divider(),
            StyledHeading(
                'PRICE (${rangeLabels.start.toString()} to ${rangeLabels.end.toString()})'),
            SizedBox(height: width * 0.02),
            Padding(
              padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
              child: RangeSlider(
                  inactiveColor: Colors.grey[300],
                  divisions: 10,
                  activeColor: Colors.black,
                  max: 10000,
                  values: rangeVals,
                  // labels: rangeLabels,
                  // onChangeStart: (value) {
                  //   setState(() {
                  //     lowerPriceValue = value;
                  //   });
                  // },
                  onChanged: (values) {
                    setState(() {
                      rangeVals = values;
                      rangeLabels = RangeLabels(values.start.round().toString(),
                          values.end.round().toString());
                    });
                  }),
            ),
            SizedBox(height: width * 0.05),
            // const Divider(),
            // const StyledHeading('LENGTH'),
            // SizedBox(height: width * 0.02),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
            //   child: Wrap(
            //     direction: Axis.horizontal,
            //     children: generateLengths(),
            //   ),
            // ),
            // SizedBox(height: width * 0.05),
            // const Divider(),
            // const StyledHeading('PRINT'),
            // SizedBox(height: width * 0.02),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
            //   child: Wrap(
            //     direction: Axis.horizontal,
            //     children: generatePrints(),
            //   ),
            // ),
            // SizedBox(height: width * 0.05),
            // const Divider(),
            // const StyledHeading('SLEEVE'),
            // SizedBox(height: width * 0.02),
            // Padding(
            //   padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
            //   child: Wrap(
            //     direction: Axis.horizontal,
            //     children: generateSleeves(),
            //   ),
            // ),
          ]),
        ),
      ),
      bottomNavigationBar: Container(
        // height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 3,
            )
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  resetValues();
                  widget.setValues(getColours(), getSizes(), getPrices(),
                      getLengths(), getPrints(), getSleeves());
                  widget.setFilter(getFilterOn(), noOfFilters);
                  // Provider.of<ItemStoreProvider>(context, listen: false).sizesFilterSetter(sizeMap);
                  // Provider.of<ItemStoreProvider>(context, listen: false).rangeValuesFilterSetter(rangeVals);
                  // Provider.of<ItemStoreProvider>(context, listen: false).coloursFilterSetter(colourMap);
                  // Provider.of<ItemStoreProvider>(context, listen: false).lengthsFilterSetter(lengthMap);
                  // Provider.of<ItemStoreProvider>(context, listen: false).printsFilterSetter(printMap);
                  // Provider.of<ItemStoreProvider>(context, listen: false).sleevesFilterSetter(sleeveMap);
                  // noOfFilters = 0;
                });
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(width: 1.0, color: Colors.black),
              ),
              child: const StyledHeading('RESET'),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: OutlinedButton(
              onPressed: () {
                widget.setValues(getColours(), getSizes(), getPrices(),
                    getLengths(), getPrints(), getSleeves());
                widget.setFilter(getFilterOn(), noOfFilters);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .sizesFilterSetter(sizeMap);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .rangeValuesFilterSetter(rangeVals);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .coloursFilterSetter(colourMap);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .lengthsFilterSetter(lengthMap);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .printsFilterSetter(printMap);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .sleevesFilterSetter(sleeveMap);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .rangeValuesFilterSetter(rangeVals);
                Navigator.pop(context);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: const BorderSide(width: 1.0, color: Colors.black),
              ),
              child: const StyledHeading('APPLY', color: Colors.white),
            ),
          ),
        ]),
      ),
    );
  }
}
