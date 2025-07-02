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
  // late Image thisImage;
  String thisImage = ''; // Initialize with empty string to prevent LateInitializationError

  // late List<Image> images = [];
  late List<String> images = [];

  @override
  Widget build(BuildContext context) {
    images.clear();

    // String itemImage = 'assets/img/items2/${widget.item.brand}_${widget.item.name}_Item_${widget.itemNumber}.jpg';
    // return FittedBox(
    //ynt moved folowing function from outer build to inner build
    // String setItemImage() {
    // itemType = toBeginningOfSentenceCase(widget.item.type.replaceAll(RegExp(' +'), '_'));
    // itemName = widget.item.name.replaceAll(RegExp(' +'), '_');
    // brandName = widget.item.brand.replaceAll(RegExp(' +'), '_');
    // imageName = 'assets/img/items2/${brandName}_${itemName}_${itemType}_${widget.itemNumber}.jpg';
    // return imageName;
    for (ItemImage i
        in Provider.of<ItemStoreProvider>(context, listen: false).images) {
      for (String j in widget.item.imageId) {
        if (i.id == j) {
          images.add(i.imageId);
        }
      }
    }
    
    // Find the specific image for this item number
    thisImage = ''; // Reset to empty string
    for (ItemImage i
        in Provider.of<ItemStoreProvider>(context, listen: false).images) {
      if (widget.item.imageId.isNotEmpty && 
          widget.itemNumber <= widget.item.imageId.length &&
          i.id == widget.item.imageId[widget.itemNumber - 1]) {
        log(widget.item.imageId[widget.itemNumber - 1].toString());
        thisImage = i.imageId;
        break; // Exit loop once found
      }
    }
    
    // If no image was found, try to use a fallback or placeholder
    if (thisImage.isEmpty) {
      log('No image found for item ${widget.item.name}, number ${widget.itemNumber}');
      // Could set a default image URL here if needed
    }
    // images.add(thisImage);
    //   return thisImage;
    // }

    return GestureDetector(
      onTap: () {
        // Only navigate if we have images to show
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
              ), // Fallback when no image URL
      ),
    );
    // return Image.asset(setItemImage(), fit: BoxFit.contain);
    // child: Image.asset(setItemImage(),),
    // fit: BoxFit.fill,
    // );
  }
}
