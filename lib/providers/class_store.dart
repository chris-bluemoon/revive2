import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/fitting_renter.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/models/message.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/models/review.dart';
import 'package:revivals/providers/create_item_provider.dart';
import 'package:revivals/providers/set_price_provider.dart';
import 'package:revivals/services/firestore_service.dart';
import 'package:revivals/shared/secure_repo.dart';

class ItemStoreProvider extends ChangeNotifier {

  /// Award badges based on profile, items, and reviews (not review dialog badges)
  void checkAndAwardBadges(Renter renter) {
    // Trust and Responsibility
    if (!(renter.badgeTitles.containsKey('Verified Identity')) && renter.verified == 'verified') {
      renter.badgeTitles['Verified Identity'] = 1;
    }
    if (!(renter.badgeTitles.containsKey('Highly Rated User - Test'))) {
      final myAvgReviews = renter.avgReview;
      if (myAvgReviews > 4) {
        log('Awarding Highly Rated User badge to ${renter.name}');
        renter.badgeTitles['Top Rated Lender'] = 1;
      }
    }

    // Experience & Activity
    if (!(renter.badgeTitles.containsKey('Super Lender'))) {
      final myItems = _items.where((item) => item.owner == renter.id).length;
      if (myItems >= 10) {
        renter.badgeTitles['Super Lender'] = 1;
      }
    }
    if (!(renter.badgeTitles.containsKey('Super Renter'))) {
      final myRentals = _itemRenters.where((ir) => ir.renterId == renter.id && ir.transactionType == 'rental').length;
      if (myRentals >= 10) {
        renter.badgeTitles['Super Renter'] = 1;
      }
    }
    if (!(renter.badgeTitles.containsKey('Seasoned User'))) {
      final creation = renter.creationDate;
      if (DateTime.now().difference(creation).inDays >= 0) {
        renter.badgeTitles['Seasoned User'] = 1;
      }
    }
    if (!(renter.badgeTitles.containsKey('First Rental Complete'))) {
      final myRentals = _itemRenters.where((ir) => ir.renterId == renter.id && ir.transactionType == 'rental').length;
      if (myRentals >= 1) {
        renter.badgeTitles['First Rental Complete'] = 1;
      }
    }
    if (!(renter.badgeTitles.containsKey('10 Rentals'))) {
      final myRentals = _itemRenters.where((ir) => ir.renterId == renter.id && ir.transactionType == 'rental').length;
      if (myRentals >= 10) {
        renter.badgeTitles['10 Rentals'] = 1;
      }
    }
    if (!(renter.badgeTitles.containsKey('50 Rentals'))) {
      final myRentals = _itemRenters.where((ir) => ir.renterId == renter.id && ir.transactionType == 'rental').length;
      if (myRentals >= 50) {
        renter.badgeTitles['50 Rentals'] = 1;
      }
    }
    if (!(renter.badgeTitles.containsKey('100 Rentals'))) {
      final myRentals = _itemRenters.where((ir) => ir.renterId == renter.id && ir.transactionType == 'rental').length;
      if (myRentals >= 100) {
        renter.badgeTitles['100 Rentals'] = 1;
      }
    }

    // Community & Engagement
    if (!(renter.badgeTitles.containsKey('Fast Responder'))) {
      if (renter.avgResponseTime != null && renter.avgResponseTime! < const Duration(hours: 1)) {
        renter.badgeTitles['Fast Responder'] = 1;
      }
    }
    if (!(renter.badgeTitles.containsKey('Helpful Rater'))) {
      final myReviews = _reviews.where((r) => r.reviewerId == renter.id).length;
      if (myReviews >= 10) {
        renter.badgeTitles['Helpful Rater'] = 1;
      }
    }
    if (!(renter.badgeTitles.containsKey('Profile Complete'))) {
      if (renter.bio.isNotEmpty && renter.imagePath.isNotEmpty && renter.size > 0) {
        renter.badgeTitles['Profile Complete'] = 1;
      }
    }

    // Style & Category
    if (!(renter.badgeTitles.containsKey('Style Icon'))) {
      final compliments = renter.compliments;
      if (compliments >= 10) {
        renter.badgeTitles['Style Icon'] = 1;
      }
    }

    // Exclusive/Seasonal
    if (!(renter.badgeTitles.containsKey('Early Adopter'))) {
      final creation = renter.creationDate;
      if (creation.isBefore(DateTime(2026, 1, 1))) {
        renter.badgeTitles['Early Adopter'] = 1;
      }
    }
    if (!(renter.badgeTitles.containsKey('Sustainability Star'))) {
      if (renter.hasEcoInitiative == true) {
        renter.badgeTitles['Sustainability Star'] = 1;
      }
    }

    // --- Award badges when score is over 50 ---
    renter.badgeTitles.forEach((title, score) {
      if (score > 50 && !renter.badgeTitles.containsKey(title)) {
        renter.badgeTitles[title] = score;
      }
    });
    saveRenterNoEmail(renter);
  }
  final double width =
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width;

