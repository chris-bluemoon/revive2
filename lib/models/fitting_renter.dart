import 'package:cloud_firestore/cloud_firestore.dart';

class FittingRenter {
  
  FittingRenter({required this.id, 
          required this.renterId, 
          required this.itemArray,
          required this.bookingDate, 
          required this.price,
          required this.status,
        }); 

    String id;
    String renterId;
    List itemArray;
    String bookingDate;
    int price;
    String status;

  // item to firestore (map)
  Map<String, dynamic> toFirestore() {
    return {
      'renterId': renterId,
      'itemArray': itemArray,
      'bookingDate': bookingDate,
      'price': price,
      'status': status,
    };
  }

  // FittingRenter from firestore
  factory FittingRenter.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {

    // get data from snapshot
    final data = snapshot.data()!;

    // make character instance
    FittingRenter fittingRenter = FittingRenter(
      id: snapshot.id,
      renterId: data['renterId'],
      itemArray: data['itemArray'],
      bookingDate: data['bookingDate'],
      price: data['price'],
      status: data['status'],
    );

    return fittingRenter;
  } 
  
  
}
