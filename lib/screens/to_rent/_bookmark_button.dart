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
  bool get isFav {
    final renter = Provider.of<ItemStoreProvider>(context, listen: false).renter;
    return renter.favourites.contains(widget.item.id);
  }

  void _toggleFav() {
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    final renter = itemStore.renter;
    setState(() {
      if (isFav) {
        renter.favourites.remove(widget.item.id);
      } else {
        renter.favourites.add(widget.item.id);
      }
      itemStore.saveRenter(renter);
    });
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return IconButton(
      icon: Icon(
        isFav ? Icons.bookmark : Icons.bookmark_border,
        size: width * 0.05,
        color: isFav ? Colors.amber : Colors.grey[400], // More visually appealing colors
      ),
      onPressed: _toggleFav,
      tooltip: isFav ? 'Remove from saved' : 'Save as favourite',
    );
  }
}
