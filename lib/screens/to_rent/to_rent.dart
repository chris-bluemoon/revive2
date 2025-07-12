import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import at the top
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/messages/message_conversation_page.dart';
import 'package:revivals/screens/profile/profile.dart';
import 'package:revivals/screens/to_rent/_bookmark_button.dart';
import 'package:revivals/screens/to_rent/_favourite_button.dart';
import 'package:revivals/screens/to_rent/item_widget.dart';
import 'package:revivals/screens/to_rent/rent_for_longer.dart';
import 'package:revivals/screens/to_rent/to_rent_bottom_bar.dart';
import 'package:revivals/screens/to_rent/user_card.dart';
import 'package:revivals/screens/to_rent/you_may_also_like.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/smooth_page_route.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

// ignore: must_be_immutable
class ToRent extends StatefulWidget {
  const ToRent(this.item, {super.key});

  @override
  State<ToRent> createState() => _ToRentState();

  final Item item;
  // late String itemName;
  // late String imageName;
  // late String itemType;

  // String setItemImage() {
  //   itemType = item.type.replaceAll(RegExp(' '), '_');
  //   itemName = item.name.replaceAll(RegExp(' '), '_');
  //   imageName = '${item.brand}_${itemName}_${itemType}.webp';
  //   return imageName;
  // }

  // final ValueNotifier<int> rentalDays = ValueNotifier<int>(0);
}

class _ToRentState extends State<ToRent> {
  List items = [];
  int currentIndex = 1; // Start carousel on item 2 (index 1)
  bool itemCheckComplete = false;
  List<Color> dotColours = [];
  // bool showMessageBox = false;

  CarouselSliderController buttonCarouselSliderController =
      CarouselSliderController();

  String convertedrentPriceDaily = '-1';
  String convertedBuyPrice = '-1';
  String convertedRRPPrice = '-1';
  String symbol = globals.thb;

  String ownerName = 'Jane Doe';
  String location = 'UK';

  bool isOwner = false;

  int getPricePerDay(noOfDays) {
    // String country = Provider.of<ItemStoreProvider>(context, listen: false)
        // .renter
        // .settings[0];
    String country = 'BANGKOK'; // Default to Bangkok for now

    int oneDayPrice = widget.item.rentPrice1;

    if (country == 'BANGKOK') {
      oneDayPrice = widget.item.rentPrice1;
    } else {
      oneDayPrice = int.parse(convertFromTHB(widget.item.rentPrice1, country));
    }

    if (noOfDays == 2) {
      int twoDayPrice = (oneDayPrice * 0.8).toInt() - 1;
      if (country == 'BANGKOK') {
        return (twoDayPrice ~/ 100) * 100 + 100;
      } else {
        return (twoDayPrice ~/ 5) * 5 + 5;
      }
    }
    if (noOfDays == 3) {
      int threeDayPrice = (oneDayPrice * 0.6).toInt() - 1;
      if (country == 'BANGKOK') {
        return (threeDayPrice ~/ 100) * 100 + 100;
      } else {
        return (threeDayPrice ~/ 5) * 5 + 5;
      }
    }
    if (noOfDays == 4) {
      int fourDayPrice = (oneDayPrice * 0.4).toInt() - 1;
      if (country == 'BANGKOK') {
        return (fourDayPrice ~/ 100) * 100 + 100;
      } else {
        return (fourDayPrice ~/ 5) * 5 + 5;
      }
    }
    return oneDayPrice;
  }

  @override
  void initState() {
    // setPrice();
    _initImages();
    for (Renter r
        in Provider.of<ItemStoreProvider>(context, listen: false).renters) {
      log('Renter: ${r.name}, Owner: ${widget.item.owner}');
      if (widget.item.owner == r.id) {
        log('Owner found: ${r.name}');
        ownerName = r.name;
        location = 'BANGKOK';
      }
      if (widget.item.owner ==
          Provider.of<ItemStoreProvider>(context, listen: false).renter.id) {
        isOwner = true;
      }
    }

    super.initState();
  }