  final List<Ledger> _ledgers = []; // Store all ledgers for the current user
  final List<Message> _messages = [];
  final List<ItemImage> _images = [];
  final List<Item> _items = [];
  final List<Item> _favourites = [];
  final List<String> _fittings = [];
  // final List<Item> _settings = [];
  final List<Renter> _renters = [];
  final List<ItemRenter> _itemRenters = [];
  final List<FittingRenter> _fittingRenters = [];
  final List<Review> _reviews = [];
  Map<String, bool> _sizesFilter = {
    '4': false,
    '6': false,
    '8': false,
    '10': false,
  };
  Map<Color, bool> _coloursFilter = {
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
  };
  String? _cityFilter;
  RangeValues _rangeValuesFilter = const RangeValues(0, 10000);

  // final List<bool> _sizesFilter = [true, true, false, false];
  // final List<bool> _sizesFilter = [true, true, false, false];
  // TODO: Revert back to late initialization if get errors with this
  // late final _user;
  Renter _user = Renter(
    id: '0000',
    email: 'dummy',
    name: 'no_user',
    type: 'USER',
    size: 0,
    address: '',
    countryCode: '',
    phoneNum: '',
    favourites: [],
    verified: 'not started',
    imagePath: '',
    creationDate: DateTime.now(),
    location: '', // <-- Add this line
    bio: '',
    followers: [],
    following: [],
    avgReview: 0.0,
    lastLogin: DateTime.now(),
    vacations: [],
    status: 'not active',
    saved: [],
    badgeTitles: {}, // <-- Added status field, changed to Map<String, int>
  );
  bool _loggedIn = false;
  // String _region = 'BANGKOK';

  get ledgers => _ledgers;
  get messages => _messages;
  List<ItemImage> get images => _images;
  get items => _items;
  get favourites => _favourites;
  get fittings => _fittings;
  get renters => _renters;
  get itemRenters => _itemRenters;
  get fittingRenters => _fittingRenters;
  get renter => _user;
  get loggedIn => _loggedIn;
  get sizesFilter => _sizesFilter;
  get coloursFilter => _coloursFilter;
  get cityFilter => _cityFilter;
  get rangeValuesFilter => _rangeValuesFilter;
  get reviews => _reviews;

  get currentRenter => null;

  void sizesFilterSetter(sizeF) {
    _sizesFilter = sizeF;
  }

  void coloursFilterSetter(colourF) {
    _coloursFilter = colourF;
  }

  void cityFilterSetter(String? city) {
    _cityFilter = city;
  }

  void rangeValuesFilterSetter(rangeValuesF) {
    _rangeValuesFilter = rangeValuesF;
  }

  void resetFilters() {
    sizesFilter.updateAll((name, value) => value = false);
    rangeValuesFilterSetter(const RangeValues(0, 10000));
    coloursFilter.updateAll((name, value) => value = false);
    _cityFilter = null;
  }

