import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/providers/class_store.dart';

class BookmarkButton extends StatefulWidget {
  final Item item;
  const BookmarkButton({super.key, required this.item});

  @override
  State<BookmarkButton> createState() => _BookmarkButtonState();
}

class _BookmarkButtonState extends State<BookmarkButton> {
  bool get isSaved {
    final renter = Provider.of<ItemStoreProvider>(context, listen: false).renter;
    return renter.saved.contains(widget.item.id);
  }

  void _toggleSaved() {
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    final renter = itemStore.renter;
    setState(() {
      if (isSaved) {
        renter.saved.remove(widget.item.id);
      } else {
        renter.saved.add(widget.item.id);
      }
      itemStore.saveRenter(renter);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return IconButton(
      icon: Icon(
        isSaved ? Icons.bookmark : Icons.bookmark_border,
        size: width * 0.05, // Revert to original size
        color: isSaved ? Colors.amber : Colors.grey[400],
      ),
      onPressed: _toggleSaved,
      tooltip: isSaved ? 'Remove from saved' : 'Save as favourite',
    );
  }
}