  void setPrice() {
      String country = 'BANGKOK';
    if (country == 'BANGKOK') {
      // String country = Provider.of<ItemStoreProvider>(context, listen: false)
          // .renter
          // .settings[0];
      convertedrentPriceDaily = getPricePerDay(5).toString();
      // convertedrentPriceDaily = convertFromTHB(getPricePerDay(1), country);
      convertedBuyPrice = convertFromTHB(widget.item.buyPrice, country);
      convertedRRPPrice = convertFromTHB(widget.item.rrp, country);
      symbol = getCurrencySymbol(country);
    } else {
      convertedrentPriceDaily = getPricePerDay(5).toString();
      convertedBuyPrice = widget.item.buyPrice.toString();
      convertedRRPPrice = widget.item.rrp.toString();
      symbol = globals.thb;
    }
  }

  Future _initImages() async {
    int counter = 0;
    for (String _ in widget.item.imageId) {
      counter++;
      items.add(counter);
      dotColours.add(Colors.grey);
    }
    setState(() {
      itemCheckComplete = true;
    });
  }

  // setSendMessagePressedToFalse() {
  //   setState(() {
  //     showMessageBox = false;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: SizedBox(
          width: width * 0.7, // Adjust as needed for your layout
          child: Text(
            widget.item.name,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
            softWrap: true,            // <-- Ensure wrapping
            maxLines: 3,               // <-- Allow up to 3 lines (adjust as needed)
            overflow: TextOverflow.visible, // <-- Show all lines, no ellipsis
            textAlign: TextAlign.center,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, size: width * 0.08),
            onPressed: () {
              showModalBottomSheet(
                backgroundColor: Colors.white,
                // barrierColor: Colors.white, // Make the overlay background white
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.share),
                          title: const Text('Share'),
                          onTap: () async {
                            Navigator.pop(context);
                            final shareText = 'Check out this item on Revive: \\${widget.item.name}';
                            try {
                              await Share.share(shareText);
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to share: \\$e')),
                              );
                            }
                          },
                        ),
                        if (!isOwner)
                          ListTile(
                            leading: const Icon(Icons.report),
                            title: const Text('Report as inappropriate'),
                            onTap: () async {
                              Navigator.pop(context);
                              // Add report to Firebase (Firestore)
                              try {
                                final report = {
                                  'itemId': widget.item.id,
                                  'itemName': widget.item.name,
                                  'reportedUserId': widget.item.owner,
                                  'reportedUserName': ownerName,
                                  'reason': 'Item Report',
                                  'timestamp': DateTime.now().toIso8601String(),
                                };
                                // Use Firebase Firestore
                                // ignore: avoid_dynamic_calls
                                await FirebaseFirestore.instance.collection('reports').add(report);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reported. Thank you!')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Failed to report: \\$e')),
                                );
                              }
                            },
                          ),
                        ListTile(
                          leading: const Icon(Icons.close),
                          title: const Text('Cancel'),
                          onTap: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: (!itemCheckComplete)
          ? const Text('Loading')
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: width * 0.01),
                  (items.length == 1)
                      ? SizedBox(
                          height: width,
                          child: Center(
                              child:
                                  ItemWidget(item: widget.item, itemNumber: 1)))
                      : Column(
                          children: [
                            CarouselSlider(
                              carouselController: buttonCarouselSliderController,
                              options: CarouselOptions(
                                  initialPage: 1, // Start on item 2
                                  onPageChanged: (index, reason) {
                                    setState(() {
                                      currentIndex = index;
                                    });
                                  },
                                  height: width * 1,
                                  autoPlay: true,
                                  viewportFraction: 0.85,
                              ),
                              items: items.map((index) {
                                return Builder(
                                  builder: (BuildContext context) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: SizedBox(
                                        width: width * 0.85,
                                        height: width * 0.8,
                                        child: ItemWidget(item: widget.item, itemNumber: index),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                            SizedBox(height: width * 0.04),
                          ],
                        ),
                  SizedBox(height: width * 0.03),
                  // DotsIndicator, Email, and BookmarkButton on the same line
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: SizedBox(
                      height: width * 0.09,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          if (items.length > 1)
                            Center(
                              child: DotsIndicator(
                                dotsCount: items.length,
                                position: currentIndex,
                                decorator: DotsDecorator(
                                  colors: dotColours,
                                  activeColor: Colors.black,
                                ),
                              ),
                            ),
                          // Remove the heart icon from the left
                          // Place the heart icon next to the bookmark on the right
                          Align(
                            alignment: Alignment.centerRight,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isOwner)
                                  SizedBox(
                                    height: width * 0.09, // Increase icon size
                                    width: width * 0.09,
                                    child: FavouriteButton(item: widget.item),
                                  ), // Heart icon now here
                                if (!isOwner) const SizedBox(width: 6),
                                SizedBox(
                                  height: width * 0.09,
                                  width: width * 0.09,
                                  child: BookmarkButton(item: widget.item),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: width * 0.03),
                  Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0),
                    child: Row(
                      children: [
                        // Avatar and owner/location info
                        GestureDetector(
                          onTap: () {
                            final renters = Provider.of<ItemStoreProvider>(context, listen: false).renters;
                            final ownerList = renters.where((r) => r.name == ownerName).toList();
                            final owner = ownerList.isNotEmpty ? ownerList.first : null;
                            if (owner != null && owner.name.isNotEmpty) {
                              log('Owner name: \\${owner.name}');
                              Navigator.of(context).push(
                                SmoothTransitions.luxury(Profile(userN: owner.name, canGoBack: true,)),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('User not found')),
                              );
                            }
                          },
                          child: UserCard(ownerName, location),
                        ),
                        // Spacer to push the icon to the far right
                        const Spacer(),
                        if (!isOwner)
                          IconButton(
                            icon: Icon(Icons.chat_bubble_outline, color: Colors.black, size: width * 0.06), // Reduced size
                            onPressed: () {
                              final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                              if (!itemStore.loggedIn) {
                                showMessagingAlertDialog(context);
                                return;
                              }
                              final renters = itemStore.renters;
                              final ownerList = renters.where((r) => r.id == widget.item.owner).toList();
                              final owner = ownerList.isNotEmpty ? ownerList.first : null;
                              Navigator.of(context).push(
                                SmoothTransitions.luxury(MessageConversationPage(
                                  currentUserId: itemStore.renter.id,
                                  otherUserId: widget.item.owner,
                                  otherUser: {
                                    'name': ownerName,
                                    'profilePicUrl': owner?.imagePath ?? '',
                                  },
                                )),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                  Padding(
                    padding: EdgeInsets.all(width * 0.05),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Add the brand above the description
                        StyledHeading(
                          widget.item.brand,
                          color: Colors.black54,
                          fontSize: width * 0.045,
                          weight: FontWeight.bold,
                        ),
                        SizedBox(height: width * 0.01),
                        // --- Make description wrap ---
                        Text(
                          widget.item.description,
                          style: TextStyle(
                            fontSize: width * 0.042,
                            fontWeight: FontWeight.normal,
                            color: Colors.black,
                          ),
                          softWrap: true,
                          maxLines: 5,
                          overflow: TextOverflow.visible,
                        ),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        // REMOVE: Row with type and size
                        // --- Product details section ---
                        Padding(
                          padding: EdgeInsets.only(top: width * 0.01),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StyledBody(
                                    "Product Type",
                                    weight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: width * 0.042,
                                  ),
                                  StyledBody(
                                    widget.item.type,
                                    weight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: width * 0.042,
                                  ),
                                ],
                              ),
                              // If item is a dress, show size under Product Type
                              if (widget.item.type.toLowerCase() == 'dress' && widget.item.size.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    StyledBody(
                                      "Size",
                                      weight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontSize: width * 0.042,
                                    ),
                                    StyledBody(
                                      "UK ${widget.item.size}",
                                      weight: FontWeight.bold,
                                      color: Colors.black,
                                      fontSize: width * 0.042,
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StyledBody(
                                    "${widget.item.minDays} Day Rental Price",
                                    weight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: width * 0.042,
                                  ),
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPrice1)}$symbol",
                                    weight: FontWeight.bold,
                                    color: Colors.black,
                                    fontSize: width * 0.042,
                                  ),
                                ],
                              ),
                              // Show Buy Price if booking type is "buy" or "both"
                              if (widget.item.bookingType == "buy" || widget.item.bookingType == "both") ...[
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    StyledBody(
                                      "Buy Price",
                                      weight: FontWeight.bold,
                                      color: Colors.grey,
                                      fontSize: width * 0.042,
                                    ),
                                    StyledBody(
                                      "${NumberFormat('#,###').format(widget.item.buyPrice)}$symbol",
                                      weight: FontWeight.bold, // <-- Make value bold
                                      color: Colors.black,
                                      fontSize: width * 0.042,
                                    ),
                                  ],
                                ),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StyledBody(
                                    "Minimal Rental Period",
                                    weight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: width * 0.042,
                                  ),
                                  StyledBody(
                                    '${widget.item.minDays} ${widget.item.minDays == 1 ? "day" : "days"}',
                                    weight: FontWeight.bold, // <-- Make value bold
                                    color: Colors.black,
                                    fontSize: width * 0.042,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                    child: Divider(
                      color: Colors.grey[400],
                      thickness: 1,
                      height: 0,
                    ),
                  ),
                  SizedBox(height: width * 0.04), // <-- Increased gap below divider
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.02, bottom: width * 0.01),
                    child: StyledBody(
                      'Extend your rental period for better rates',
                      fontSize: width * 0.042,
                      weight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(height: width * 0.04), // <-- Increased gap below "Rent for longer" text
                  RentForLonger(
                    item: widget.item,
                    symbol: symbol,
                    options: [
                      {
                        'days': widget.item.minDays,
                        'price': widget.item.rentPrice1,
                        'label': '${widget.item.minDays} Days',
                      },
                      {
                        'days': widget.item.minDays + 2,
                        'price': widget.item.rentPrice2,
                        'label': '${widget.item.minDays + 2} Days',
                      },
                      {
                        'days': widget.item.minDays + 4,
                        'price': widget.item.rentPrice3,
                        'label': '${widget.item.minDays + 4} Days',
                      },
                      {
                        'days': 14,
                        'price': widget.item.rentPrice4,
                        'label': '14 Days',
                      },
                    ],
                  ),
                  SizedBox(height: width * 0.02), // Further reduced gap below the cards
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.05,
                      right: width * 0.05,
                      top: width * 0.02,
                    ),
                    child: const Text(
                      "ALL PRICING IS FINAL, NO NEGOTIATIONS ALLOWED",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold, // <-- Make text bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: width * 0.04),
                  YouMayAlsoLike(item: widget.item, isOwner: isOwner),
                ],
              ),
            ),
      bottomNavigationBar: ToRentBottomBar(item: widget.item, isOwner: isOwner, isSubmission: false),
    );
  }
}

