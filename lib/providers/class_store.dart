import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:revivals/models/fitting_renter.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/models/message.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/models/review.dart';
import 'package:revivals/services/firestore_service.dart';
import 'package:revivals/shared/secure_repo.dart';

class ItemStoreProvider extends ChangeNotifier {
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
  Map<String, bool> _lengthsFilter = {
    'mini': false,
    'midi': false,
    'long': false
  };
  Map<String, bool> _printsFilter = {
    'enthic': false,
    'boho': false,
    'preppy': false,
    'floral': false,
    'abstract': false,
    'stripes': false,
    'dots': false,
    'textured': false,
    'none': false
  };
  Map<String, bool> _sleevesFilter = {
    'sleeveless': false,
    'short sleeve': false,
    '3/4 sleeve': false,
    'long sleeve': false
  };
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
    creationDate: '',
    location: '', // <-- Add this line
    bio: '',
    followers: [],
    following: [],
    avgReview: 0.0,
    lastLogin: DateTime.now(),
    vacations: [],
    status: 'not active', // <-- Added status field
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
  get lengthsFilter => _lengthsFilter;
  get printsFilter => _printsFilter;
  get sleevesFilter => _sleevesFilter;
  get rangeValuesFilter => _rangeValuesFilter;
  get reviews => _reviews;

  get currentRenter => null;

  void sizesFilterSetter(sizeF) {
    _sizesFilter = sizeF;
  }

  void coloursFilterSetter(colourF) {
    _coloursFilter = colourF;
  }

  void lengthsFilterSetter(lengthsF) {
    _lengthsFilter = lengthsF;
  }

  void printsFilterSetter(printsF) {
    _printsFilter = printsF;
  }

  void sleevesFilterSetter(sleevesF) {
    _sleevesFilter = sleevesF;
  }

  void rangeValuesFilterSetter(rangeValuesF) {
    _rangeValuesFilter = rangeValuesF;
  }

  void resetFilters() {
    sizesFilter.updateAll((name, value) => value = false);
    rangeValuesFilterSetter(const RangeValues(0, 10000));
    coloursFilter.updateAll((name, value) => value = false);
    lengthsFilter.updateAll((name, value) => value = false);
    printsFilter.updateAll((name, value) => value = false);
    sleevesFilter.updateAll((name, value) => value = false);
  }

  // assign the user
  void assignUser(Renter user) async {
    // await FirestoreService.addItem(item);
    _user = user;
    notifyListeners();
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

  void addRenter(Renter renter) async {
    if (renter.status != 'deleted') {
      _renters.add(renter);
      await FirestoreService.addRenter(renter);
      setCurrentUser(); // Set the current user to the newly added renter
      setLoggedIn(true);
      notifyListeners();
    }
  }

  void saveRenterLocal(Renter updated) {
    _user = updated;
    notifyListeners();
    // No Firebase or remote update, just local state
  }
  Future<void> saveRenter(Renter renter) async {
    log('Updating renter: ${renter.name} with email: ${renter.type}');
    await FirestoreService.updateRenter(renter);
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
    User? user = FirebaseAuth.instance.currentUser;
    log('Setting current user, then assigning: ${user?.email}');
    log('Renters (assigning) count: ${renters.length}');
    for (Renter r in renters) {
      log('Checking renter: ${r.email} with user email: ${user?.email}');
      if (r.email == user?.email) {
        // Update lastLogin
        log('Checking assgining user: ${r.name} with email: ${r.type}');
        r.lastLogin = DateTime.now();
        assignUser(r);
        await FirestoreService.updateRenter(r); // Save to Firestore, just for lastLogin
        setLoggedIn(true);
        listenToMessages(r.id); // Start listening to messages for this user
      }
    }
    log('Renters (assigning) count: ${renters.length}');
    return user;
    // return asda;
  }

  void setLoggedIn(bool loggedIn) {
    _loggedIn = loggedIn;
    if (loggedIn == false) {
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
        creationDate: '',
        location: '', // <-- Add this line
        bio: '',
        following: [],
        followers: [],
        vacations: [],
        avgReview: 0.0,
        lastLogin: DateTime.now(),
        status: 'not active'
      );
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
      _renters.add(doc.data());
      log('Fetched renter: ${doc.data()}');
    }
    notifyListeners();
  }

  Future<bool> fetchRentersOnce() async {
    if (renters.length == 0) {
      final snapshot = await FirestoreService.getRentersOnce();
      for (var doc in snapshot.docs) {
        _renters.add(doc.data());
        log('Fetched renter: ${doc.data().type}');
      }
      setCurrentUser();
    }
    notifyListeners();
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
  }) async {
    if (bio != null) {
      _user.bio = bio;
    }
    if (location != null) {
      _user.location = location;
    }
    if (imagePath != null) {
      _user.imagePath = imagePath;
    }
    await saveRenter(_user);
    notifyListeners();
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
        await FirestoreService.updateRenter(_renters[renterIndex]);
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
}