  // assign the user
  void assignUser(Renter user) async {
    log('=== ASSIGNING USER ===');
    log('Assigning user: ${user.name} with email: ${user.email} and ID: ${user.id}');
    log('Previous user was: ${_user.name} (${_user.id})');
    _user = user;
    log('User assigned successfully. Current user is now: ${_user.name} (${_user.id})');
    notifyListeners();
    log('=== END ASSIGNING USER ===');
  }

  // Fetch and set all ledgers for the current user
  Future<void> fetchLedgersOnce() async {
    final userId = _user.id;
    if (_ledgers.isNotEmpty) {
      log('Ledgers already fetched for user: $userId, count: ${_ledgers.length}');
      return; // Return early if ledgers are already fetched
    }
    final snapshot = await FirestoreService.getLedgersOnce();
    log('Fetching ledgers for user: $userId, count: ${snapshot.docs.length}');
    for (var doc in snapshot.docs) {
      final ledger = doc.data();
      if (ledger.owner == userId) {
        _ledgers.add(ledger);
        log('Added ledger: ${ledger.id} with amount: ${ledger.amount} and balance: ${ledger.balance}');
      }
    }
    notifyListeners();
  }

  // Returns the latest balance for the current user
  int getBalance() {
    if (_ledgers.isEmpty) return 0;
    _ledgers.sort((a, b) => b.date.compareTo(a.date));
    return _ledgers.first.balance;
  }

  // Add a ledger for the current user
  Future<void> addLedger(Ledger ledger) async {
    _ledgers.add(ledger);
    log('Adding ledger: ${ledger.id} with amount: ${ledger.amount} and balance: ${ledger.balance}');
    await FirestoreService.addLedger(ledger);
    notifyListeners();
  }

  void addItem(Item item) async {
    _items.add(item);
    await FirestoreService.addItem(item);
    notifyListeners();
  }

  Future<void> addRenter(Renter renter) async {
    log('=== ADDING NEW RENTER ===');
    log('Adding new renter: ${renter.name} with email: ${renter.email} and ID: ${renter.id}');
    log('Current user before adding: ${_user.name} (${_user.id})');
    if (renter.status != 'deleted') {
      _renters.add(renter);
      log('Added to renters list, new count: ${_renters.length}');
      await FirestoreService.addRenter(renter);
      log('Saved to Firestore');
      // Directly assign the new user instead of searching through the list
      assignUser(renter);
      log('Assigned user');
      setLoggedIn(true);
      log('Set logged in to true');
      notifyListeners();
      log('Notified listeners');
      log('Successfully added and assigned new renter: ${renter.name}');
      log('Current user after adding: ${_user.name} (${_user.id})');
    }
    log('=== END ADDING NEW RENTER ===');
  }

  void saveRenterLocal(Renter updated) {
    _user = updated;
    notifyListeners();
    // No Firebase or remote update, just local state
  }

  Future<void> saveRenter(Renter renter) async {
    log('Updating renter: ${renter.name} with email: ${renter.type}');
    await FirestoreService.updateRenter(renter, refreshFcmToken: false); // Default to no FCM refresh for performance
    // _renters[0].aditem = renter.aditem;
    // _user.aditem = renter.aditem;
    // fetchRentersOnce(); // Refddresh the renters list
    notifyListeners();
    return;
  }

  void addRenterAppOnly(Renter renter) {
    _renters.add(renter);
  }

  // add itemRenter
  Future<void> addItemRenter(ItemRenter itemRenter) async {
    _itemRenters.add(itemRenter);
    await FirestoreService.addItemRenter(itemRenter);
    // Award "First Rental Complete" badge if this is the user's first rental
    if (itemRenter.transactionType == 'rental') {
      final userRentals = _itemRenters.where((ir) => ir.renterId == itemRenter.renterId && ir.transactionType == 'rental').toList();
      if (userRentals.length == 1) {
        // First rental for this user
        final renterIndex = _renters.indexWhere((r) => r.id == itemRenter.renterId);
        if (renterIndex != -1) {
          final renter = _renters[renterIndex];
          if (!renter.badgeTitles.containsKey('First Rental Complete')) {
            renter.badgeTitles['First Rental Complete'] = 1;
            await saveRenterNoEmail(renter);
          }
        }
      }
    }
    notifyListeners();
  }

