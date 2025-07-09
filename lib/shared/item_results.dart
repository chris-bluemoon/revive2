import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pluralize/pluralize.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/create/create_item.dart';
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

  String? selectedCity;
  void setValues(
      List<String> filterColours,
      List<String> filterSizes,
      RangeValues rangeValuesFilter,
      String? city) {
    sizes = filterSizes;
    ranges = rangeValuesFilter;
    coloursSet = {...filterColours};
    sizesSet = {...filterSizes};
    selectedCity = city;
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
    log('Filter is on: $filterOn');
    if (filterOn == true) {
      // Filter by city/location using the owner's location
      List<Item> cityFilteredItems = [];
      final renters = Provider.of<ItemStoreProvider>(context, listen: false).renters;
      if (selectedCity != null && selectedCity!.isNotEmpty) {
        for (Item i in allItems) {
          final matches = renters.where((r) => r.id == i.owner);
          final owner = matches.isNotEmpty ? matches.first : null;
          if (owner != null &&
              owner.location.trim().toLowerCase() == selectedCity!.trim().toLowerCase()) {
            cityFilteredItems.add(i);
          }
        }
      } else {
        cityFilteredItems = List.from(allItems);
      }
      // Now apply other filters to cityFilteredItems
      for (Item i in cityFilteredItems) {
        Set colourSet = {i.colour};
        if (
            coloursSet.intersection(colourSet).isNotEmpty &&
            sizesSet.contains(i.size) &&
            i.rentPriceDaily > ranges.start &&
            i.rentPriceDaily < ranges.end) {
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
                      itemBuilder: (_, index) {
                        final item = finalItems[index];
                        if (widget.attribute == 'myItems') {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              GestureDetector(
                                child: SizedBox(
                                  width: width * 0.5,
                                  child: ItemCard(item),
                                ),
                                onTap: () async {
                                  final action = await showModalBottomSheet<String>(
                                    context: context,
                                    builder: (context) {
                                      return SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: const Icon(Icons.visibility),
                                              title: const Text('View'),
                                              onTap: () => Navigator.of(context).pop('view'),
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.edit),
                                              title: const Text('Edit'),
                                              onTap: () => Navigator.of(context).pop('edit'),
                                            ),
                                            ListTile(
                                              leading: const Icon(Icons.delete, color: Colors.red),
                                              title: const Text('Delete', style: TextStyle(color: Colors.red)),
                                              onTap: () => Navigator.of(context).pop('delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );

                                  if (action == 'view') {
                                    Navigator.of(context).push(SmoothTransitions.luxury(ToRent(item)));
                                  } else if (action == 'edit') {
                                    Navigator.of(context).push(
                                      SmoothTransitions.luxury(
                                        CreateItem(
                                          item: item,
                                        ),
                                      ),
                                    );
                                  } else if (action == 'delete') {
                                    setState(() {
                                      item.status = 'deleted';
                                      Provider.of<ItemStoreProvider>(context, listen: false).saveItem(item);
                                      allItems.removeWhere((i) => i.id == item.id); // Remove from allItems so it won't show up in finalItems
                                    });
                                  }
                                },
                              ),
                              const SizedBox(height: 4),
                            ],
                          );
                        } else {
                          return GestureDetector(
                            child: SizedBox(
                              width: width * 0.5,
                              child: ItemCard(item),
                            ),
                            onTap: () {
                              if (widget.attribute != 'status') {
                                Navigator.of(context).push(SmoothTransitions.luxury(ToRent(item)));
                              } else if (widget.attribute == 'status') {
                                Navigator.of(context).push(SmoothTransitions.luxury(ToRentSubmission(item)));
                              }
                            },
                          );
                        }
                      },
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
