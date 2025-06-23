import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';

class MessagePage extends StatefulWidget {
  final dynamic user;
  final dynamic item;
  const MessagePage({required this.user, required this.item, super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  final TextEditingController _controller = TextEditingController();
  final List<_SentMessage> _messages = [];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    log('Sending message: ${_controller.text}');
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();

    // Get the current user id from your authentication or provider
    final userId = Provider.of<ItemStoreProvider>(context, listen: false).renter.id;
    final ownerId = widget.user.id;
    log('Owner ID: $ownerId, User ID: $userId');
    log('Item name: ${widget.item?.name}');
    // Prevent sending message to self or with invalid participants
    if (ownerId == null || ownerId == userId) {
      return;
    }

    final participants = [userId, ownerId];

    await FirebaseFirestore.instance.collection('messages').add({
      'text': text,
      'time': now,
      'itemId': widget.item?.id,
      'participants': participants,
      'status': 'sent',
      'deletedFor': [],
    });

    setState(() {
      log('Sending message in setting state: $text');
      _messages.add(_SentMessage(
        text: text,
        time: now,
      ));
      _controller.clear();
    });
    FocusScope.of(context).unfocus();
  }

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  void _loadMessages() {
    final userId = Provider.of<ItemStoreProvider>(context, listen: false).renter.id;
    final ownerId = widget.user.id;

    // Assuming you have a list of messages in ItemStoreProvider called allMessages
    final allMessages = Provider.of<ItemStoreProvider>(context, listen: false).messages;

    // Filter messages for this conversation and not deleted for this user
    final filtered = allMessages.where((msg) {
      final participants = msg.participants ?? [];
      final deletedFor = msg.deletedFor ?? [];
      return participants.contains(userId) &&
             participants.contains(ownerId) &&
             !deletedFor.contains(userId);
    }).map<_SentMessage>((msg) => _SentMessage(
          text: msg.text ?? '',
          time: msg.time is Timestamp ? (msg.time as Timestamp).toDate() : msg.time,
        )).toList(); // <--- Explicitly cast to List<_SentMessage>

    setState(() {
      _messages.clear();
      _messages.addAll(filtered);
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final item = widget.item;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.user.name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: width * 0.06,
              backgroundColor: Colors.grey[300],
              backgroundImage: (widget.user.profilePicUrl != null && widget.user.profilePicUrl.isNotEmpty)
                  ? NetworkImage(widget.user.profilePicUrl)
                  : null,
              child: (widget.user.profilePicUrl == null || widget.user.profilePicUrl.isEmpty)
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
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                children: [
                  Text(
                    "All in-app rentals are monitored and are guaranteed on a case-by-case basis",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 18),
                  Text(
                    "All pricing is final. Negotiation is not allowed.",
                    style: TextStyle(color: Colors.black),
                  ),
                  SizedBox(height: 18),
                  Text(
                    "Revive will never ask you to verify or make payments outside of the app.",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            const Spacer(),
            // Show sent messages
            if (_messages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Column(
                  children: _messages.map((msg) {
                    return Align(
                      alignment: Alignment.centerRight,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              msg.text,
                              style: const TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                DateFormat('HH:mm').format(msg.time),
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.check, size: 16, color: Colors.grey),
                            ],
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            if (item != null)
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dress image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: (item.imageId != null && item.imageId.isNotEmpty)
                          ? (item.imageId[0] is String &&
                                  (item.imageId[0].startsWith('http://') ||
                                      item.imageId[0].startsWith('https://')))
                              ? Image.network(
                                  item.imageId[0],
                                  width: 48,
                                  height: 48,
                                  fit: BoxFit.cover,
                                )
                              : (item.imageId[0] is Map &&
                                      item.imageId[0]['url'] != null &&
                                      (item.imageId[0]['url'] as String).startsWith('http'))
                                  ? Image.network(
                                      item.imageId[0]['url'],
                                      width: 48,
                                      height: 48,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      width: 48,
                                      height: 48,
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.image, color: Colors.white),
                                    )
                          : Container(
                              width: 48,
                              height: 48,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image, color: Colors.white),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${item.type}  |  Size: ${item.size}',
                            style: const TextStyle(color: Colors.grey, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            // Message input row
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

class _SentMessage {
  final String text;
  final DateTime time;
  _SentMessage({required this.text, required this.time});
}