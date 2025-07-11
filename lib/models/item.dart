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
    required this.rentPrice1,
    required this.rentPrice2,
    required this.rentPrice3,
    required this.rentPrice4,
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
  int rentPrice1;
  int rentPrice2;
  int rentPrice3;
  int rentPrice4;
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
      'rentPrice1': rentPrice1,
      'rentPrice2': rentPrice2,
      'rentPrice3': rentPrice3,
      'rentPrice4': rentPrice4,
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
      rentPrice1: data['rentPrice1'] ?? 0,
      rentPrice2: data['rentPrice2'] ?? 0,
      rentPrice3: data['rentPrice3'] ?? 0,
      rentPrice4: data['rentPrice4'] ?? 0,
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
