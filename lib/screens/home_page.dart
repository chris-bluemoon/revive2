import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
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

  final _pages = [
    const Home(),
    const Browse(),
    // const AddItemsScreen(),
    const CreateItemTemp(),
    // const CreateItem(item: null),
    const Profile(canGoBack: false,),
  ];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedLabelStyle:
            TextStyle(fontSize: width * 0.025, color: Colors.black),
        selectedLabelStyle:
            TextStyle(fontSize: width * 0.025, color: Colors.grey),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Icon(Icons.home_outlined, size: width * 0.05),
            ),
            label: 'HOME',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Icon(Icons.menu_book_outlined, size: width * 0.05),
            ),
            label: 'BROWSE',
          ),
          // BottomNavigationBarItem(
          //   icon: Padding(
          //     padding: const EdgeInsets.only(bottom: 8.0),
          //     child: Icon(Icons.add_box_outlined, size: width * 0.05),
          //   ),
          //   label: 'ADD',
          // ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Icon(Icons.add_box_outlined, size: width * 0.05),
            ),
            label: 'LIST',
          ),
          BottomNavigationBarItem(
              icon: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Icon(Icons.account_circle_outlined, size: width * 0.05),
              ),
              label: 'PROFILE'),
        ],
        // selectedLabelStyle: TextStyle(color: Colors.blue,fontSize: 14),
        currentIndex: _pageIndex,
        onTap: (int index) {
          setState(
            () {
              // getCurrentUser();
              _pageIndex = index;
              bool loggedIn = Provider.of<ItemStoreProvider>(context, listen: false).loggedIn;
              log('Page Index: $_pageIndex, Logged In: $loggedIn');
              if (!loggedIn && index == 2) {
                Navigator.of(context).pushNamedAndRemoveUntil('/sign_in', (Route<dynamic> route) => false);
                _pageIndex = 0; // Reset to Home page
              }
              //
              // if (index == 3 && loggedIn == false) {
              //   // Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const Profile())));
              //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const GoogleSignInScreen())));
              //   _pageIndex = 0;
              // }
            },
          );
        },
      ),
    );
  }
}
