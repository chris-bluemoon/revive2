import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/to_rent/view_image.dart';
import 'package:revivals/shared/loading.dart';

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
  late String thisImage;

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
    for (ItemImage i
        in Provider.of<ItemStoreProvider>(context, listen: false).images) {
      if (i.id == widget.item.imageId[widget.itemNumber - 1]) {
        log(widget.item.imageId[widget.itemNumber - 1].toString());
        thisImage = i.imageId;
      }
    }
    // images.add(thisImage);
    //   return thisImage;
    // }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => (ViewImage(
                  images,
                  0,
                ))));
      },
      child: CachedNetworkImage(
        imageUrl: thisImage,
        placeholder: (context, url) => const Loading(),
        errorWidget: (context, url, error) =>
            Image.asset('assets/img/items/No_Image_Available.jpg'),
      ),
    );
    // return Image.asset(setItemImage(), fit: BoxFit.contain);
    // child: Image.asset(setItemImage(),),
    // fit: BoxFit.fill,
    // );
  }
}
