import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/animated_logo_spinner.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:revivals/screens/to_rent/_bookmark_button.dart';

// ignore: must_be_immutable
class ItemCard extends StatefulWidget {
  const ItemCard(this.item, {super.key});

  final Item item;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {



  String symbol = globals.thb;

  Image? myImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Try to load image again when dependencies change (e.g., when images are loaded)
    if (thisImage.isEmpty && widget.item.imageId.isNotEmpty) {
      _loadImage();
    }
  }

  void _loadImage() async {
    if (widget.item.imageId.isNotEmpty) {
      final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
      
      // First attempt - immediate check
      for (ItemImage i in itemStore.images) {
        if (i.id == widget.item.imageId[0]) {
          if (mounted) {
            setState(() {
              thisImage = i.imageId;
            });
          }
          return; // Found it, exit early
        }
      }
      
      // If not found immediately, try with delays
      for (int attempt = 0; attempt < 3; attempt++) {
        await Future.delayed(Duration(milliseconds: 500 + (attempt * 300)));
        
        if (!mounted) return; // Check if widget is still mounted
        
        // Refetch images if needed
        if (attempt > 0) {
          await itemStore.fetchImages();
        }
        
        // Try to find the image again
        for (ItemImage i in itemStore.images) {
          if (i.id == widget.item.imageId[0]) {
            if (mounted) {
              setState(() {
                thisImage = i.imageId;
              });
            }
            return; // Found it, exit
          }
        }
      }
      
      // If still not found after all attempts, log for debugging
      if (mounted && thisImage.isEmpty) {
        print('Failed to load image for item: ${widget.item.name}, imageId: ${widget.item.imageId[0]}');
        print('Available images count: ${itemStore.images.length}');
        if (itemStore.images.isNotEmpty) {
          print('First few image IDs: ${itemStore.images.take(3).map((i) => i.id).toList()}');
        }
      }
    }
  }

  int getPricePerDay(noOfDays) {
    String country = 'BANGKOK';

    int oneDayPrice = widget.item.rentPriceDaily;

    if (country == 'BANGKOK') {
      oneDayPrice = widget.item.rentPriceDaily;
    } else {
      oneDayPrice = int.parse(convertFromTHB(widget.item.rentPriceDaily, country));
    }

    if (noOfDays == 3) {
      int threeDayPrice = (oneDayPrice * 0.8).toInt() - 1;
      if (country == 'BANGKOK') {
        return (threeDayPrice ~/ 100) * 100 + 100;
      } else {
        return (threeDayPrice ~/ 5) * 5 + 5;
      }
    }
    if (noOfDays == 5) {
      int fiveDayPrice = (oneDayPrice * 0.6).toInt() - 1;
      if (country == 'BANGKOK') {
        return (fiveDayPrice ~/ 100) * 100 + 100;
      } else {
        return (fiveDayPrice ~/ 5) * 5 + 5;
      }
    }
    return oneDayPrice;
  }

  String getSize(sizeArray) {
    String formattedSize = 'N/A';
    if (sizeArray.length == 1) {
      formattedSize = sizeArray.first;
    }
    if (sizeArray.length == 2) {
      String firstSize;
      String secondSize;
      firstSize = sizeArray.elementAt(0);
      secondSize = sizeArray.elementAt(1);
      formattedSize = '$firstSize-$secondSize';
    }
    return formattedSize;
  }