showMessagingAlertDialog(BuildContext context) {
  // Create button
  double width = MediaQuery.of(context).size.width;

  Widget okButton = ElevatedButton(
    style: OutlinedButton.styleFrom(
      textStyle: const TextStyle(color: Colors.white),
      foregroundColor: Colors.white, //change background color of button
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: const BorderSide(width: 1.0, color: Colors.black),
    ),
    onPressed: () {
      Navigator.of(context).pop(); // Just close the dialog
    },
    child: const Center(child: StyledHeading("OK", color: Colors.white)),
  );
  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white,
    title: const Center(child: StyledHeading("NOT LOGGED IN")),
    content: SizedBox(
      height: width * 0.2,
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("Please log in"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("or register to continue"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("to use messaging"),
            ],
          ),
        ],
      ),
    ),
    actions: [
      okButton,
    ],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showRentAlertDialog(BuildContext context) {
  // Create button
  double width = MediaQuery.of(context).size.width;

  Widget okButton = ElevatedButton(
    style: OutlinedButton.styleFrom(
      textStyle: const TextStyle(color: Colors.white),
      foregroundColor: Colors.white, //change background color of button
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: const BorderSide(width: 1.0, color: Colors.black),
    ),
    onPressed: () {
      Navigator.of(context).pop(); // Just close the dialog
    },
    child: const Center(child: StyledHeading("OK", color: Colors.white)),
  );
  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white,
    title: const Center(child: StyledHeading("NOT LOGGED IN")),
    content: SizedBox(
      height: width * 0.2,
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("Please log in"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("or register to continue"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("to rent this item"),
            ],
          ),
        ],
      ),
    ),
    actions: [
      okButton,
    ],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
