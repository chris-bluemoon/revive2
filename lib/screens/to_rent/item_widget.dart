import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/to_rent/view_image.dart';
import 'package:revivals/shared/loading.dart';
import 'package:revivals/shared/smooth_page_route.dart';

class ItemWidget extends StatefulWidget {
  const ItemWidget({super.key, required this.item, required this.itemNumber});

  final int itemNumber;
  final Item item;

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  late String itemType;
  late String itemName;
  late String brandName;
  late String imageName;
  String thisImage = '';

  late final List<String> images;

  @override
  void initState() {
    super.initState();
    images = _getImagesOnce();
  }

  List<String> _getImagesOnce() {
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    final List<String> result = [];
    log('ItemStore images count: \\${itemStore.images.length}');
    // Only add images in the order of widget.item.imageId, and only once per id
    for (String imageId in widget.item.imageId) {
      final match = itemStore.images.firstWhere(
        (img) => img.id == imageId,
        orElse: () => ItemImage(id: '', imageId: ''),
      );
      if (match.id.isNotEmpty) {
        result.add(match.imageId);
        log('Adding image: \\${match.imageId} for item \\${widget.item.name}, number \\${widget.itemNumber}');
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    // Find the specific image for this item number
    thisImage = '';
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    for (ItemImage i in itemStore.images) {
      if (widget.item.imageId.isNotEmpty &&
          widget.itemNumber <= widget.item.imageId.length &&
          i.id == widget.item.imageId[widget.itemNumber - 1]) {
        log(widget.item.imageId[widget.itemNumber - 1].toString());
        thisImage = i.imageId;
        break;
      }
    }
    if (thisImage.isEmpty) {
      log('No image found for item \\${widget.item.name}, number \\${widget.itemNumber}');
    }
    return GestureDetector(
      onTap: () {
        log('Number of images: \\${images.length}');
        if (images.isNotEmpty) {
          Navigator.of(context).push(SmoothTransitions.luxury(ViewImage(
            images,
            0,
          )));
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.0),
        child: thisImage.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: thisImage,
                placeholder: (context, url) => const Loading(),
                errorWidget: (context, url, error) =>
                    Image.asset('assets/img/items/No_Image_Available.jpg'),
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/img/items/No_Image_Available.jpg',
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