  // add fittingRenter
  void addFittingRenter(FittingRenter fittingRenter) async {
    _fittingRenters.add(fittingRenter);
    await FirestoreService.addFittingRenter(fittingRenter);
    notifyListeners();
  }

  Future<void> fetchItemsOnce() async {
    log('CALLING FETCHITEMSONCE');
    if (items.length == 0) {
      // Temporary setting of email password once
      MyStore.writeToStore('fkwx gnet sbwl pgjb');
      final snapshot = await FirestoreService.getItemsOnce();
      for (var doc in snapshot.docs) {
        _items.add(doc.data());
      }
      log('ENDING FETCHITEMSONCE');
      // fetchRentersOnce();
      fetchImages(); // FIXED AS fetchRenters now done here, KEEP AN EYE ON THIS, ARE WE FETCHING BEFORE USERS VERIFY IMAGE IS SET
      populateFavourites();
      // populateFittings();
      // fetchImages();
      notifyListeners();
    }
  }

  void populateFavourites() {
    List favs = _user.favourites;
    _favourites.clear();
    for (Item d in _items) {
      if (favs.contains(d.id)) {
        _favourites.add(d);
      }
    }
  }

  void addFavourite(item) {
    _favourites.add(item);
    notifyListeners();
  }

  void removeFavourite(item) {
    _favourites.remove(item);
    notifyListeners();
  }

  // void clearFittings() {
  //   fittings.clear();
  //   renter.fittings = [];
  //   saveRenter(renter);
  //   notifyListeners();
  // }

  Future<dynamic> setCurrentUser() async {
    log('=== SET CURRENT USER START ===');
    User? user = FirebaseAuth.instance.currentUser;
    log('Firebase Auth user: ${user?.email}');
    log('Current renters count: ${renters.length}');
    
    if (user?.email == null) {
      log('❌ No Firebase user found, cannot set current user');
      log('=== SET CURRENT USER END (NO FIREBASE USER) ===');
      return null;
    }
    
    // Don't fetch renters here to avoid recursion - they should already be loaded
    if (renters.isEmpty) {
      log('⚠️  WARNING: Renters list is empty when trying to set current user');
      log('=== SET CURRENT USER END (NO RENTERS LOADED) ===');
      return null;
    }
    
    bool userFound = false;
    for (Renter r in renters) {
      log('🔍 Checking renter: "${r.email}" vs Firebase user: "${user?.email}"');
      log('🔍 Renter status: "${r.status}" (trimmed: "${r.status.trim()}", length: ${r.status.length})');
      
      if (r.email == user?.email) {
        log('📧 EMAIL MATCH FOUND: ${r.name} with email: ${r.email}, status: "${r.status}"');
        
        // Check if the account is deleted - if so, reject login
        if (r.status == 'deleted' || r.status.toLowerCase().trim() == 'deleted') {
          log('🚫 DELETED ACCOUNT DETECTED: ${r.email} with status: "${r.status}"');
          log('Signing out Firebase user...');
          await FirebaseAuth.instance.signOut();
          log('✅ Firebase user signed out');
          log('=== SET CURRENT USER END (DELETED USER REJECTED) ===');
          throw Exception('Account has been deleted');
        }
        
        log('✅ ACCEPTING USER: ${r.name} with status: "${r.status}"');
        // Update lastLogin
        r.lastLogin = DateTime.now();
        assignUser(r);
        await FirestoreService.updateRenter(r, refreshFcmToken: false); // Save to Firestore, just for lastLogin - no need for FCM token refresh
        setLoggedIn(true);
        listenToMessages(r.id); // Start listening to messages for this user
        userFound = true;
        log('✅ User successfully set and logged in');
        break;
      }
    }
    
    if (!userFound) {
      log('❌ User not found in renters list. Firebase email: ${user?.email}');
      log('Available renters:');
      for (int i = 0; i < renters.length; i++) {
        log('  Renter $i: ${renters[i].email} (status: ${renters[i].status})');
      }
    }
    
    log('Final renters count: ${renters.length}');
    log('=== SET CURRENT USER END ===');
    return user;
  }

