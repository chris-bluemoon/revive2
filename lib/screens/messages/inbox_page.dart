import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/messages/message_conversation_page.dart';
import 'package:revivals/shared/styled_text.dart';

class InboxPage extends StatelessWidget {
  final String currentUserId; // Pass the current user's ID

  const InboxPage({super.key, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const StyledTitle('INBOX'),
        ),
      backgroundColor: Colors.white,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('messages')
            .where('participants', arrayContains: currentUserId)
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No messages'));
          }
          // Filter out messages deleted for the current user
          final filteredDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final deletedFor = List<String>.from(data['deletedFor'] ?? []);
            return !deletedFor.contains(currentUserId);
          }).toList();

          // Group messages by other participant to get the latest message per conversation
          final Map<String, QueryDocumentSnapshot> latestMessages = {};
          for (var doc in filteredDocs) {
            final data = doc.data() as Map<String, dynamic>;
            // No need to check deletedFor again here
            final participants = List<String>.from(data['participants'] ?? []);
            log('Participants: $participants');
            final otherUserIds = participants.where((id) => id != currentUserId).toList();
            if (otherUserIds.isEmpty) continue;
            final otherUserId = otherUserIds.first;
            if (!latestMessages.containsKey(otherUserId)) {
              latestMessages[otherUserId] = doc;
            }
          }

          final messagePreviews = latestMessages.entries.map((entry) {
            final doc = entry.value;
            final data = doc.data() as Map<String, dynamic>;
            // final participants = List<String>.from(data['participants'] ?? []);
            final otherUserId = entry.key;
            return _MessagePreviewWithUserId(
              userId: otherUserId,
              latestMessage: data['text'] ?? '',
              time: data['time'] != null
                  ? (data['time'] as Timestamp).toDate().toLocal().toString().substring(0, 16)
                  : '',
            );
          }).toList();

          for (var i in messagePreviews) {
            log('Message Preview: ${i.userId}, ${i.latestMessage}, ${i.time}');
          } 

          return ListView.separated(
            itemCount: messagePreviews.length,
            separatorBuilder: (_, __) => const Row(
              children: [
                SizedBox(width: 16), // Add space at the start
                Expanded(
                  child: Divider(
                    height: 1,
                    thickness: 1,
                    color: Color(0xFF444444),
                  ),
                ),
                SizedBox(width: 16), // Add space at the end
              ],
            ),
            itemBuilder: (context, index) {
              final preview = messagePreviews[index];
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('renter')
                    .doc(preview.userId)
                    .get(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    // Don't show anything until the name is resolved
                    return const SizedBox.shrink();
                  }
                  final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                  log('User Data: ${userData['name']}, ${userData['imagePath']}');
                  log('Other User ID: ${preview.userId}');

                  final displayName = userData['name'] ?? preview.userId;
                  final profilePic = userData['imagePath'] ?? '';
                  return Dismissible(
                    key: Key(preview.userId), // Use a unique key for each conversation
                    direction: DismissDirection.endToStart, // Swipe left to delete
                    confirmDismiss: (direction) async {
                      String? action = await showModalBottomSheet<String>(
                        context: context,
                        builder: (context) {
                          return SafeArea(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                  InkWell(
                                    onTap: () => Navigator.of(context).pop('delete'),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 18.0),
                                      child: Center(
                                        child: Text(
                                          'DELETE',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  InkWell(
                                    onTap: () => Navigator.of(context).pop('delete'),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 18.0),
                                      child: Center(
                                        child: Text(
                                          'DELETE AND REPORT',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  InkWell(
                                    onTap: () => Navigator.of(context).pop('delete'),
                                    child: const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 18.0),
                                      child: Center(
                                        child: Text(
                                          'CANCEL',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  ],
                                ),
                                const SizedBox(height: 16),
                              ],
                            ),
                          );
                        },
                      );
                      if (action == 'delete') {
                        log('Deleting conversation for user ${preview.userId}');
                        // final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                        // itemStore.deleteMessagesByParticipant(preview.userId); 

                        return true;
                      } else if (action == 'delete_report') {
                        // Handle report logic here if needed
                        // For now, also delete:137
                        // You can call your report function here
                        return true;
                      }
                      // Cancel or dismissed
                      return false;
                    },
                    onDismissed: (direction) {
                      // Remove the conversation from your data source
                      // Optionally show a snackbar
                      
                      messagePreviews.removeAt(index);
                      final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                      itemStore.deleteMessagesByParticipant(currentUserId);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: profilePic.isNotEmpty
                            ? NetworkImage(profilePic)
                            : null,
                        backgroundColor: Colors.grey[300],
                        child: (profilePic.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: Text(
                        displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        preview.latestMessage,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Text(
                        preview.time,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => MessageConversationPage(
                              currentUserId: currentUserId,
                              otherUserId: preview.userId,
                              otherUser: {
                                'name': displayName,
                                'profilePicUrl': profilePic,
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _MessagePreviewWithUserId {
  final String userId;
  final String latestMessage;
  final String time;

  _MessagePreviewWithUserId({
    required this.userId,
    required this.latestMessage,
    required this.time,
  });
}