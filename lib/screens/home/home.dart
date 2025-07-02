import 'dart:developer';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart'; // Make sure this import is correct for your ItemStoreProvider
import 'package:revivals/screens/authenticate/sign_in_up.dart';
// import 'package:revivals/screens/home/fitting_home_widget.dart';
import 'package:revivals/screens/home/home_page_bottom_card.dart';
import 'package:revivals/screens/home/new_arrivals_carousel.dart';
import 'package:revivals/screens/home/offer_home_widget.dart';
import 'package:revivals/screens/home/rentals_home_widget.dart';
import 'package:revivals/screens/home/to_buy_home_widget.dart';
import 'package:revivals/screens/messages/inbox_page.dart';
import 'package:revivals/shared/item_results.dart';
import 'package:revivals/shared/styled_text.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List items = [1, 2];
  int currentIndex = 0;

  CarouselSliderController buttonCarouselSliderController =
      CarouselSliderController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
      itemStore.fetchRentersOnce().then((_) {
        itemStore.fetchItemsOnce().then((_) {
          // Fetch images after items are loaded
          itemStore.fetchImages();
        });
        itemStore.fetchItemRentersOnce();
        // itemStore.fetchFittingRentersOnce();
        itemStore.fetchLedgersOnce();
        itemStore.fetchMessagesOnce();
        itemStore.fetchReviewsOnce();
        // itemStore.listenToMessages(itemStore.renter.id);
      });
    });
    log('Logged in status at Home.dart: ${Provider.of<ItemStoreProvider>(context, listen: false).loggedIn}');
  } // Initialize the items list or fetch it from the provider if neededjkI
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // Get the current user id from ItemStoreProvider
    final itemStore = Provider.of<ItemStoreProvider>(context);
    final String userId = itemStore.renter.id; // <-- Set dynamically

    // Replace unreadMessages with actual unread count from itemStore
    // itemStore.refreshMessages();
    // Group unread messages by sender (participants[0])
    final Set<String> unreadSenders = {};
    for (var msg in itemStore.messages) {
      if (msg.participants[1] == userId && !(msg.status == 'read') && !msg.deletedFor.contains(userId)) {
        unreadSenders.add(msg.participants[0]); // Add sender to the set if the message is unread
      }
    }

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Never show back chevron on home page
          toolbarHeight: width * 0.2,
          actions: Provider.of<ItemStoreProvider>(context, listen: false).loggedIn
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 16.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 30),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => InboxPage(currentUserId: userId),
                              ),
                            );
                          },
                        ),
                        if (unreadSenders.isNotEmpty)
                          Positioned(
                            right: 4,
                            top: 4,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 20,
                                minHeight: 20,
                              ),
                              child: Center(
                                child: Text(
                                  unreadSenders.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ]
              : [],
          title: const Text(
            'VELAA',
            style: TextStyle(
              fontFamily: 'Lovelo',
              fontWeight: FontWeight.normal,
              fontSize: 32,
              color: Colors.black,
              letterSpacing: 3.0,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Version number at the top

              CarouselSlider(
                carouselController: buttonCarouselSliderController,
                options: CarouselOptions(
                    viewportFraction: 1,
                    onPageChanged: (index, reason) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    height: height * 0.2,
                    autoPlay: true),
                items: items.map((i) {
                  return Builder(
                    builder: (BuildContext context) {
                      return const OfferWidget();
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: width * 0.02),
              // Display dot indicators for carousel

              Center(
                child: DotsIndicator(
                  dotsCount: items.length,
                  position: currentIndex,
                  decorator: const DotsDecorator(
                    colors: [Colors.grey, Colors.grey],
                    activeColor: Colors.black,
                    // colors: [Colors.grey[300], Colors.grey[600], Colors.grey[900]], // Inactive dot colors
                  ),
                ),
              ),

              // // Now display the first home page widget, for now a simple icon button
              // SizedBox(height: width * 0.02),
              // const Padding(
              //   padding: EdgeInsets.only(left: 12.0),
              //   child: StyledHeading(
              //     'ALL ITEMS',
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () {
              //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const ItemResults('occasion', 'party'))));
              //   },
              //   child: const AllItemsHomeWidget()),

              SizedBox(height: width * 0.02),
              const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: StyledHeading(
                  'TO RENT',
                ),
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            (const ItemResults('bookingType', 'rental'))));
                  },
                  child: const RentalHomeWidget()),
              SizedBox(height: width * 0.02),
              const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: StyledHeading(
                  'NEW ARRIVALS',
                ),
              ),
              // const NewArrivalsHomeWidget(),
              SizedBox(height: width * 0.02),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            (const ItemResults('dateAdded', '01-01-2020'))));
                  },
                  child: const NewArrivalsCarousel()),

              SizedBox(height: width * 0.05),
              const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: StyledHeading(
                  'TO BUY',
                ),
              ),
              GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            (const ItemResults('bookingType', 'buy'))));
                  },
                  child: const ToBuyHomeWidget()),

              SizedBox(height: width * 0.02),

              // const Padding(
              //   padding: EdgeInsets.only(left: 12.0),
              //   child: StyledHeading(
              //     'BOOK A FITTING ',
              //   ),
              // ),
              // GestureDetector(
              //   onTap: () {
              //     // Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const Fitting2())));
              //     bool loggedIn = Provider.of<ItemStoreProvider>(context, listen: false).loggedIn;
              //     (loggedIn) ? Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const ItemResults('fitting','dummy'))))
              //       : showAlertDialog(context);
              //   },
              //   child: const FittingHomeWidget()),

              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.only(left: 12.0),
                child: StyledHeading('HELP CENTRE'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: height * 0.10,
                child: ListView(
                  // This next line does the trick.
                  scrollDirection: Axis.horizontal,
                  children: <Widget>[
                    const SizedBox(width: 4),
                    // GestureDetector(
                    //   onTap: () {
                    //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const HygienePolicy())));
                    //   },
                    //   child: const HomePageBottomCard('Our Hygiene Policy')),
                    GestureDetector(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const FAQs())));
                          Navigator.pushNamed(context, '/faqs');
                        },
                        child: const HomePageBottomCard('General FAQs')),
                    GestureDetector(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const WhatIs())));
                          Navigator.pushNamed(context, '/whatIs');
                        },
                        child: const HomePageBottomCard('Who Are We?')),
                    GestureDetector(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const HowItWorks())));
                          Navigator.pushNamed(context, '/howItWorks');
                        },
                        child: const HomePageBottomCard('How It Works')),
                    GestureDetector(
                        onTap: () {
                          // Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const SizingGuide())));
                          Navigator.pushNamed(context, '/sizingGuide');
                        },
                        child: const HomePageBottomCard('Sizing Guide')),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ));
  }

  showAlertDialog(BuildContext context) {
    // Create button
    double width = MediaQuery.of(context).size.width;

    Widget okButton = ElevatedButton(
      style: OutlinedButton.styleFrom(
        textStyle: const TextStyle(color: Colors.white),
        foregroundColor: Colors.white, //change background color of button
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0.0),
        ),
        side: const BorderSide(width: 1.0, color: Colors.black),
      ),
      onPressed: () {
        // Navigator.of(context).pop();
        // Navigator.of(context).popUntil((route) => route.isFirst);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => (const GoogleSignInScreen())));
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
                StyledHeading("to book a fitting"),
              ],
            )
          ],
        ),
      ),
      actions: [
        okButton,
      ],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(0.0)),
      ),
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}

// In your theme.dart or directly in main.dart
final ThemeData primaryTheme = ThemeData(
  fontFamily: 'Inter', // or your chosen font family
  // ...other theme settings...
);
