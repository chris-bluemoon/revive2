import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluralize/pluralize.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/profile/admin/to_rent_submission.dart';
import 'package:revivals/screens/to_rent/to_rent.dart';
import 'package:revivals/shared/filters_page.dart';
import 'package:revivals/shared/item_card.dart';
import 'package:revivals/shared/no_items_found.dart';
import 'package:revivals/shared/smooth_page_route.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class ItemResults extends StatefulWidget {
  const ItemResults(this.attribute, this.value, {this.values, super.key});

  final String attribute;
  final String value;
  final List<String>? values; // <-- Add this line

  @override
  State<ItemResults> createState() => _ItemResultsState();
}

class _ItemResultsState extends State<ItemResults> {
  Badge myBadge = const Badge(child: Icon(Icons.filter));

  List<Item> filteredItems = [];
  late List<String> sizes = [];
  late RangeValues ranges = const RangeValues(0, 0);
  late List<String> lengths = [];
  late List<String> prints = [];
  late List<String> sleeves = [];
  late Set coloursSet = <String>{};
  late Set sizesSet = <String>{};
  late bool filterOn = false;
  late int numOfFilters = 0;

  void setValues(
      List<String> filterColours,
      List<String> filterSizes,
      RangeValues rangeValuesFilter,
      List<String> filterLengths,
      List<String> filterPrints,
      List<String> filterSleeves) {
    sizes = filterSizes;
    lengths = filterLengths;
    ranges = rangeValuesFilter;
    prints = filterPrints;
    sleeves = filterSleeves;
    coloursSet = {...filterColours};
    sizesSet = {...filterSizes};
    setState(() {});
  }

  void setFilter(bool filter, int noOfFilters) {
    filterOn = filter;
    numOfFilters = noOfFilters;
    setState(() {});
  }

  late List<Item> allItems = [];

