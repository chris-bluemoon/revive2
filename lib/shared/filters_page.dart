import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:revivals/shared/thailand_cities.dart';

class FiltersPage extends StatefulWidget {
  const FiltersPage(
      {required this.setFilter, required this.setValues, super.key});

  final Function setValues;
  final Function setFilter;

  @override
  State<FiltersPage> createState() => _FiltersPage();
}

class _FiltersPage extends State<FiltersPage> {
  // Location filter state (Thai cities)
  final List<String> cityOptions = thailandCities;
  String? selectedCity;
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
    bool isLightColor = colour == Colors.white || colour.value == 0xFFF5F5DC || colour.value == 0xFFFFFDD0; // white, beige, cream
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
                child: isLightColor
                    ? const Icon(Icons.check_circle_outline, color: Colors.black, size: 18)
                    : const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              )
            : null,
      ),
    );
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
    Colors.orange: false,
    const Color(0xFFE0B0FF): false, // Mauve
    const Color(0xFFFFFDD0): false, // Cream
    const Color(0xFFF5F5DC): false, // Beige
  };

  Map<String, bool> sizeMap = {
    '4': false,
    '6': false,
    '8': false,
    '10': false,
  };

  // Filter state
  bool filterOn = false;
  bool colourFilter = false;
  bool sizeFilter = false;
  bool priceFilter = false;

  bool getFilterOn() {
    log('Colour filter is: \x1B[33m${colourFilter.toString()}\x1B[0m');
    noOfFilters = 0;
    if (colourFilter) noOfFilters++;
    if (sizeFilter) noOfFilters++;
    if (rangeVals.start > 0 || rangeVals.end < 10000) noOfFilters++;
    if (selectedCity != null && selectedCity!.isNotEmpty) noOfFilters++;
    filterOn = noOfFilters > 0;
    return filterOn;
  }

  List<String> getColours() {
    List<String> returnColours = [];
    colourFilter = false;
    colourMap.forEach((key, value) {
      if (value == true) {
        colourFilter = true;
        if (key == Colors.black) {
          returnColours.add('Black');
        } else if (key == Colors.white) {
          returnColours.add('White');
        } else if (key == Colors.blue) {
          returnColours.add('Blue');
        } else if (key == Colors.red) {
          returnColours.add('Red');
        } else if (key == Colors.green) {
          returnColours.add('Green');
        } else if (key == Colors.yellow) {
          returnColours.add('Yellow');
        } else if (key == Colors.grey) {
          returnColours.add('Grey');
        } else if (key == Colors.brown) {
          returnColours.add('Brown');
        } else if (key == Colors.purple) {
          returnColours.add('Purple');
        } else if (key == Colors.pink) {
          returnColours.add('Pink');
        } else if (key == Colors.cyan) {
          returnColours.add('Cyan');
        } else if (key == Colors.orange) {
          returnColours.add('Orange');
        } else if (key.value == 0xFFF5F5DC) {
          returnColours.add('Beige');
        } else if (key.value == 0xFFFFFDD0) {
          returnColours.add('Cream');
        } else if (key.value == 0xFFE0B0FF) {
          returnColours.add('Mauve');
        }
      }
    });
    if (!colourFilter) {
      colourMap.forEach((key, value) {
        if (key == Colors.black) {
          returnColours.add('Black');
        } else if (key == Colors.white) {
          returnColours.add('White');
        } else if (key == Colors.blue) {
          returnColours.add('Blue');
        } else if (key == Colors.red) {
          returnColours.add('Red');
        } else if (key == Colors.green) {
          returnColours.add('Green');
        } else if (key == Colors.yellow) {
          returnColours.add('Yellow');
        } else if (key == Colors.grey) {
          returnColours.add('Grey');
        } else if (key == Colors.brown) {
          returnColours.add('Brown');
        } else if (key == Colors.purple) {
          returnColours.add('Purple');
        } else if (key == Colors.pink) {
          returnColours.add('Pink');
        } else if (key == Colors.cyan) {
          returnColours.add('Cyan');
        } else if (key == Colors.orange) {
          returnColours.add('Orange');
        } else if (key.value == 0xFFF5F5DC) {
          returnColours.add('Beige');
        } else if (key.value == 0xFFFFFDD0) {
          returnColours.add('Cream');
        } else if (key.value == 0xFFE0B0FF) {
          returnColours.add('Mauve');
        }
      });
    }
    return returnColours;
  }

  List<String> getSizes() {
    List<String> returnSizes = [];
    sizeFilter = false;
    sizeMap.forEach((key, value) {
      if (value == true) {
        sizeFilter = true;
        returnSizes.add(key);
      }
    });
    if (!sizeFilter) {
      sizeMap.forEach((key, value) {
        returnSizes.add(key);
      });
    }
    return returnSizes;
  }

  RangeValues getPrices() {
    priceFilter = false;
    if (rangeVals.start > 0 || rangeVals.end < 10000) {
      priceFilter = true;
    }
    return rangeVals;
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
    List a = [];
    a.add(colourMap);
    a.add(sizeMap);
    return a;
  }

  @override
  void initState() {
    // resetValues();
    Map<String, bool> sizesFromStore =
        Provider.of<ItemStoreProvider>(context, listen: false).sizesFilter;
    Map<Color, bool> coloursFromStore =
        Provider.of<ItemStoreProvider>(context, listen: false).coloursFilter;
    RangeValues rangeValuesFromStore =
        Provider.of<ItemStoreProvider>(context, listen: false)
            .rangeValuesFilter;
    String? cityFromStore = Provider.of<ItemStoreProvider>(context, listen: false).cityFilter;
    sizeMap = Map<String, bool>.from(sizesFromStore);
    colourMap = Map<Color, bool>.from(coloursFromStore);
    rangeVals = rangeValuesFromStore;
    // Debug: print cityFromStore and cityOptions
    log('cityFromStore: "${cityFromStore ?? 'null'}"');
    log('cityOptions: ${cityOptions.join(", ")}');
    if (cityFromStore != null && cityFromStore.isNotEmpty) {
      // Try to match ignoring case and whitespace
      final match = cityOptions.firstWhere(
        (c) => c.trim().toLowerCase() == cityFromStore.trim().toLowerCase(),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        selectedCity = match;
      } else {
        selectedCity = null;
      }
    } else {
      selectedCity = null;
    }
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
            const Divider(),
            const StyledHeading('LOCATION'),
            SizedBox(height: width * 0.02),
            Padding(
              padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
              child: DropdownButtonFormField<String>(
                value: selectedCity,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                dropdownColor: Colors.white,
                hint: const Text('Select a city'),
                items: cityOptions.map((city) {
                  return DropdownMenuItem<String>(
                    value: city,
                    child: Text(city),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    selectedCity = val;
                  });
                },
              ),
            ),
            SizedBox(height: width * 0.05),
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
                  selectedCity = null;
                  widget.setValues(getColours(), getSizes(), getPrices(), selectedCity);
                  widget.setFilter(getFilterOn(), noOfFilters);
                  Provider.of<ItemStoreProvider>(context, listen: false)
                      .cityFilterSetter(null);
                  // Provider.of<ItemStoreProvider>(context, listen: false).sizesFilterSetter(sizeMap);
                  // Provider.of<ItemStoreProvider>(context, listen: false).rangeValuesFilterSetter(rangeVals);
                  // Provider.of<ItemStoreProvider>(context, listen: false).coloursFilterSetter(colourMap);
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
                    selectedCity);
                widget.setFilter(getFilterOn(), noOfFilters);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .sizesFilterSetter(sizeMap);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .rangeValuesFilterSetter(rangeVals);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .coloursFilterSetter(colourMap);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .rangeValuesFilterSetter(rangeVals);
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .cityFilterSetter(selectedCity);
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

  void setValues(
    List<String> filterColours,
    List<String> filterSizes,
    RangeValues rangeValuesFilter,
    String? city,
  ) {
    filterSizes = filterSizes;
    rangeValuesFilter = rangeValuesFilter;
    filterColours = {...filterColours}.toList();
    filterSizes = {...filterSizes}.toList();
    selectedCity = city;
    setState(() {});
  }
}
