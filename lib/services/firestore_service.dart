import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:revivals/models/fitting_renter.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/models/message.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/models/review.dart';
import 'package:revivals/services/notification_service.dart';

class FirestoreService {
  static final refLedger = FirebaseFirestore.instance
      .collection('ledger')
      .withConverter(
          fromFirestore: Ledger.fromFirestore,
          toFirestore: (Ledger d, _) => d.toFirestore());

  static final refItem = FirebaseFirestore.instance
      .collection('item')
      .withConverter(
          fromFirestore: Item.fromFirestore,
          toFirestore: (Item d, _) => d.toFirestore());

  static final refRenter = FirebaseFirestore.instance
      .collection('renter')
      .withConverter(
          fromFirestore: Renter.fromFirestore,
          toFirestore: (Renter d, _) => d.toFirestore());

  static final refItemRenter = FirebaseFirestore.instance
      .collection('itemRenter')
      .withConverter(
          fromFirestore: ItemRenter.fromFirestore,
          toFirestore: (ItemRenter d, _) => d.toFirestore());

  static final refFittingRenter = FirebaseFirestore.instance
      .collection('fittingRenter')
      .withConverter(
          fromFirestore: FittingRenter.fromFirestore,
          toFirestore: (FittingRenter d, _) => d.toFirestore());

  static final refReview = FirebaseFirestore.instance
      .collection('review') // Collection for reviews
      .withConverter(
          fromFirestore: Review.fromFirestore,
          toFirestore: (Review r, _) => r.toFirestore());

  static final CollectionReference<Message> refMessage = FirebaseFirestore.instance
      .collection('messages')
      .withConverter<Message>(
          fromFirestore: Message.fromFirestore,
          toFirestore: (Message m, _) => m.toFirestore());

  // add a new message
  static Future<void> addLedger(Ledger ledger) async {
    await refLedger.doc(ledger.id).set(ledger);
  }

  // add a new item
  static Future<void> addItem(Item item) async {
    await refItem.doc(item.id).set(item);
  }

  // get item once
  static Future<QuerySnapshot<Item>> getItemsOnce() {
    return refItem.get();
  }

  // add a new renter
  static Future<void> addRenter(Renter renter) async {
    
    if( renter.fcmToken == null || renter.fcmToken == '') renter.fcmToken = await NotificationService.getFCMToken();
    await refRenter.doc(renter.id).set(renter);
    log('Renter (assigning) added in Firestore: ${renter.id} - ${renter.name}');
  }

  // Update renter
  static Future<void> updateRenter(Renter renter, {bool refreshFcmToken = false}) async {
    log('Updating renter in Firestore: ${renter.id} - ${renter.name}');
    
    String? fcmToken;
    if (refreshFcmToken) {
      log('Getting FCM token for ${renter.name}');
      fcmToken = await NotificationService.getFCMToken();
      log('Completed FCM token fetch for ${renter.name}');
    } else {
      // Use existing FCM token from renter object
      fcmToken = renter.fcmToken;
    }
    
    await refRenter.doc(renter.id).update({
      'email': renter.email,
      'name': renter.name,
      'type': renter.type,
      'size': renter.size,
      'address': renter.address,
      'countryCode': renter.countryCode,
      'phoneNum': renter.phoneNum,
      'favourites': renter.favourites,
      'verified': renter.verified,
      'imagePath': renter.imagePath,
      'location': renter.location,
      'bio': renter.bio,
      'followers': renter.followers,
      'following': renter.following,
      'avgReview': renter.avgReview,
      'lastLogin': renter.lastLogin,
      'vacations': renter.vacations.map((v) {
        return {
          'startDate': v['startDate']?.toIso8601String(),
          'endDate': v['endDate']?.toIso8601String(),
        };
      }).toList(),
      'fcmToken' : fcmToken,
      'status': renter.status,
    });
  }

  // Convenience method for updating renter with FCM token refresh
  static Future<void> updateRenterWithFcmRefresh(Renter renter) async {
    return updateRenter(renter, refreshFcmToken: true);
  }

  // Optimized version for profile updates - doesn't refresh FCM token
  static Future<void> updateRenterProfile(Renter renter) async {
    await refRenter.doc(renter.id).update({
      'name': renter.name,
      'imagePath': renter.imagePath,
      'location': renter.location,
      'bio': renter.bio,
      'lastLogin': renter.lastLogin,
    });
  }

  // Fast update for status only - doesn't refresh FCM token
  static Future<void> updateRenterStatus(String renterId, String status) async {
    await refRenter.doc(renterId).update({
      'status': status,
      'lastLogin': DateTime.now(),
    });
  }

  // get renters once
  static Future<QuerySnapshot<Renter>> getRentersOnce() {
    return refRenter.get();
  }

  // add a new renterItem
  static Future<void> addItemRenter(ItemRenter itemRenter) async {
    await refItemRenter.doc(itemRenter.id).set(itemRenter);
  }

  static Future<void> addFittingRenter(FittingRenter fittingRenter) async {
    await refFittingRenter.doc(fittingRenter.id).set(fittingRenter);
  }

  static Future<QuerySnapshot<Ledger>> getLedgersOnce() {
    return refLedger.get();
  }

  static Future<QuerySnapshot<ItemRenter>> getItemRentersOnce() {
    return refItemRenter.get();
  }

  static Future<QuerySnapshot<FittingRenter>> getFittingRentersOnce() {
    return refFittingRenter.get();
  }

  // Update itemrenter
  // Update itemrenter
  static Future<void> updateItemRenter(ItemRenter itemRenter) async {
    await refItemRenter.doc(itemRenter.id).update({
      'status': itemRenter.status,
    });
  }