  void setLoggedIn(bool loggedIn) {
    if (loggedIn == false) {
      // When logging out, reset all provider state to ensure clean slate
      resetAllProviderState();
    } else {
      _loggedIn = loggedIn;
      notifyListeners();
    } 
  }

  Future<void> fetchItemRentersOnce() async {
    if (itemRenters.length == 0) {
      final snapshot = await FirestoreService.getItemRentersOnce();
      for (var doc in snapshot.docs) {
        _itemRenters.add(doc.data());
        log('Fetched item renter: ${doc.data()}');
      }
      notifyListeners();
    }
  }
  Future<void> fetchItemRentersAgain() async {
      _itemRenters.clear();
      final snapshot = await FirestoreService.getItemRentersOnce();
      for (var doc in snapshot.docs) {
        _itemRenters.add(doc.data());
        log('Fetched item again: ${doc.data()}');
      }
      notifyListeners();
  }

  

  void fetchFittingRentersOnce() async {
    if (fittingRenters.length == 0) {
      final snapshot = await FirestoreService.getFittingRentersOnce();
      for (var doc in snapshot.docs) {
        _fittingRenters.add(doc.data());
      }
      notifyListeners();
    }
  }

  void deleteLedgers() async {
    await FirestoreService.deleteLedgers();
    _ledgers.clear();
  }

  void deleteItems() async {
    await FirestoreService.deleteItems();
    _items.clear();
  }

  void deleteItemRenters() async {
    await FirestoreService.deleteItemRenters();
    _itemRenters.clear();
  }

  void deleteFittingRenters() async {
    await FirestoreService.deleteFittingRenters();
    _fittingRenters.clear();
  }

  void deleteMessagesByParticipant(String userId) async {
    // messages.removeWhere((msg) => msg.participants[0] == userId);
    await FirestoreService().deleteMessagesBySenderId(userId);
    notifyListeners();
  }

  // Add this function to your ItemStoreProvider class
  void deleteMessagesByParticipants(String senderId, String receiverId) {
    messages.removeWhere((msg) =>
        (msg.participant[0] == senderId && msg.participant[1] == receiverId));
    log('Deleted messages between $senderId and $receiverId, remaining: ${messages.length}');
    notifyListeners();
  }

  Future<void> fetchImages() async {
    log('Item count is: ${items.length}');
    for (Item i in items) {
      for (String j in i.imageId) {
        log(j);
        final ref = FirebaseStorage.instance.ref().child(j);
        String url = '';
        try {
          url = await ref.getDownloadURL();
          ItemImage newImage = ItemImage(id: ref.fullPath, imageId: url);
          _images.add(newImage);
          log('Item image added (for url $url), size now ${_images.length}');
        } catch (e) {
          log('Item load error: ${e.toString()} for url: $url');
        }
      }
    }
    for (Renter r in renters) {
      String verifyImagePath = r.imagePath;
      if (verifyImagePath != '') {
        final refVerifyImage =
            FirebaseStorage.instance.ref().child(verifyImagePath);
        String verifyUrl = '';
        try {
          verifyUrl = await refVerifyImage.getDownloadURL();
          ItemImage newImage =
              ItemImage(id: refVerifyImage.fullPath, imageId: verifyUrl);
          _images.add(newImage);
          log('VerifyImage load success');
        } catch (e) {
          log('Item load error: ${e.toString()} for url: $verifyUrl');
        }
      } else {
        log('No image to load for user, not verified?');
      }
    }
    notifyListeners();
  }

  void refreshRenters() async {
    final snapshot = await FirestoreService.getRentersOnce();
    _renters.clear();
    for (var doc in snapshot.docs) {
      // Create a copy of the renter with the email obfuscated
      final renter = doc.data().copyWith(
        email: 'hidden',
        status: doc.data().status, // Keep the status as is
      );
      _renters.add(renter);
      log('Added renter: [email hidden] (status: ${renter.status})');
    }
    notifyListeners();
  }

