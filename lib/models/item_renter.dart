import 'package:cloud_firestore/cloud_firestore.dart';

class ItemRenter {
  
  ItemRenter({required this.id, 
          required this.renterId, 
          required this.ownerId, 
          required this.itemId,
          required this.transactionType, 
          required this.startDate, 
          required this.endDate, 
          required this.price,
          required this.status,
        }); 

    String id;
    String renterId;
    String ownerId;
    String itemId;
    String transactionType;
    String startDate;
    String endDate;
    int price;
    String status;

  // item to firestore (map)
  Map<String, dynamic> toFirestore() {
    return {
      'renterId': renterId,
      'ownerId': ownerId,
      'itemId': itemId,
      'transactionType': transactionType,
      'startDate': startDate,
      'endDate': endDate,
      'price': price,
      'status': status,
    };
  }

  // ItemRenter from firestore
  factory ItemRenter.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {

    // get data from snapshot
    final data = snapshot.data()!;

    // make character instance
    ItemRenter itemRenter = ItemRenter(
      id: snapshot.id,
      renterId: data['renterId'],
      ownerId: data['ownerId'],
      itemId: data['itemId'],
      transactionType: data['transactionType'],
      startDate: data['startDate'],
      endDate: data['endDate'],
      price: data['price'],
      status: data['status'],
    );

    return itemRenter;
  } 
  
  
}