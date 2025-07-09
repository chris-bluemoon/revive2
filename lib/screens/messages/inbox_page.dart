import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:revivals/screens/messages/message_conversation_page.dart';
import 'package:revivals/screens/profile/report_page.dart';
import 'package:revivals/shared/animated_logo_spinner.dart';
import 'package:revivals/shared/profile_avatar.dart';
import 'package:revivals/shared/smooth_page_route.dart';
import 'package:revivals/shared/styled_text.dart';

class InboxPage extends StatefulWidget {
  final String currentUserId; // Pass the current user's ID

  const InboxPage({super.key, required this.currentUserId});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  final Set<String> _dismissedConversations = <String>{};

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
            .where('participants', arrayContains: widget.currentUserId)
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CenteredLogoSpinner(size: 80);
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: StyledBody(
                'No New Messages',
                color: Colors.grey,
                weight: FontWeight.normal,
              ),
            );
          }
          // Filter out messages deleted for the current user
          final filteredDocs = snapshot.data!.docs.where((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final deletedFor = List<String>.from(data['deletedFor'] ?? []);
            return !deletedFor.contains(widget.currentUserId);
          }).toList();

          // Group messages by other participant to get the latest message per conversation
          final Map<String, QueryDocumentSnapshot> latestMessages = {};
          for (var doc in filteredDocs) {
            final data = doc.data() as Map<String, dynamic>;
            // No need to check deletedFor again here
            final participants = List<String>.from(data['participants'] ?? []);
            log('Participants: $participants');
            final otherUserIds = participants.where((id) => id != widget.currentUserId).toList();
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

          // Filter out dismissed conversations
          final visiblePreviews = messagePreviews.where((preview) => 
              !_dismissedConversations.contains(preview.userId)).toList();

          for (var i in visiblePreviews) {
            log('Message Preview: ${i.userId}, ${i.latestMessage}, ${i.time}');
          } 

          if (visiblePreviews.isEmpty) {
            return const Center(
              child: StyledBody(
                'No New Messages',
                color: Colors.grey,
                weight: FontWeight.normal,
              ),
            );
          }

          return ListView.separated(
            itemCount: visiblePreviews.length,
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
              final preview = visiblePreviews[index];
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
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                                      child: Center(
                                        child: Text(
                                          'DELETE',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context).size.width * 0.04,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  InkWell(
                                    onTap: () => Navigator.of(context).pop('delete_report'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                                      child: Center(
                                        child: Text(
                                          'DELETE AND REPORT',
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context).size.width * 0.04,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(height: 1),
                                  InkWell(
                                    onTap: () => Navigator.of(context).pop('cancel'),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                                      child: Center(
                                        child: Text(
                                          'CANCEL',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold,
                                            fontSize: MediaQuery.of(context).size.width * 0.04,
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
                        // Navigate to report page first, then delete the conversation
                        log('Delete and report conversation for user ${preview.userId}');
                        // Get user data for report page
                        final userData = await FirebaseFirestore.instance
                            .collection('renter')
                            .doc(preview.userId)
                            .get();
                        final reportedUserName = userData.exists 
                            ? (userData.data() as Map<String, dynamic>)['name'] ?? preview.userId 
                            : preview.userId;
                        
                        if (context.mounted) {
                          Navigator.of(context).push(
                            SmoothTransitions.luxury(ReportPage(
                              reportedUserId: preview.userId,
                              reportedUserName: reportedUserName,
                            )),
                          );
                        }
                        return true;
                      }
                      // Cancel or dismissed
                      return false;
                    },
                    onDismissed: (direction) {
                      // Add the conversation to dismissed set immediately to prevent rebuild issues
                      setState(() {
                        _dismissedConversations.add(preview.userId);
                      });
                      
                      // Use post-frame callback to ensure the dismiss animation completes
                      // before updating the data, preventing the tree inconsistency error
                      WidgetsBinding.instance.addPostFrameCallback((_) async {
                        // Delete the specific conversation between current user and the other user
                        try {
                          log('Starting deletion process - Current User: ${widget.currentUserId}, Other User: ${preview.userId}');
                          final firestore = FirebaseFirestore.instance;
                          final query = await firestore
                              .collection('messages')
                              .where('participants', arrayContains: widget.currentUserId)
                              .get();

                          log('Found ${query.docs.length} messages involving current user');

                          for (var doc in query.docs) {
                            final participants = List<String>.from(doc['participants'] ?? []);
                            // Only delete messages in this specific conversation
                            if (participants.contains(preview.userId) && participants.contains(widget.currentUserId)) {
                              final List<dynamic> deletedFor = doc['deletedFor'] ?? [];
                              log('Processing message ${doc.id} - Participants: $participants, Before update - deletedFor: $deletedFor');
                              if (!deletedFor.contains(widget.currentUserId)) {
                                await firestore.collection('messages').doc(doc.id).update({
                                  'deletedFor': FieldValue.arrayUnion([widget.currentUserId]),
                                });
                                log('✓ Updated message ${doc.id} - added ONLY ${widget.currentUserId} to deletedFor');
                              } else {
                                log('⚠ Message ${doc.id} already marked as deleted for ${widget.currentUserId}');
                              }
                            } else {
                              log('⏩ Skipping message ${doc.id} - not part of this conversation (participants: $participants)');
                            }
                          }
                          
                          // Optionally show a snackbar
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Conversation deleted'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        } catch (e) {
                          log('Error deleting conversation: $e');
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to delete conversation'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            // Re-add to visible list if deletion failed
                            setState(() {
                              _dismissedConversations.remove(preview.userId);
                            });
                          }
                        }
                      });
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    child: ListTile(
                      leading: ProfileAvatar(
                        imageUrl: profilePic,
                        userName: displayName,
                        radius: 20,
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
                          SmoothTransitions.luxury(MessageConversationPage(
                              currentUserId: widget.currentUserId,
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