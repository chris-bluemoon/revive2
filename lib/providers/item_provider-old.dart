import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  // Debug utility to check a specific user's status
  Future<void> debugCheckUserStatus(String email) async {
    try {
      print('🔍 DEBUG: Checking status for email: $email');

      // Check in authentication
      User? firebaseUser = FirebaseAuth.instance.currentUser;
      print('🔍 DEBUG: Firebase Auth user: ${firebaseUser?.email}');

      // Check in renters collection
      QuerySnapshot renterQuery = await FirebaseFirestore.instance
          .collection('renters')
          .where('email', isEqualTo: email)
          .get();

      print('🔍 DEBUG: Found ${renterQuery.docs.length} renter records for $email');

      for (var doc in renterQuery.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('🔍 DEBUG: Renter document ${doc.id}:');
        print('   - status: "${data['status']}" (type: ${data['status'].runtimeType})');
        print('   - email: "${data['email']}"');
        print('   - name: "${data['name']}"');
        print('   - Raw status bytes: ${data['status']?.codeUnits}');
      }
    } catch (e) {
      print('🔍 DEBUG: Error checking user status: $e');
    }
  }

  // ...existing code...
}