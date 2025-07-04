import 'package:cloud_firestore/cloud_firestore.dart';

class Renter {
  Renter({
    required this.id,
    required this.email,
    required this.name,
    required this.type,
    required this.size,
    required this.address,
    required this.countryCode,
    required this.phoneNum,
    required this.favourites,
    required this.verified, // String
    required this.imagePath,
    required this.creationDate,
    required this.location,
    required this.bio,
    required this.followers,
    required this.following,
    this.fcmToken = '',
    required this.avgReview,
    required this.lastLogin,
    required this.vacations,
    required this.status,
    required this.saved,
  });

  String id;
  String email;
  String name;
  String type;
  int size;
  String address;
  String countryCode;
  String phoneNum;
  List favourites;
  String verified;
  String imagePath;
  String creationDate;
  String location;
  String bio;
  List<String> followers;
  List<String> following;
  double avgReview;
  DateTime lastLogin;
  String? fcmToken;
  List<Map<String, DateTime>> vacations;
  String status; // <-- Added status field
  List<String> saved;

  Renter copyWith({
    List<Map<String, DateTime>>? vacations,
    String? verified,
    required String status, // <-- Added status field
    // add other fields here if needed
  }) {
    return Renter(
      id: id,
      email: email,
      name: name,
      type: type,
      size: size,
      address: address,
      countryCode: countryCode,
      phoneNum: phoneNum,
      favourites: favourites,
      verified: verified ?? this.verified,
      imagePath: imagePath,
      creationDate: creationDate,
      location: location,
      bio: bio,
      followers: followers,
      following: following,
      avgReview: avgReview,
      lastLogin: lastLogin,
      vacations: vacations ?? this.vacations,
      fcmToken: fcmToken,
      status: status,
      saved: saved,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'name': name,
      'type': type,
      'size': size,
      'address': address,
      'countryCode': countryCode,
      'phoneNum': phoneNum,
      'favourites': favourites,
      'verified': verified,
      'imagePath': imagePath,
      'creationDate': creationDate,
      'location': location,
      'bio': bio,
      'followers': followers,
      'following': following,
      'avgReview': avgReview,
      'lastLogin': lastLogin.toIso8601String(),
      'vacations': vacations
          .map((v) => {
                'startDate': v['startDate']?.toIso8601String(),
                'endDate': v['endDate']?.toIso8601String(),
              })
          .toList(),
      'status': status, // <-- Added status field
      'fcmToken' : fcmToken,
      'saved': saved,
    };
  }

  factory Renter.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    List<Map<String, DateTime>> vacationsList = [];
    if (data['vacations'] != null) {
      vacationsList = (data['vacations'] as List)
          .map((v) => {
                'startDate': DateTime.parse(v['startDate']),
                'endDate': DateTime.parse(v['endDate']),
              })
          .toList();
    }
    Renter renter = Renter(
      id: snapshot.id,
      email: data['email'] ?? '',
      name: data['name'] ?? '',
      type: data['type'] ?? 'USER',
      size: data['size'] ?? 0,
      address: data['address'] ?? '',
      countryCode: data['countryCode'] ?? '',
      phoneNum: data['phoneNum'] ?? '',
      favourites: data['favourites'] ?? [],
      verified: data['verified']?.toString() ?? '',
      imagePath: data['imagePath'] ?? '',
      creationDate: data['creationDate'] ?? '',
      location: data['location'] ?? '',
      bio: data['bio'] ?? '',
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      avgReview: (data['avgReview'] ?? 0.0).toDouble(),
      lastLogin: data['lastLogin'] != null
          ? (data['lastLogin'] is Timestamp
              ? (data['lastLogin'] as Timestamp).toDate()
              : (DateTime.tryParse(data['lastLogin'].toString()) ?? DateTime.fromMillisecondsSinceEpoch(0)))
          : DateTime.fromMillisecondsSinceEpoch(0),
      vacations: vacationsList,
      fcmToken: data['fcmToken'],
      status: data['status']?.toString() ?? '', // <-- especially here!
      saved: data['saved'] != null ? List<String>.from(data['saved']) : <String>[],
    );

    return renter;
  }

  String get profilePicUrl {
    if (imagePath.isNotEmpty && (imagePath.startsWith('http://') || imagePath.startsWith('https://'))) {
      return imagePath;
    }
    return '';
  }
}
