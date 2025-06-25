import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/message.dart';
// Add the correct import for ItemStoreProvider below.
// For example, if it's defined in item_store_provider.dart:
import 'package:revivals/providers/class_store.dart';

class MessageConversationPage extends StatefulWidget {
  final String currentUserId;
  final String otherUserId;
  final dynamic otherUser; // Pass user object or fetch in this page
  const MessageConversationPage({
    required this.currentUserId,
    required this.otherUserId,
    this.otherUser,
    super.key,
  });

  @override
  State<MessageConversationPage> createState() => _MessageConversationPageState();
}

class _MessageConversationPageState extends State<MessageConversationPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _markConversationAsRead();
  }

  Future<void> _markConversationAsRead() async {
    final query = await FirebaseFirestore.instance
        .collection('messages')
        .where('participants', arrayContains: widget.currentUserId)
        .get();

    for (var doc in query.docs) {
      final data = doc.data();
      final participants = List<String>.from(data['participants'] ?? []);
      // Only mark as read if the recipient is the current user
      // Assuming participants[0] is sender, participants[1] is recipient
      // Or, if you have a 'senderId' field, use that for clarity
      final isRecipient = participants.contains(widget.otherUserId) && participants.contains(widget.currentUserId)
        && participants[1] == widget.currentUserId;
      if (isRecipient) {
        if (!(data['status'] == 'read' ?? false)) {
          await doc.reference.update({'status': 'read'});
        }
        // Also update in-memory _messages if you have access to the provider
        try {
          final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
          final msgIndex = itemStore.messages.indexWhere((m) =>
            m.time == (data['time'] as Timestamp).toDate() &&
            m.text == data['text'] &&
            m.participants.toString() == participants.toString()
          );
          if (msgIndex != -1) {
            itemStore.messages[msgIndex] = Message(
              id: itemStore.messages[msgIndex].id, // Keep the same ID
              text: itemStore.messages[msgIndex].text,
              time: itemStore.messages[msgIndex].time,
              participants: itemStore.messages[msgIndex].participants,
              status: itemStore.messages[msgIndex].status,
              deletedFor: [],
            );
            itemStore.notifyListeners();
          }
        } catch (_) {
          // Ignore if provider is not available in this context
        }
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();

    final participants = [widget.currentUserId, widget.otherUserId];

    await FirebaseFirestore.instance.collection('messages').add({
      'text': text,
      'time': now,
      'participants': participants,
      'status': 'sent',
      'deletedFor': [],
    });

    // Add to in-memory messages in ItemStoreProvider
    try {
      final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
      itemStore.addMessage(
        Message(
          id: '', // Firestore will generate the ID
          text: text,
          time: now,
          participants: participants,
          status: 'sent',
          deletedFor: [],
        ),
      );
    } catch (_) {
      log('ItemStoreProvider not available in this context');
      // Ignore if provider is not available in this context
    }

    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final otherUser = widget.otherUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          otherUser != null ? (otherUser['name'] ?? widget.otherUserId) : widget.otherUserId,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          if (otherUser != null)
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: CircleAvatar(
                radius: width * 0.06,
                backgroundColor: Colors.grey[300],
                backgroundImage: (otherUser['profilePicUrl'] != null && otherUser['profilePicUrl'].isNotEmpty)
                    ? NetworkImage(otherUser['profilePicUrl'])
                    : null,
                child: (otherUser['profilePicUrl'] == null || otherUser['profilePicUrl'].isEmpty)
                    ? Icon(Icons.person, size: width * 0.06, color: Colors.white)
                    : null,
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .where('participants', arrayContains: widget.currentUserId)
                    .orderBy('time', descending: true) // reverse order
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Filter only messages between these two users
                  final docs = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final participants = List<String>.from(data['participants'] ?? []);
                    final deletedFor = List<String>.from(data['deletedFor'] ?? []);
                    return participants.contains(widget.otherUserId) &&
                           participants.contains(widget.currentUserId) &&
                           !deletedFor.contains(widget.currentUserId);
                  }).toList();

                  return ListView.builder(
                    reverse: true, // puts messages at the bottom and scrolls up
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final DateTime msgTime = (data['time'] as Timestamp).toDate();
                      final String msgDate = DateFormat('yMMMMd').format(msgTime);

                      // Check if we need to show the date header
                      bool showDateHeader = false;
                      if (index == docs.length - 1) {
                        showDateHeader = true;
                      } else {
                        final nextData = docs[index + 1].data() as Map<String, dynamic>;
                        final DateTime nextMsgTime = (nextData['time'] as Timestamp).toDate();
                        final String nextMsgDate = DateFormat('yMMMMd').format(nextMsgTime);
                        if (msgDate != nextMsgDate) {
                          showDateHeader = true;
                        }
                      }

                      // Determine if this message is sent by the current user
                      final participants = List<String>.from(data['participants'] ?? []);
                      final isMe = participants[0] == widget.currentUserId;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (showDateHeader)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Center(
                                child: Text(
                                  msgDate,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Column(
                              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: const EdgeInsets.symmetric(vertical: 4),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isMe ? Colors.black : Colors.grey[300],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    data['text'] ?? '',
                                    style: TextStyle(
                                      color: isMe ? Colors.white : Colors.black,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['time'] != null
                                      ? DateFormat('HH:mm').format((data['time'] as Timestamp).toDate())
                                      : '',
                                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward, color: Colors.green, size: 32),
                    onPressed: _sendMessage,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      // onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}