  static Future<void> updateItem(Item item) async {
    await refItem.doc(item.id).update({
      'owner': item.owner,
      'type': item.type,
      'bookingType': item.bookingType,
      'dateAdded': item.dateAdded,
      'name': item.name,
      'brand': item.brand,
      'colour': item.colour,
      'size': item.size,
      'rentPriceDaily': item.rentPriceDaily,
      'rentPriceWeekly': item.rentPriceWeekly,
      'rentPriceMonthly': item.rentPriceMonthly,
      'buyPrice': item.buyPrice,
      'rrp': item.rrp,
      'description': item.description,
      'longDescription': item.longDescription,
      'imageId': item.imageId,
      'status': item.status,
      'minDays': item.minDays,
      'hashtags': item.hashtags, // <-- Make sure hashtags are included
    });
  }

  static deleteLedgers() {
    FirebaseFirestore.instance.collection('ledger').get().then((snapshot) {
      for (DocumentSnapshot i in snapshot.docs) {
        i.reference.delete();
      }
    });
  }

  static deleteItems() {
    FirebaseFirestore.instance.collection('item').get().then((snapshot) {
      for (DocumentSnapshot i in snapshot.docs) {
        i.reference.delete();
      }
    });
  }

  static deleteItemRenters() {
    FirebaseFirestore.instance.collection('itemRenter').get().then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  static deleteFittingRenters() {
    FirebaseFirestore.instance
        .collection('fittingRenter')
        .get()
        .then((snapshot) {
      for (DocumentSnapshot ds in snapshot.docs) {
        ds.reference.delete();
      }
    });
  }

  // Add a new review (expects a Map or your Review model's toMap())
  static Future<void> addReview(Review review) async {
    // Always use the review's id as the document id
    await refReview.doc(review.id).set(review);
  }

  // Optionally, get reviews for a renter
  static Future<QuerySnapshot<Review>> getReviewsForRenter(String renterId) {
    return refReview.where('renterId', isEqualTo: renterId).get();
  }
  
  // Optionally, get reviews for an itemRenter
  static Future<QuerySnapshot<Review>> getReviewsForItemRenter(String itemRenterId) {
    return refReview.where('itemRenterId', isEqualTo: itemRenterId).get();
  }

  // Get all reviews once
  static Future<QuerySnapshot<Review>> getReviewsOnce() {
    return refReview.get();
  }

  // Optionally, get messages for a renter
  // static Future<QuerySnapshot<Message>> getMessagesForRenter(String renterId) {
  //   return refMessage.where('renterId', isEqualTo: renterId).get();
  // }
  
  // Optionally, get messages for an itemRenter
  // static Future<QuerySnapshot<Message>> getMessagesForItemRenter(String itemRenterId) {
  //   return refMessage.where('itemRenterId', isEqualTo: itemRenterId).get();
  // }

  // Get all messages once
  static Future<QuerySnapshot<Message>> getMessagesOnce() {
    return refMessage.get();
  }

  // Add this function to your ItemStoreProvider class

  Future<void> deleteMessagesBySenderId(String userId) async {
    // Update local messages
    // Update Firestore (assuming 'messages' collection and 'participant' is a List)
    final firestore = FirebaseFirestore.instance;
    final query = await firestore
        .collection('messages')
        .where('participants', arrayContains: userId)
        .get();

    for (var doc in query.docs) {
      final participants = List<String>.from(doc['participants'] ?? []);
      log('Participants for message ${doc.id}: $participants');
      if (participants.isNotEmpty && participants.contains(userId)) {
        final List<dynamic> deletedFor = doc['deletedFor'] ?? [];
        if (!deletedFor.contains(userId)) {
          await firestore.collection('messages').doc(doc.id).update({
            'deletedFor': FieldValue.arrayUnion([userId]),
          });
        }
      }
    }
  }

  static Future<void> deleteItemById(String itemId) async {
    await FirebaseFirestore.instance.collection('item').doc(itemId).delete();
  }

  // Clean up deleted user from all followers and following lists
  static Future<void> cleanupDeletedUserFromFollowLists(String deletedUserId) async {
    log('Cleaning up deleted user $deletedUserId from all follow lists');
    
    try {
      // Get all renters
      final QuerySnapshot<Renter> rentersSnapshot = await refRenter.get();
      
      // Track which renters need to be updated
      List<Future<void>> updateTasks = [];
      
      for (var doc in rentersSnapshot.docs) {
        final renter = doc.data();
        bool needsUpdate = false;
        
        // Check if this renter has the deleted user in their followers list
        List<String> updatedFollowers = List<String>.from(renter.followers);
        if (updatedFollowers.contains(deletedUserId)) {
          updatedFollowers.remove(deletedUserId);
          needsUpdate = true;
          log('Removing $deletedUserId from ${renter.name}\'s followers list');
        }
        
        // Check if this renter has the deleted user in their following list
        List<String> updatedFollowing = List<String>.from(renter.following);
        if (updatedFollowing.contains(deletedUserId)) {
          updatedFollowing.remove(deletedUserId);
          needsUpdate = true;
          log('Removing $deletedUserId from ${renter.name}\'s following list');
        }
        
        // Update the renter if changes were made
        if (needsUpdate) {
          updateTasks.add(
            refRenter.doc(renter.id).update({
              'followers': updatedFollowers,
              'following': updatedFollowing,
            })
          );
        }
      }
      
      // Execute all updates in parallel
      await Future.wait(updateTasks);
      log('Completed cleanup of deleted user $deletedUserId from ${updateTasks.length} renters');
      
    } catch (error) {
      log('Error cleaning up deleted user from follow lists: $error');
      rethrow;
    }
  }
}
