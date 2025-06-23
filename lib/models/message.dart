import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id; // Unique message ID
  // final String senderId; // ID of the user who sent the message  
  final String text;
  final DateTime time;
  final List<String> participants; // List of user IDs in the conversation
  final String status; // true if sent by current user, false if received
  final List<String> deletedFor; // List of user IDs in the conversation

  Message({
    required this.id, // Unique message ID
    required this.text,
    required this.time,
    required this.participants,
    required this.status,
    this.deletedFor = const [], // <-- Default to empty list
  });

  // Firestore: fromFirestore (same format as review.dart)
  factory Message.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data()!;
    return Message(
      id: snapshot.id,
      text: data['text'] ?? '',
      time: (data['time'] as Timestamp).toDate(),
      participants: List<String>.from(data['participants'] ?? []),
      status: data['status'],
      deletedFor: List<String>.from(data['deletedFor'] ?? []),
    );
  }

  // Firestore: toFirestore
  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'time': time,
      'participants': participants,
      'status': status,
      'deletedFor': deletedFor,
    };
  }
}