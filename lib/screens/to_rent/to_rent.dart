import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Add this import at the top
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/create/create_item.dart';
import 'package:revivals/screens/messages/message_conversation_page.dart';
import 'package:revivals/screens/profile/profile.dart';
import 'package:revivals/screens/summary/summary_purchase.dart';
import 'package:revivals/screens/to_rent/_bookmark_button.dart';
import 'package:revivals/screens/to_rent/item_widget.dart';
import 'package:revivals/screens/to_rent/rent_this_with_date_selecter.dart';
import 'package:revivals/screens/to_rent/user_card.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/item_card.dart';
import 'package:revivals/shared/smooth_page_route.dart';
import 'package:revivals/shared/styled_text.dart';
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
  int currentIndex = 0;
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

    int oneDayPrice = widget.item.rentPriceDaily;

    if (country == 'BANGKOK') {
      oneDayPrice = widget.item.rentPriceDaily;
    } else {
      oneDayPrice = int.parse(convertFromTHB(widget.item.rentPriceDaily, country));
    }

    if (noOfDays == 3) {
      int threeDayPrice = (oneDayPrice * 0.8).toInt() - 1;
      if (country == 'BANGKOK') {
        return (threeDayPrice ~/ 100) * 100 + 100;
      } else {
        return (threeDayPrice ~/ 5) * 5 + 5;
      }
    }
    if (noOfDays == 5) {
      int fiveDayPrice = (oneDayPrice * 0.6).toInt() - 1;
      if (country == 'BANGKOK') {
        return (fiveDayPrice ~/ 100) * 100 + 100;
      } else {
        return (fiveDayPrice ~/ 5) * 5 + 5;
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
              onPressed: () =>
                  {Navigator.of(context).popUntil((route) => route.isFirst)},
              icon: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, width * 0.01, 0),
                child: Icon(Icons.close, size: width * 0.06),
              )),
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
                  // DotsIndicator and BookmarkButton on the same line
                  if (items.length > 1)
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Align(
                              alignment: Alignment.center,
                              child: DotsIndicator(
                                dotsCount: items.length,
                                position: currentIndex,
                                decorator: DotsDecorator(
                                  colors: dotColours,
                                  activeColor: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          BookmarkButton(item: widget.item),
                        ],
                      ),
                    ),
                  SizedBox(height: width * 0.03),
                  Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.05, 0, 0, 0),
                    child: Row(
                      children: [
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
                        if (!isOwner)
                          IconButton(
                            onPressed: () {
                              // Check if user is logged in
                              final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                              if (!itemStore.loggedIn) {
                                showMessagingAlertDialog(context);
                                return;
                              }
                              final renters = Provider.of<ItemStoreProvider>(context, listen: false).renters;
                              final ownerList = renters.where((r) => r.id == widget.item.owner).toList();
                              final owner = ownerList.isNotEmpty ? ownerList.first : null;
                              Navigator.of(context).push(
                                SmoothTransitions.luxury(MessageConversationPage(
                                    currentUserId: Provider.of<ItemStoreProvider>(context, listen: false).renter.id,
                                    otherUserId: widget.item.owner,
                                    otherUser: {
                                      'name': ownerName,
                                      'profilePicUrl': owner?.imagePath ?? '',
                                    },
                                  )),
                              );
                            },
                            icon: Icon(Icons.email_outlined, size: width * 0.05),
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
                        StyledHeading(widget.item.description),
                        SizedBox(height: MediaQuery.of(context).size.height * 0.01),
                        Row(
                          children: [
                            // Item type to the left of the size, with a comma
                            StyledBody(
                              widget.item.type +
                                  (widget.item.type.toLowerCase() == 'dress' ? ',' : ''),
                              weight: FontWeight.normal,
                              fontSize: width * 0.042, // <-- Set font size here
                            ),
                            if (widget.item.type.toLowerCase() == 'dress') ...[
                              SizedBox(width: width * 0.01),
                              StyledBody(
                                widget.item.size.isNotEmpty ? "UK ${widget.item.size}" : '',
                                weight: FontWeight.normal,
                                fontSize: width * 0.042, // <-- Set font size here
                              ),
                            ],
                          ],
                        ),
                        // Move long description here, directly below type and size
                        if (widget.item.longDescription.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.only(top: width * 0.02),
                            child: StyledBody(
                              widget.item.longDescription,
                              weight: FontWeight.normal,
                              fontSize: width * 0.042, // <-- Set font size here
                            ),
                          ),
                        SizedBox(height: width * 0.04),
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
                                    weight: FontWeight.bold, // <-- Make value bold
                                    color: Colors.black,
                                    fontSize: width * 0.042,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StyledBody(
                                    "Colour",
                                    weight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: width * 0.042,
                                  ),
                                  StyledBody(
                                    widget.item.colour.isNotEmpty ? widget.item.colour : '',
                                    weight: FontWeight.bold, // <-- Make value bold
                                    color: Colors.black,
                                    fontSize: width * 0.042,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  StyledBody(
                                    "Daily Rental Price",
                                    weight: FontWeight.bold,
                                    color: Colors.grey,
                                    fontSize: width * 0.042,
                                  ),
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPriceDaily)}$symbol",
                                    weight: FontWeight.bold, // <-- Make value bold
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
                      height: 0, // Remove extra height from Divider itself
                    ),
                  ),
                  SizedBox(height: width * 0.04), // Make the gap above and below the divider the same
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.05, bottom: width * 0.05),
                    child: StyledBody(
                        'Rent for longer to save on pricing.',
                        fontSize: width * 0.042, // Make this text bigger
                        weight: FontWeight.normal,
                      ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: width * 0.00),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // 1st card: minDays
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.black12),
                            ),
                            elevation: 2,
                            margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.01),
                              child: Column(
                                children: [
                                  StyledBody(
                                    "${widget.item.minDays} days",
                                    weight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 6),
                                  // Per day price uses rentPriceDaily
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPriceDaily)}$symbol / day",
                                    weight: FontWeight.normal,
                                  ),
                                  const SizedBox(height: 6),
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPriceDaily * widget.item.minDays)}$symbol total",
                                    weight: FontWeight.normal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 2nd card: Weekly (7 days)
                        Expanded(
                          child: Card(
                            color: Colors.green[50], // Light green background
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.black12),
                            ),
                            elevation: 2,
                            margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.01),
                              child: Column(
                                children: [
                                  // "Recommended" label above "Weekly"
                                  const StyledBody(
                                    "Suggested", // Changed from "Recommended"
                                    weight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                  const SizedBox(height: 4),
                                  const StyledBody(
                                    "7 Days",
                                    weight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 6),
                                  // Per day price uses rentPrice7 / 7
                                  StyledBody(
                                    "${NumberFormat('#,###').format((widget.item.rentPrice7 / 7).floor())}$symbol / day",
                                    weight: FontWeight.normal,
                                  ),
                                  const SizedBox(height: 6),
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPrice7)}$symbol total",
                                    weight: FontWeight.normal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        // 3rd card: Monthly (30 days)
                        Expanded(
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Colors.black12),
                            ),
                            elevation: 2,
                            margin: EdgeInsets.symmetric(horizontal: width * 0.01),
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: width * 0.03, horizontal: width * 0.01),
                              child: Column(
                                children: [
                                  const StyledBody(
                                    "14 Days",
                                    weight: FontWeight.bold,
                                  ),
                                  const SizedBox(height: 6),
                                  // Per day price uses rentPrice14 / 14
                                  StyledBody(
                                    "${NumberFormat('#,###').format((widget.item.rentPrice14 / 14).floor())}$symbol / day",
                                    weight: FontWeight.normal,
                                  ),
                                  const SizedBox(height: 6),
                                  StyledBody(
                                    "${NumberFormat('#,###').format(widget.item.rentPrice14)}$symbol total",
                                    weight: FontWeight.normal,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: width * 0.03), // Make the gap above and below the cards the same
                  Padding(
                    padding: EdgeInsets.only(
                      left: width * 0.05,
                      right: width * 0.05,
                      top: width * 0.02,
                    ),
                    child: const Text(
                      "ALL PRICING IS FINAL, NEGOTIATION IS NOT ALLOWED.",
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold, // <-- Make text bold
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: width * 0.04),
                  Consumer<ItemStoreProvider>(
  builder: (context, store, _) {
    log('isOwner: $isOwner');
    final allAcceptedItems = store.items.where((i) => i.status == "accepted").toList();
    final brandItems = allAcceptedItems
        .where((i) =>
            i.brand == widget.item.brand &&
            i.id != widget.item.id)
        .toList();
    if (brandItems.isEmpty || isOwner) {
      return const SizedBox.shrink();
    }
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(
            left: width * 0.05,
            right: width * 0.05,
            top: width * 0.04,
            bottom: width * 0.01,
          ),
          child: const Text(
            "YOU MAY ALSO LIKE",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 18,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: EdgeInsets.only(
            left: width * 0.05,
            right: width * 0.05,
            bottom: width * 0.03,
          ),
          child: SizedBox(
            height: width * 1,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: brandItems.length,
              itemBuilder: (context, index) {
                final item = brandItems[index];
                return Padding(
                  padding: EdgeInsets.only(right: width * 0.03),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        SmoothTransitions.luxury(ToRent(item)),
                      );
                    },
                    child: SizedBox(
                      width: width * 0.5,
                      height: width * 1, // or whatever fits your design
                      child: ItemCard(item),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  },
),
                ],
              ),
            ),
      bottomNavigationBar: SizedBox(
        height: 90, // Increased height for the bottom bar
        child: Container(
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
          child: Row(
            children: [
              // Only show the rentPriceDaily row if not in edit mode AND not both buy and rent
              if (!isOwner && widget.item.bookingType != 'both')
                Row(
                  children: [
                    StyledHeading(
                      "${NumberFormat('#,###').format(widget.item.rentPriceDaily)}$symbol / day",
                      color: Colors.black,
                    ),
                    StyledBody(
                      '  (${widget.item.minDays} ${widget.item.minDays == 1 ? "day)" : "days)"}',
                      color: Colors.black,
                    ),
                  const SizedBox(width: 10),
                  ],
                ),
              (widget.item.bookingType == 'buy' ||
                      widget.item.bookingType == 'both') && !isOwner
                  ? Expanded(
                      flex: widget.item.bookingType == 'both' ? 1 : 1, // Equal flex when both buttons are shown
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.of(context).push(SmoothTransitions.luxury(SummaryPurchase(
                                  widget.item,
                                  DateTime.now(),
                                  DateTime.now(),
                                  0,
                                  widget.item.buyPrice,
                                  'booked',
                                  symbol)));
                        },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18), // Match RENT button padding
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: const BorderSide(width: 1.0, color: Colors.black),
                          minimumSize: const Size(100, 44), // Match RENT button minimumSize
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'BUY',
                          style: TextStyle(
                            fontSize: width * 0.05,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 1.2,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                      ))
                  : const Expanded(child: SizedBox()),
              const SizedBox(width: 5),
              (widget.item.bookingType == 'rental' ||
                      widget.item.bookingType == 'both')
                  ? Expanded(
                      flex: (widget.item.bookingType == 'both' && !isOwner) ? 1 : 5, // Equal flex when both buttons are shown to non-owners, full width otherwise
                      child: isOwner
                          ? Row(
                              children: [
                                // DELETE button (logic from to_rent_edit)
                                Expanded(
                                  flex: 2, // Increased flex for wider buttons
                                  child: OutlinedButton(
                                    onPressed: () async {
                                      final store = Provider.of<ItemStoreProvider>(context, listen: false);

                                      // Confirm before deleting
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        barrierDismissible: false,
                                        builder: (context) => Center(
                                          child: ConstrainedBox(
                                            constraints: const BoxConstraints(
                                              maxWidth: 350, // Set a max width for the dialog
                                            ),
                                            child: AlertDialog(
                                              backgroundColor: Colors.white,
                                              shape: const RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(12)),
                                              ),
                                              titlePadding: const EdgeInsets.only(top: 32),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                              actionsPadding: const EdgeInsets.only(bottom: 24, top: 12),
                                              insetPadding: const EdgeInsets.symmetric(horizontal: 40),
                                              title: const Center(
                                                child: Text(
                                                  'Delete Item',
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              content: const Text(
                                                'Are you sure you want to delete this item?\nThis action cannot be undone.',
                                                textAlign: TextAlign.center,
                                              ),
                                              actionsAlignment: MainAxisAlignment.center,
                                              actions: [
                                                SizedBox(
                                                  width: 110,
                                                  child: OutlinedButton(
                                                    onPressed: () => Navigator.of(context).pop(false),
                                                    style: OutlinedButton.styleFrom(
                                                      backgroundColor: Colors.white,
                                                      side: const BorderSide(color: Colors.black, width: 1),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(0),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                    ),
                                                    child: const StyledHeading('Cancel', color: Colors.black),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                SizedBox(
                                                  width: 110,
                                                  child: OutlinedButton(
                                                    onPressed: () async {
                                                      // Call deleteItem before popping
                                                      store.deleteItemById(widget.item.id);

                                                      // Replace pop with popUntilReplace to go to the first route
                                                      Navigator.of(context).popUntil((route) {
                                                        if (route.isFirst) {
                                                          // Replace the first route with a new page if needed, or just return true to stop popping
                                                          return true;
                                                        }
                                                        return false;
                                                      });
                                                    },
                                                    style: OutlinedButton.styleFrom(
                                                      backgroundColor: Colors.red,
                                                      side: const BorderSide(color: Colors.red, width: 1),
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(0),
                                                      ),
                                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                                    ),
                                                    child: const StyledHeading('Delete', color: Colors.white),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ));
                                      // if (confirm == true) {
                                      //   final store = Provider.of<ItemStoreProvider>(context, listen: false);

                                      //   // Check for future bookings
                                      //   final hasFutureBooking = store.itemRenters.any((itemRenters) =>
                                      //       itemRenters.itemId == widget.item.id &&
                                      //       itemRenters.endDate.isAfter(DateTime.now()) &&
                                      //       itemRenters.status != 'cancelled');

                                      //   if (hasFutureBooking) {
                                      //     ScaffoldMessenger.of(context).showSnackBar(
                                      //       const SnackBar(
                                      //         content: Text('Cannot delete: This item has future bookings.'),
                                      //         backgroundColor: Colors.red,
                                      //       ),
                                      //     );
                                      //     return;
                                      //   }

                                      //   // Update item status to 'deleted'
                                      //   widget.item.status = 'deleted';
                                      //   store.saveItem(widget.item);

                                      //   // Pop back twice: first the dialog, then the ToRent screen
                                      //   Navigator.of(context).pop(); // Pop dialog
                                      //   Navigator.of(context).pop(); // Pop ToRent screen
                                      // }
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0), // More vertical padding, no horizontal
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: const BorderSide(width: 1.0, color: Colors.red),
                                      minimumSize: const Size(120, 48), // Wider and taller minimum size
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'DELETE',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontWeight: FontWeight.bold,
                                        fontSize: width * 0.05, // Larger font
                                        letterSpacing: 1.2,
                                      ),
                                      maxLines: 2, // Allow up to 2 lines
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12), // More space between buttons
                                // EDIT button
                                Expanded(
                                  flex: 2, // Increased flex for wider buttons
                                  child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                        SmoothTransitions.luxury(CreateItem(item: widget.item)),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0), // More vertical padding, no horizontal
                                      backgroundColor: Colors.black,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      side: const BorderSide(width: 1.0, color: Colors.black),
                                      minimumSize: const Size(120, 48), // Wider and taller minimum size
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'EDIT',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: width * 0.05, // Larger font
                                        letterSpacing: 1.2,
                                      ),
                                      maxLines: 2, // Allow up to 2 lines
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : OutlinedButton(
                              onPressed: () {
                                bool loggedIn = Provider.of<ItemStoreProvider>(context, listen: false).loggedIn;
                                if (loggedIn) {
                                  Navigator.of(context).push(SmoothTransitions.luxury(RentThisWithDateSelecter(widget.item)));
                                } else {
                                  showRentAlertDialog(context);
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                side: const BorderSide(width: 1.0, color: Colors.black),
                                minimumSize: const Size(100, 44),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'RENT',
                                style: TextStyle(
                                  fontSize: width * 0.05,// Changed from 18 to 16
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                            ),
                    )
                  : const Expanded(child: SizedBox()),
            ],
          ),
        ),
      ),
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