  Future<bool> fetchRentersOnce() async {
    log('=== FETCH RENTERS ONCE START ===');
    log('Current renters count: ${renters.length}');
    log('Current user: ${_user.name} (${_user.id})');
    
    if (renters.length == 0) {
      log('Fetching renters from Firestore...');
      final snapshot = await FirestoreService.getRentersOnce();
      log('Fetched ${snapshot.docs.length} renters from Firestore');
      
      for (var doc in snapshot.docs) {
        _renters.add(doc.data());
        log('Added renter: ${doc.data().email} (status: ${doc.data().status})');
      }
      
      // Only call setCurrentUser if no user is currently assigned or if the current user is the default placeholder
      if (_user.id == '0000' || _user.name == 'no_user') {
        log('No current user set, attempting auto-login via setCurrentUser()');
        try {
          await setCurrentUser();
          log('✅ Auto-login via setCurrentUser() completed successfully');
        } catch (e) {
          log('💥 Exception caught during auto-login: $e');
          if (e.toString().contains('Account has been deleted')) {
            log('❌ DELETED USER CAUGHT BY AUTO-LOGIN: resetting all provider state');
            // Reset all provider state to ensure clean slate for deleted user
            resetAllProviderState();
          } else {
            log('❌ Other error in automatic setCurrentUser: $e');
            // For other errors, we can choose to ignore or handle differently
          }
        }
      } else {
        log('Current user already set: ${_user.name} (${_user.id}), skipping setCurrentUser()');
      }
    } else {
      log('Renters already loaded (${renters.length} renters), skipping fetch');
    }
    
    log('Final state - renters count: ${renters.length}, user: ${_user.name} (${_user.id})');
    
    // Debug dump all renters data
    // debugDumpAllRenters();
    
    log('=== FETCH RENTERS ONCE END ===');
    notifyListeners();
    // refreshRenters();
    return true;
  }

  void saveItemRenter(ItemRenter itemRenter) async {
    await FirestoreService.updateItemRenter(itemRenter);
    notifyListeners();
    return;
  }

  void saveItem(Item item) async {
    log('Saving item: ${item.name} with status: ${item.status}');
    await FirestoreService.updateItem(item);
    return;
  }

  void updateItem(Item updatedItem) async {
    // Find the index of the item to update
    final index = _items.indexWhere((item) => item.id == updatedItem.id);
    if (index != -1) {
      _items[index] = updatedItem;
      await FirestoreService.updateItem(updatedItem);
      notifyListeners();
    }
  }

  Future<void> updateRenterProfile({
    String? bio,
    String? location,
    String? imagePath,
    String? name,
  }) async {
    // Update local state immediately for responsive UI
    if (bio != null) {
      _user.bio = bio;
    }
    if (location != null) {
      _user.location = location;
    }
    if (imagePath != null) {
      _user.imagePath = imagePath;
    }
    if (name != null) {
      _user.name = name;
    }
    
    // Update the user in the local renters list immediately
    final renterIndex = _renters.indexWhere((r) => r.id == _user.id);
    if (renterIndex != -1) {
      _renters[renterIndex] = _user;
    }
    
    // Notify listeners immediately for responsive UI
    notifyListeners();
    
    // Then update the database in the background
    await saveRenterOptimized(_user);
  }

  // Optimized version that doesn't refresh FCM token
  Future<void> saveRenterOptimized(Renter renter) async {
    log('Updating renter profile: ${renter.name}');
    await FirestoreService.updateRenterProfile(renter);
    return;
  }