  @override
  void initState() {
    // TODO: implement initState
    log('Item count: ${Provider.of<ItemStoreProvider>(context, listen: false).items.length}');
    for (Item i
        in Provider.of<ItemStoreProvider>(context, listen: false).items) {
      if (i.status == 'submitted' && widget.attribute == 'status') {
        allItems.add(i);
      } else if (i.status == 'accepted' && widget.attribute != 'status') {
        allItems.add(i);
      } else if (i.status == 'denied' && widget.attribute == 'status') {
        allItems.add(i);
      }
    }
    log('All items: ${allItems.length}');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    // getCurrentUser();
    List<Item> finalItems = [];
    filteredItems.clear();
    log('Attribute: ${widget.attribute}, Value: ${widget.value}');
    if (filterOn == true) {
      switch (widget.attribute) {
        case 'search':
          // widget.value is expected to be a List<String> of search terms
          List<String> searchTerms = [];
          searchTerms = widget.values!;
          for (Item i in allItems) {
            if (i.hashtags.any((tag) => searchTerms.contains(tag))) {
              filteredItems.add(i);
            }
          }
          break;
        case 'hashtag':
          for (Item i in allItems) {
            if (i.hashtags.contains(widget.value)) {
              filteredItems.add(i);
            }
          }
        case 'myItems':
          for (Item i in allItems) {
            if (i.owner == widget.value) {
              filteredItems.add(i);
            }
          }
        case 'status':
          for (Item i in allItems) {
            log('Item status: ${i.status}');
            if (i.status == widget.value) {
              filteredItems.add(i);
            }
          }
        case 'brand':
          for (Item i in allItems) {
            if (i.brand == widget.value) {
              filteredItems.add(i);
            }
          }
        case 'type':
          for (Item i in allItems) {
            if (i.type == widget.value) {
              filteredItems.add(i);
            }
          }
        case 'bookingType':
          for (Item i in allItems) {
            if (i.bookingType == widget.value || i.bookingType == 'both') {
              filteredItems.add(i);
            }
          }
        case 'dateAdded':
          for (Item i in allItems) {
            DateFormat format = DateFormat("dd-MM-yyyy");
            DateTime dateSupplied = format.parse(widget.value);
            DateTime dateAdded = format.parse(i.dateAdded);
            if (dateAdded.isAfter(dateSupplied)) {
              filteredItems.add(i);
            }
          }
      }
      for (Item i in filteredItems) {
        Set colourSet = {i.colour};
        // TODO: FIX THIS
        if (
            coloursSet.intersection(colourSet).isNotEmpty &&
            sizesSet.contains(i.size) &&
            i.rentPriceDaily > ranges.start &&
            i.rentPriceDaily < ranges.end) {
        // if (coloursSet.intersection(colourSet).isNotEmpty) {
          finalItems.add(i);
        }
      }
    } else {
      for (Item i in allItems) {
        log('Item: ${i.name}, Attribute: ${widget.attribute}, Value: ${widget.value}');
        switch (widget.attribute) {
          case 'search':
            List<String> searchTerms = [];
            if (widget.values != null) {
              searchTerms = widget.values!.map((s) => s.toLowerCase()).toList();
              log('Search terms: $searchTerms');
            }
            // Check hashtags, colour, brand (any word), and name (any word) fields for any match with searchTerms (case-insensitive)
            bool matchesHashtag = i.hashtags.any((tag) => searchTerms.contains(tag.toLowerCase()));
            bool matchesColour = searchTerms.any((term) => i.colour.toLowerCase() == term);
            // Split brand into words and check if any word matches a search term
            bool matchesBrand = i.brand
                .split(RegExp(r'\s+'))
                .any((word) => searchTerms.contains(word.toLowerCase()));
            // Split name into words and check if any word matches a search term
            bool matchesName = i.name
                .split(RegExp(r'\s+'))
                .any((word) => searchTerms.contains(word.toLowerCase()));
            if (matchesHashtag || matchesColour || matchesBrand || matchesName) {
              finalItems.add(i);
            }
            break;
          case 'hashtag':
            if (i.hashtags.contains(widget.value)) {
              finalItems.add(i);
            }
          case 'myItems':
            if (i.owner == widget.value) {
              finalItems.add(i);
            }
          case 'status':
            if (i.status == widget.value) {
              log('Item status: ${i.status}');
              finalItems.add(i);
            }
          case 'brand':
            if (i.brand == widget.value) {
              finalItems.add(i);
            }
          case 'type':
            if (i.type == widget.value) {
              finalItems.add(i);
            }
          case 'bookingType':
            if (i.bookingType == widget.value || i.bookingType == 'both') {
              finalItems.add(i);
            }
          case 'dateAdded':
            for (Item i in allItems) {
              DateFormat format = DateFormat("dd-MM-yyyy");
              DateTime dateSupplied = format.parse(widget.value);
              DateTime dateAdded = format.parse(i.dateAdded);
              if (dateAdded.isAfter(dateSupplied)) {
                finalItems.add(i);
              }
            }
        }
      }
    }
    String setTitle(attribute) {
      String title = '';
      switch (attribute) {
        case 'hashtag':
          {
            log('attribute: $attribute');
            title = widget.value.toUpperCase();
          }
        case 'dateAdded':
          {
            title = 'LATEST ADDITIONS';
          }
        case 'status':
          {
            title = 'SUBMISSIONS';
          }
        case 'myItems':
          {
            title = 'MY ITEMS';
          }
        case 'brand':
          {
            title = widget.value.toUpperCase();
          }
        case 'bookingType':
          {
            title = Pluralize().plural(widget.value).toUpperCase();
          }
      }

      return title;
    }

    return Consumer<ItemStoreProvider>(builder: (context, value, child) {
      return Scaffold(
          appBar: AppBar(
            toolbarHeight: width * 0.2,
            title: StyledTitle(setTitle(widget.attribute)),
            centerTitle: true,
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: Icon(Icons.chevron_left, size: width * 0.08),
              onPressed: () {
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .resetFilters();
                Navigator.pop(context);
              },
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(SmoothTransitions.luxury(FiltersPage(
                          setFilter: setFilter, setValues: setValues)));
                },
                child: Padding(
                    padding:
                        EdgeInsets.fromLTRB(0, width * 0.0, width * 0.03, 0),
                    child: (numOfFilters == 0)
                        ? Image.asset('assets/img/icons/1.png',
                            height: width * 0.1)
                        : (numOfFilters == 1)
                            ? Image.asset('assets/img/icons/2.png',
                                height: width * 0.1)
                            : (numOfFilters == 2)
                                ? Image.asset('assets/img/icons/3.png',
                                    height: width * 0.1)
                                : (numOfFilters == 3)
                                    ? Image.asset('assets/img/icons/4.png',
                                        height: width * 0.1)
                                    : (numOfFilters == 4)
                                        ? Image.asset('assets/img/icons/5.png',
                                            height: width * 0.1)
                                        : (numOfFilters == 5)
                                            ? Image.asset(
                                                'assets/img/icons/6.png',
                                                height: width * 0.1)
                                            : (numOfFilters == 6)
                                                ? Image.asset(
                                                    'assets/img/icons/7.png',
                                                    height: width * 0.1)
                                                : Image.asset(
                                                    'assets/img/icons/1.png',
                                                    width: width * 0.01)),
              ),
            ],
          ),
          body: (finalItems.isNotEmpty)
              ? Container(
                  color: Colors.white,
                  child: Consumer<ItemStoreProvider>(
                      builder: (context, value, child) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2, childAspectRatio: 0.5),
                      itemCount: finalItems.length,
                      itemBuilder: (_, index) => GestureDetector(
                          child: SizedBox(
                                  width: width * 0.5, // Constrain width
                                  // Removed fixed height to let IntrinsicHeight work
                                  child: ItemCard(finalItems[index])),
                          onTap: () {
                            final item = finalItems[index];
                            // final currentUserId = Provider.of<ItemStoreProvider>(context, listen: false).renter.id;
                            if (widget.attribute != 'status') {
                              Navigator.of(context).push(SmoothTransitions.luxury(ToRent(item)));
                            } else if (widget.attribute == 'status') {
                              Navigator.of(context).push(SmoothTransitions.luxury(ToRentSubmission(item)));
                            } 
                          }),
                    );
                  }),
                )
              : NoItemsFound(
                  isMyItems: widget.attribute == 'myItems' && !filterOn,
                ),
          floatingActionButton: null);
    });
  }
}