  String thisImage = 'assets/img/items/No_Image_Available.jpg';
// Widget createImage(String imageName) {
//   return Image.asset(imageName,
//       errorBuilder: (context, object, stacktrace) =>
//           Image.asset('assets/img/items/No_Image_Available.jpg'));
// }
  @override
  Widget build(BuildContext context) {
    return Consumer<ItemStoreProvider>(
      builder: (context, itemStore, child) {
        // Try to load image if it's still empty and images are available
        if (thisImage.isEmpty && widget.item.imageId.isNotEmpty && itemStore.images.isNotEmpty) {
          for (ItemImage i in itemStore.images) {
            if (i.id == widget.item.imageId[0]) {
              thisImage = i.imageId;
              break;
            }
          }
        }
        
        double width = MediaQuery.of(context).size.width;
        List currListOfFavs = itemStore.favourites;
        isFav = isAFav(widget.item, currListOfFavs);
        
        // Determine what to show: actual image URL, spinner, or fallback
        String displayImage = '';
        bool showSpinner = false;
        
        if (thisImage != 'assets/img/items/No_Image_Available.jpg' && thisImage.isNotEmpty) {
          // We have an actual image URL to display
          displayImage = thisImage;
        } else if (widget.item.imageId.isNotEmpty) {
          // We should have an image but it's not loaded yet, show spinner
          showSpinner = true;
        }
        // If no imageId, we'll show the fallback image
        
        return Card(
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          color: Colors.white,
          child: IntrinsicHeight(
            child: Padding(
              padding: EdgeInsets.all(width * 0.025),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(child: StyledHeading(widget.item.brand)),
                  SizedBox(height: width * 0.01),
                  AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: showSpinner
                              ? Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: AnimatedLogoSpinner(
                                      size: 60,
                                    ),
                                  ),
                                )
                              : displayImage.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: displayImage,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                      placeholder: (context, url) => Container(
                                        width: double.infinity,
                                        height: double.infinity,
                                        color: Colors.grey[200],
                                        child: const Center(
                                          child: AnimatedLogoSpinner(
                                            size: 60,
                                          ),
                                        ),
                                      ),
                                      errorWidget: (context, url, error) =>
                                          Image.asset('assets/img/items/No_Image_Available.jpg', fit: BoxFit.cover),
                                    )
                                  : Image.asset(
                                      'assets/img/items/No_Image_Available.jpg',
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: double.infinity,
                                    ),
                        ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: BookmarkButton(item: widget.item),
                  ),
                ],
              ),
            ),
            SizedBox(height: width * 0.015), // Kept this spacing after image
            Row(
              children: [
                Container(
                  width: width * 0.40, // Use more of the card's width
                  alignment: Alignment.centerLeft,
                  child: StyledHeading(
                    widget.item.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(width: width * 0.01),
              ],
            ),
            SizedBox(height: width * (widget.item.bookingType == 'both' ? 0.005 : 0.01)), // Even less spacing for 'both' type
            StyledBody(
              '${widget.item.type}, UK ${widget.item.size}',
              weight: FontWeight.normal,
            ),
            SizedBox(height: width * (widget.item.bookingType == 'both' ? 0.005 : 0.01)), // Even less spacing for 'both' type
            // Show rental price for "rental" or "both" booking types
            if (widget.item.bookingType == 'rental' || widget.item.bookingType == 'both')
              StyledBody(
                'Rent from ${getPricePerDay(5)}$symbol',
                weight: FontWeight.bold,
                color: Colors.black,
                fontSize: widget.item.bookingType == 'both' ? width * 0.03 : null, // Smaller text for 'both'
              ),
            // Show buy price for "buy" or "both" booking types
            if (widget.item.bookingType == 'buy' || widget.item.bookingType == 'both') ...[
              if (widget.item.bookingType == 'both') SizedBox(height: width * 0.005), // Even smaller spacing
              StyledBody(
                'Buy for ${widget.item.buyPrice}$symbol',
                weight: FontWeight.normal,
                fontSize: widget.item.bookingType == 'both' ? width * 0.03 : null, // Smaller text for 'both'
              ),
            ],
            SizedBox(height: width * (widget.item.bookingType == 'both' ? 0.005 : 0.01)), // Conditional spacing
            StyledBodyStrikeout('RRP ${widget.item.rrp}$symbol',
                weight: FontWeight.normal,
                fontSize: widget.item.bookingType == 'both' ? width * 0.025 : null),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