  // Add this method to your ItemStoreProvider class:
  void addReview(Review review) async {
    _reviews.add(review);
    await FirestoreService.addReview(review); // Persist to Firestore

    // Calculate average review for the reviewed user
    final reviewedUserId =
        review.reviewedUserId; // Make sure your Review model has this field
    final userReviews =
        _reviews.where((r) => r.reviewedUserId == reviewedUserId).toList();

    if (userReviews.isNotEmpty) {
      log('Calculating average review for user: $reviewedUserId');
      final avg = userReviews.map((r) => r.rating).reduce((a, b) => a + b) /
          userReviews.length;

      // Find the renter and update avgReview
      final renterIndex = _renters.indexWhere((r) => r.id == reviewedUserId);
      if (renterIndex != -1) {
        log('Updating reviewed user ${_renters[renterIndex].name} with new average: $avg');
        _renters[renterIndex].avgReview = avg;
        await FirestoreService.updateRenter(_renters[renterIndex], refreshFcmToken: false); // Just updating average - no need for FCM token refresh
      }
    }

    notifyListeners();
  }

  // Optionally, add a method to check if a review exists for an itemRenter
  // bool hasReviewForItemRenter(String itemRenterId) {
  //   return _reviews.any((review) => review.itemRenterId == itemRenterId);
  // }

  // void fetchRentersOnce() async {
  //   if (renters.length == 0) {
  //     final snapshot = await FirestoreService.getRentersOnce();
  //     for (var doc in snapshot.docs) {
  //       _renters.add(doc.data());
  //     }
  //   }
  //   setCurrentUser();
  //   notifyListeners();
  // }
  void fetchReviewsOnce() async {
    log('Fetching reviews, current count: ${_reviews.length}');
    if (_reviews.isEmpty) {
      final snapshot = await FirestoreService.getReviewsOnce();
      log('Fetching reviews, count: ${snapshot.docs.length}');
      for (var doc in snapshot.docs) {
        _reviews.add(doc.data());
      }
      log('Fetched reviews: ${_reviews.length}');
      notifyListeners();
    }
  }

  Future<void> fetchMessagesOnce() async {
    if (_messages.isEmpty) {
      final snapshot = await FirestoreService.getMessagesOnce();
      for (var doc in snapshot.docs) {
        _messages.add(doc.data());
      }
      log('Fetched messages: ${_messages.length}');
      notifyListeners();
    }
  }

  // Add a message to the in-memory _messages list and notify listeners
  void addMessage(Message message) {
    _messages.add(message);
    notifyListeners();
  }

  /// Force refresh _messages from Firestore, adding new messages to the existing list.
  Future<void> refreshMessages() async {
    final snapshot = await FirestoreService.getMessagesOnce();
    for (var doc in snapshot.docs) {
      final newMessage = doc.data();
      // Only add if not already present (by unique fields, e.g., time and text)
      final exists = _messages.any((m) =>
          m.time == newMessage.time &&
          m.text == newMessage.text &&
          m.participants.toString() == newMessage.participants.toString());
      if (!exists) {
        _messages.add(newMessage);
      }
    }
    log('%a Refreshed messages: ${_messages.length}');
    notifyListeners();
  }

