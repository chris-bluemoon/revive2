import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/services/firestore_service.dart';

class FavouriteButton extends StatefulWidget {
  final Item item;
  const FavouriteButton({super.key, required this.item});

  @override
  State<FavouriteButton> createState() => _FavouriteButtonState();
}

class _FavouriteButtonState extends State<FavouriteButton> {
  bool get isFavourite {
    final renter = Provider.of<ItemStoreProvider>(context, listen: false).renter;
    return renter.favourites.contains(widget.item.id);
  }

  void _toggleFavourite() async {
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    final renter = itemStore.renter;
    setState(() {
      if (isFavourite) {
        renter.favourites.remove(widget.item.id);
      } else {
        renter.favourites.add(widget.item.id);
      }
      itemStore.saveRenter(renter);
    });
    // Update Firestore
    await FirestoreService.updateRenter(renter);
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return IconButton(
      icon: Icon(
        isFavourite ? Icons.favorite : Icons.favorite_border,
        size: width * 0.07,
        color: isFavourite ? Colors.red : Colors.grey[400],
      ),
      onPressed: _toggleFavourite,
      tooltip: isFavourite ? 'Remove from favourites' : 'Add to favourites',
    );
  }
}
