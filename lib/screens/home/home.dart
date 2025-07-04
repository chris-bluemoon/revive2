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
import 'package:revivals/shared/smooth_page_route.dart';

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
        backgroundColor: Colors.grey[50], // Light background for luxury feel
        appBar: AppBar(
          automaticallyImplyLeading: false, // Never show back chevron on home page
          toolbarHeight: width * 0.25, // Slightly taller AppBar
          backgroundColor: Colors.white,
          elevation: 0, // Remove shadow for clean look
          shadowColor: Colors.transparent,
          actions: Provider.of<ItemStoreProvider>(context, listen: false).loggedIn
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 20.0),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.chat_bubble_outline, color: Colors.black, size: 28),
                            onPressed: () {
                              Navigator.of(context).push(
                                SmoothTransitions.luxury(InboxPage(currentUserId: userId)),
                              );
                            },
                          ),
                        ),
                        if (unreadSenders.isNotEmpty)
                          Positioned(
                            right: 6,
                            top: 6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 18,
                                minHeight: 18,
                              ),
                              child: Center(
                                child: Text(
                                  unreadSenders.length.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
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
          title: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: const Text(
              'VELAA',
              style: TextStyle(
                fontFamily: 'Lovelo',
                fontWeight: FontWeight.normal,
                fontSize: 36,
                color: Colors.black,
                letterSpacing: 4.0,
              ),
            ),
          ),
          centerTitle: true,
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Colors.grey[50]!,
              ],
            ),
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Premium carousel section
                Container(
                  margin: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: width * 0.02),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CarouselSlider(
                      carouselController: buttonCarouselSliderController,
                      options: CarouselOptions(
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              currentIndex = index;
                            });
                          },
                          height: height * 0.22,
                          autoPlay: true,
                          autoPlayInterval: const Duration(seconds: 4),
                          enlargeCenterPage: false),
                      items: items.map((i) {
                        return Builder(
                          builder: (BuildContext context) {
                            return const OfferWidget();
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                
                SizedBox(height: width * 0.015),
                
                // Enhanced dot indicators
                Center(
                  child: DotsIndicator(
                    dotsCount: items.length,
                    position: currentIndex,
                    decorator: DotsDecorator(
                      colors: [Colors.grey[300]!, Colors.grey[300]!],
                      activeColor: Colors.black,
                      size: const Size.square(8.0),
                      activeSize: const Size(20.0, 8.0),
                      activeShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: width * 0.06),
                
                // Section: TO RENT
                _buildSectionHeader('TO RENT', width),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(SmoothTransitions.luxury(
                          const ItemResults('bookingType', 'rental')));
                    },
                    child: const RentalHomeWidget()),
                    
                SizedBox(height: width * 0.06),
                
                // Section: NEW ARRIVALS
                _buildSectionHeader('NEW ARRIVALS', width),
                SizedBox(height: width * 0.02),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(SmoothTransitions.luxury(
                          const ItemResults('dateAdded', '01-01-2020')));
                    },
                    child: const NewArrivalsCarousel()),

                SizedBox(height: width * 0.06),
                
                // Section: TO BUY
                _buildSectionHeader('TO BUY', width),
                GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(SmoothTransitions.luxury(
                          const ItemResults('bookingType', 'buy')));
                    },
                    child: const ToBuyHomeWidget()),

                SizedBox(height: width * 0.08),

                // Section: HELP CENTRE
                _buildSectionHeader('HELP CENTRE', width),
                const SizedBox(height: 15),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: width * 0.03),
                  height: height * 0.12,
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    children: <Widget>[
                      const SizedBox(width: 8),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/faqs');
                          },
                          child: const HomePageBottomCard('General FAQs')),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/whatIs');
                          },
                          child: const HomePageBottomCard('Who Are We?')),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/howItWorks');
                          },
                          child: const HomePageBottomCard('How It Works')),
                      GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/sizingGuide');
                          },
                          child: const HomePageBottomCard('Sizing Guide')),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
                SizedBox(height: width * 0.06),
              ],
            ),
          ),
        ));
  }

  // Helper method for consistent section headers
  Widget _buildSectionHeader(String title, double width) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: width * 0.05),
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  showAlertDialog(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    Widget okButton = Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
        onPressed: () {
          Navigator.of(context).push(SmoothTransitions.luxury(
              const GoogleSignInScreen()));
        },
        child: const Text(
          "SIGN IN",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
      ),
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      contentPadding: const EdgeInsets.all(24),
      title: const Center(
        child: Text(
          "LOGIN REQUIRED",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
            color: Colors.black87,
          ),
        ),
      ),
      content: SizedBox(
        width: width * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 48,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            const Text(
              "Please log in or register to continue",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            okButton,
          ],
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: true,
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
