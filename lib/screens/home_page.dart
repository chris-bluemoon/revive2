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

  bool loggedIn = false;

  final pages = [
    const Home(),
    const Browse(),
    // const AddItemsScreen(),
    const CreateItemTemp(),
    // const CreateItem(item: null),
    const Profile(canGoBack: false,),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        height: 75.0,
        items: const <Widget>[
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home_outlined, size: 24, color: Colors.black),
              SizedBox(height: 2),
              Text('Home', style: TextStyle(fontSize: 10, color: Colors.black)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.menu_book_outlined, size: 24, color: Colors.black),
              SizedBox(height: 2),
              Text('Browse', style: TextStyle(fontSize: 10, color: Colors.black)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add_box_outlined, size: 24, color: Colors.black),
              SizedBox(height: 2),
              Text('List', style: TextStyle(fontSize: 10, color: Colors.black)),
            ],
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.account_circle_outlined, size: 24, color: Colors.black),
              SizedBox(height: 2),
              Text('Profile', style: TextStyle(fontSize: 10, color: Colors.black)),
            ],
          ),
        ],
        color: Colors.grey[100]!,
        buttonBackgroundColor: Colors.white,
        backgroundColor: Colors.white,
        animationCurve: Curves.easeInOutCubic,
        animationDuration: const Duration(milliseconds: 400),
        letIndexChange: (index) => true,
        onTap: (int index) {
          setState(() {
            _pageIndex = index;
            bool loggedIn = Provider.of<ItemStoreProvider>(context, listen: false).loggedIn;
            log('Page Index: $_pageIndex, Logged In: $loggedIn');
            if (!loggedIn && index == 2) {
              Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (Route<dynamic> route) => false);
              _pageIndex = 0; // Reset to Home page
            }
          });
        },
      ),
    );
  }
}
