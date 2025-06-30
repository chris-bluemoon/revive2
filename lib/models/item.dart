import 'package:cloud_firestore/cloud_firestore.dart';

class Item {
  Item({
    required this.id,
    required this.owner,
    required this.type,
    required this.bookingType,
    required this.dateAdded,
    required this.name,
    required this.brand,
    required this.colour,
    required this.size,
    required this.rentPriceDaily,
    required this.rentPrice3,
    required this.rentPrice5,
    required this.rentPrice7,
    required this.rentPrice14,
    required this.buyPrice,
    required this.rrp,
    required this.description,
    required this.longDescription,
    required this.imageId,
    required this.status,
    required this.minDays,
    required this.hashtags,
  });

  String id;
  String owner;
  String type;
  String bookingType;
  String dateAdded;
  String name;
  String brand;
  String colour;
  String size;
  int rentPriceDaily;
  int rentPrice3;
  int rentPrice5;
  int rentPrice7;
  int rentPrice14;
  int buyPrice;
  int rrp;
  String description;
  String longDescription;
  List imageId;
  String status;
  int minDays;
  List<String> hashtags;

  Map<String, dynamic> toFirestore() {
    return {
      'owner': owner,
      'type': type,
      'bookingType': bookingType,
      'dateAdded': dateAdded,
      'name': name,
      'brand': brand,
      'colour': colour,
      'size': size,
      'rentPriceDaily': rentPriceDaily,
      'rentPrice3': rentPrice3,
      'rentPrice5': rentPrice5,
      'rentPrice7': rentPrice7,
      'rentPrice14': rentPrice14,
      'buyPrice': buyPrice,
      'rrp': rrp,
      'description': description,
      'longDescription': longDescription,
      'imageId': imageId,
      'status': status,
      'minDays': minDays,
      'hashtags': hashtags,
    };
  }

  factory Item.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    Item item = Item(
      id: snapshot.id,
      owner: data['owner'],
      type: data['type'],
      bookingType: data['bookingType'],
      dateAdded: data['dateAdded'],
      name: data['name'],
      brand: data['brand'],
      colour: data['colour'],
      size: data['size'],
      rentPriceDaily: data['rentPriceDaily'],
      rentPrice3: data['rentPrice3'] ?? 0,
      rentPrice5: data['rentPrice5'] ?? 0,
      rentPrice7: data['rentPrice7'] ?? 0,
      rentPrice14: data['rentPrice14'] ?? 0,
      buyPrice: data['buyPrice'],
      rrp: data['rrp'],
      description: data['description'],
      longDescription: data['longDescription'],
      imageId: data['imageId'],
      status: data['status'],
      minDays: data['minDays'] ?? 1,
      hashtags: List<String>.from(data['hashtags'] ?? []),
    );
    return item;
  }
}
