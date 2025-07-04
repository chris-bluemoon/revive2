import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
// import 'package:revivals/screens/addItems/addItems.dart';
import 'package:revivals/screens/browse/browse.dart';
import 'package:revivals/screens/create/create_item_temp.dart';
import 'package:revivals/screens/home/home.dart';
import 'package:revivals/screens/profile/profile.dart';

double? screenWidth;
double? screenHeight;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // itemStore.fetchReviewsOnce(); // <-- Add this line
    // Provider.of<ItemStoreProvider>(context, listen: false)
    // .fetchRentersOnce();
    // Provider.of<ItemStoreProvider>(context, listen: false)
    // .fetchImagesOnce();
    // Provider.of<ItemStoreProvider>(context, listen: false).populateFavourites();
    // Provider.of<ItemStoreProvider>(context, listen: false).populateFittings();
    // Provider.of<ItemStoreProvider>(context, listen: false).addAllFavourites();
    // getCurrentUser();
    log('initState Logged in status at home_page.dart: ${Provider.of<ItemStoreProvider>(context, listen: false).loggedIn}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ItemStoreProvider itemStore =
        Provider.of<ItemStoreProvider>(context, listen: false);
    for (var image in itemStore.images) {
      precacheImage(CachedNetworkImageProvider(image.imageId), context);
    }
  }

  int _pageIndex = 0;
  bool _isAnimating = false;

  bool loggedIn = false;

  final pages = [
    const Home(),
    const Browse(),
    // const AddItemsScreen(),
    const CreateItemTemp(),
    // const CreateItem(item: null),
    const Profile(canGoBack: false,),
  ];

  void _onNavBarTap(int index) {
    bool loggedIn = Provider.of<ItemStoreProvider>(context, listen: false).loggedIn;
    log('Page Index: $index, Logged In: $loggedIn');
    
    if (!loggedIn && index == 2) {
      Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (Route<dynamic> route) => false);
      return;
    }

    if (index != _pageIndex && !_isAnimating) {
      _animateToPage(index);
    }
  }

  void _animateToPage(int index) async {
    if (_isAnimating) return;
    
    _isAnimating = true;
    
    // Update the page index - AnimatedSwitcher will handle the transition
    setState(() {
      _pageIndex = index;
    });
    
    // Small delay to prevent rapid tapping
    await Future.delayed(const Duration(milliseconds: 350));
    
    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.03), // 3% of screen height
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
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (Widget child, Animation<double> animation) {
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.1, 0.0),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeInOutQuart,
                )),
                child: child,
              ),
            );
          },
          child: Container(
            key: ValueKey<int>(_pageIndex),
            child: pages[_pageIndex],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          index: _pageIndex,
          height: 70.0,
          items: const <Widget>[
            Icon(Icons.home_rounded, size: 28, color: Colors.white),
            Icon(Icons.search_rounded, size: 28, color: Colors.white),
            Icon(Icons.add_circle_outline_rounded, size: 28, color: Colors.white),
            Icon(Icons.person_rounded, size: 28, color: Colors.white),
          ],
          color: Colors.black,
          buttonBackgroundColor: Colors.black87,
          backgroundColor: Colors.transparent,
          animationCurve: Curves.easeInOutCubic,
          animationDuration: const Duration(milliseconds: 350),
          letIndexChange: (index) => !_isAnimating, // Prevent navigation during animation
          onTap: _onNavBarTap,
        ),
      ),
    );
  }
}