  void listenToMessages(String userId) {
    log('Started to listen to messages for user: $userId');
    FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: userId)
        .snapshots()
        .listen((snapshot) {
      _messages.clear();
      _messages.addAll(snapshot.docs
          .map((doc) => Message.fromFirestore(doc, null))
          .toList());
      log('Listening to messages for user $userId, count: ${_messages.length}');
      notifyListeners();
    });
  }

  Future<void> deleteUser() async {
    try {
      final userId = renter.id; // or however you store the current user's id

      // Delete user document from Firestore
      log('Deleting from Firestore user with ID: $userId');
      await FirebaseFirestore.instance.collection('renters').doc(userId).delete();
      renters.removeWhere((r) => r.id == userId);

      // Optionally, delete related data (e.g., bookings, items)
      // await FirebaseFirestore.instance.collection('bookings').where('userId', isEqualTo: userId).get().then((snapshot) {
      //   for (var doc in snapshot.docs) {
      //     doc.reference.delete();
      //   }
      // });

      // Clear local user data
          final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.delete();
    }
      setLoggedIn(false);
      notifyListeners();
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

  void deleteItemById(String itemId) async {
  // Find the item in the local list
  final index = _items.indexWhere((item) => item.id == itemId);
  if (index != -1) {
    // Set status to "deleted"
    _items[index].status = "deleted";
    // Update in Firestore
    await FirestoreService.updateItem(_items[index]);
    notifyListeners();
  }
}

  // Fast update for renter status only
  Future<void> updateRenterStatus(String status) async {
    log('Updating renter status to: $status for user: ${_user.email}');
    await FirestoreService.updateRenterStatus(_user.id, status);
    
    // If the status is "deleted", clean up the user from all follow lists
    if (status == 'deleted') {
      log('User being deleted, cleaning up from follow lists');
      await FirestoreService.cleanupDeletedUserFromFollowLists(_user.id);
    }
    
    // Update local user status
    _user = _user.copyWith(status: status);
    notifyListeners();
  }

  /// Reset all provider state - call this when account is deleted or user logs out
  void resetAllProviderState() {
    log('🔄 RESETTING ALL PROVIDER STATE');
    
    // Clear all lists
    _ledgers.clear();
    _messages.clear();
    _images.clear();
    _items.clear();
    _favourites.clear();
    _fittings.clear();
    _renters.clear();
    _itemRenters.clear();
    _fittingRenters.clear();
    _reviews.clear();
    
    // Reset user to default state
    _user = Renter(
      id: '0000',
      email: 'dummy',
      name: 'no_user',
      type: 'USER',
      size: 0,
      countryCode: '',
      address: '',
      phoneNum: '',
      favourites: [],
      verified: 'not started',
      imagePath: '',
      creationDate: DateTime.now(),
      location: '',
      bio: '',
      following: [],
      followers: [],
      vacations: [],
      avgReview: 0.0,
      lastLogin: DateTime.now(),
      status: 'not active',
      saved: [],
      badgeTitles: <String, int>{},
    );
    
    // Reset logged in status
    _loggedIn = false;
    
    // Reset all filters to default state
    _sizesFilter = {
      '4': false,
      '6': false,
      '8': false,
      '10': false,
    };
    _coloursFilter = {
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
    };
    _cityFilter = null;
    _rangeValuesFilter = const RangeValues(0, 10000);
    
    log('✅ Provider state reset complete');
    notifyListeners();
  }

  /// Reset all providers state - call this when account is deleted
  /// This should be called with context to access other providers
  static void resetAllProviders(BuildContext context) {
    log('🔄 RESETTING ALL PROVIDERS');
    
    // Reset the main item store provider
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    itemStore.resetAllProviderState();
    
    // Reset create item provider
    final createItemProvider = Provider.of<CreateItemProvider>(context, listen: false);
    createItemProvider.reset();
    
    // Reset price provider
    final priceProvider = Provider.of<SetPriceProvider>(context, listen: false);
    priceProvider.clearAllFields();
    
    log('✅ All providers reset complete');
  }

  // Debug method to dump all renters data
  // void debugDumpAllRenters() {
  //   log('=== DEBUG: DUMPING ALL RENTERS DATA ===');
  //   log('
  //   log('Searching among ${renters.length} renters...');
  //   bool found = false;
    
  //   for (Renter r in renters) {
  //     if (r.email == email) {
  //       log('✅ FOUND USER: ${r.email}');
  //       log('  ID: ${r.id}');
  //       log('  Name: "${r.name}"');
  //       log('  Status: "${r.status}" (length: ${r.status.length})');
  //       log('  Status bytes: ${r.status.codeUnits}');
  //       log('  Status == "deleted": ${r.status == "deleted"}');
  //       log('  Status.toLowerCase().trim() == "deleted": ${r.status.toLowerCase().trim() == "deleted"}');
  //       found = true;
  //       break;
  //     }
  //   }
    
  //   if (!found) {
  //     log('❌ USER NOT FOUND: $email');
  //     log('Available emails:');
  //     for (Renter r in renters) {
  //       log('  - "${r.email}"');
  //     }
  //   }
    
  //   log('=== END DEBUG CHECK ===');
  // }
}
