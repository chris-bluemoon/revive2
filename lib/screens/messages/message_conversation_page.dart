import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/message.dart';
// Add the correct import for ItemStoreProvider below.
// For example, if it's defined in item_store_provider.dart:
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/profile_avatar.dart';
import 'package:translator/translator.dart';

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
  final TextEditingController _captionController = TextEditingController();
  bool _autoTranslate = false;
  File? _selectedImage; // For holding the picked image before sending

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

  Future<String> _translateToThai(String text) async {
    final translator = GoogleTranslator();
    try {
      final translation = await translator.translate(text, to: 'th');
      return translation.text;
    } catch (e) {
      log('Translation error: $e');
      return text; // fallback to original if error
    }
  }

  void _sendMessage() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;
    final now = DateTime.now();

    if (_autoTranslate) {
      final translator = GoogleTranslator();
      try {
        // Detect the language
        final detected = await translator.translate(text);
        final detectedLang = detected.sourceLanguage.code;

        if (detectedLang == 'th') {
          // If input is Thai, translate to English
          final translation = await translator.translate(text, to: 'en');
          text = translation.text;
        } else {
          // If input is not Thai, translate to Thai
          final translation = await translator.translate(text, to: 'th');
          text = translation.text;
        }
      } catch (e) {
        log('Translation error: $e');
        // fallback to original text
      }
    }

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
    }

    _controller.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    setState(() {
      _selectedImage = File(pickedFile.path);
      _captionController.clear();
    });
  }

  Future<void> _sendImageWithCaption() async {
    if (_selectedImage == null) return;

    final file = _selectedImage!;
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_${widget.currentUserId}.jpg';
    final ref = FirebaseStorage.instance.ref().child('chat_images').child(fileName);

    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask.whenComplete(() {});
    final imageUrl = await snapshot.ref.getDownloadURL();

    final now = DateTime.now();
    final participants = [widget.currentUserId, widget.otherUserId];

    await FirebaseFirestore.instance.collection('messages').add({
      'imageUrl': imageUrl,
      'text': _captionController.text.trim(),
      'time': now,
      'participants': participants,
      'status': 'sent',
      'deletedFor': [],
    });

    setState(() {
      _selectedImage = null;
      _captionController.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _captionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final otherUser = widget.otherUser;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
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
              child: AppBarProfileAvatar(
                imageUrl: (otherUser['profilePicUrl'] != null && otherUser['profilePicUrl'].isNotEmpty) 
                  ? otherUser['profilePicUrl'] 
                  : '',
                userName: otherUser['name'] ?? '',
                radius: width * 0.06,
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
                                if ((data['imageUrl'] ?? '').isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.symmetric(vertical: 4),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        data['imageUrl'],
                                        width: 180,
                                        height: 180,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                if ((data['text'] ?? '').isNotEmpty)
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
                                // Audio playback removed: FlutterSoundPlayer usage deleted
                                // If you want to show an audio indicator, you can add a placeholder here.
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
            // --- Add the radio button here ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
              child: Row(
                children: [
                  Checkbox(
                    value: _autoTranslate,
                    onChanged: (val) {
                      setState(() {
                        _autoTranslate = val ?? false;
                      });
                    },
                  ),
                  const Text('Auto-translate Thai/English'),
                ],
              ),
            ),
            // --- End radio button ---
            // --- Image preview and caption input ---
            if (_selectedImage != null)
              Container(
                color: Colors.grey[100],
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        _selectedImage!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _captionController,
                        decoration: const InputDecoration(
                          hintText: "Add a caption...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_upward, color: Colors.green, size: 32),
                      onPressed: _sendImageWithCaption,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _selectedImage = null;
                          _captionController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
            // --- End image preview and caption input ---
            if (_selectedImage == null)
              Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add, color: Colors.black, size: 28), // Changed to black + icon
                      onPressed: _pickImage,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onChanged: (_) => setState(() {}),
                        decoration: const InputDecoration(
                          hintText: "Type your message...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    GestureDetector(
                      onTap: _controller.text.trim().isNotEmpty ? _sendMessage : null,
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _controller.text.trim().isNotEmpty ? Colors.green : Colors.grey[300],
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.arrow_upward,
                            color: _controller.text.trim().isNotEmpty ? Colors.white : Colors.grey[500],
                            size: 26,
                          ),
                        ),
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