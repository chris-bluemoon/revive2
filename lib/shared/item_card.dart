import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/styled_text.dart';

// ignore: must_be_immutable
class ItemCard extends StatefulWidget {
  const ItemCard(this.item, {super.key});

  final Item item;

  @override
  State<ItemCard> createState() => _ItemCardState();
}

class _ItemCardState extends State<ItemCard> {

  bool isFav = false;

  bool isAFav(Item d, List favs) {
    if (favs.contains(d)) {
      return true;
    } else {
      return false;
    }
  }

  void _toggleFav() {
    setState(() {
      if (isFav == true) {
        isFav = false;
      } else {
        isFav = true;
      }
    });
  }

  String convertedRentPrice = '-1';
  String convertedBuyPrice = '-1';
  String convertedRRPPrice = '-1';
  String symbol = '?';

  Image? myImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    //ynt added first [if condition] to handle empty imageId
    //but still don't understand following [loop] and [second if condition]

    if (widget.item.imageId.isNotEmpty) {
      // Wait for images to be loaded if they aren't available yet
      final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
      
      // Try to find the image, with retry logic
      for (int attempt = 0; attempt < 3; attempt++) {
        bool imageFound = false;
        
        for (ItemImage i in itemStore.images) {
          if (i.id == widget.item.imageId[0]) {
            if (mounted) {
              setState(() {
                thisImage = i.imageId;
              });
            }
            imageFound = true;
            break;
          }
        }
        
        if (imageFound) break;
        
        // If not found and this isn't the last attempt, wait and try again
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 500 * (attempt + 1)));
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

  void setPrice() {
      String country = 'BANGKOK';
    if (country == 'BANGKOK') {
      convertedRentPrice = getPricePerDay(5).toString();
      convertedBuyPrice = convertFromTHB(widget.item.buyPrice, country);
      convertedRRPPrice = convertFromTHB(widget.item.rrp, country);
      symbol = getCurrencySymbol(country);
    } else {
      convertedRentPrice = getPricePerDay(5).toString();
      convertedBuyPrice = widget.item.buyPrice.toString();
      convertedRRPPrice = widget.item.rrp.toString();
      symbol = globals.thb;
    }
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
    double width = MediaQuery.of(context).size.width;
    List currListOfFavs =
        Provider.of<ItemStoreProvider>(context, listen: false).favourites;
    isFav = isAFav(widget.item, currListOfFavs);
    setPrice();
    if (thisImage == 'assets/img/items/No_Image_Available.jpg') {
      thisImage = '';
    }
    return Card(
      shape: BeveledRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      color: Colors.white,
      child: IntrinsicHeight(
        child: Padding(
          padding: EdgeInsets.all(width * 0.025), // Reduced padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Center(child: StyledHeading(widget.item.brand)),
            SizedBox(height: width * 0.01), // Reduced spacing
            AspectRatio(
              aspectRatio: 3 / 4,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: thisImage.isEmpty
                        ? Container(
                            width: double.infinity,
                            height: double.infinity,
                            color: Colors.grey[200],
                            child: widget.item.imageId.isNotEmpty
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                    ),
                                  )
                                : Image.asset(
                                    'assets/img/items/No_Image_Available.jpg',
                                    fit: BoxFit.cover,
                                  ),
                          )
                        : CachedNetworkImage(
                            imageUrl: thisImage,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                            placeholder: (context, url) => Container(
                              width: double.infinity,
                              height: double.infinity,
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Image.asset('assets/img/items/No_Image_Available.jpg', fit: BoxFit.cover),
                          ),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: IconButton(
                      icon: Icon(
                        isFav ? Icons.favorite : Icons.favorite_border_outlined,
                        size: width * 0.07,
                      ),
                      color: isFav ? Colors.red : Colors.black54,
                      onPressed: () {
                        _toggleFav();
                        Renter toSave = Provider.of<ItemStoreProvider>(
                          context,
                          listen: false,
                        ).renter;
                        if (isFav) {
                          toSave.favourites.add(widget.item.id);
                          Provider.of<ItemStoreProvider>(context, listen: false)
                              .saveRenter(toSave);
                          Provider.of<ItemStoreProvider>(context, listen: false)
                              .addFavourite(widget.item);
                        } else {
                          toSave.favourites.remove(widget.item.id);
                          Provider.of<ItemStoreProvider>(context, listen: false)
                              .saveRenter(toSave);
                          Provider.of<ItemStoreProvider>(context, listen: false)
                              .removeFavourite(widget.item);
                        }
                      },
                      splashRadius: width * 0.07,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
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
                'Rent from $convertedRentPrice$symbol',
                weight: FontWeight.bold,
                color: Colors.black,
                fontSize: widget.item.bookingType == 'both' ? width * 0.03 : null, // Smaller text for 'both'
              ),
            // Show buy price for "buy" or "both" booking types
            if (widget.item.bookingType == 'buy' || widget.item.bookingType == 'both') ...[
              if (widget.item.bookingType == 'both') SizedBox(height: width * 0.005), // Even smaller spacing
              StyledBody(
                'Buy for $convertedBuyPrice$symbol',
                weight: FontWeight.normal,
                fontSize: widget.item.bookingType == 'both' ? width * 0.03 : null, // Smaller text for 'both'
              ),
            ],
            SizedBox(height: width * (widget.item.bookingType == 'both' ? 0.005 : 0.01)), // Conditional spacing
            StyledBodyStrikeout('RRP ${widget.item.rrp}$symbol',
                weight: FontWeight.normal,
                fontSize: widget.item.bookingType == 'both' ? width * 0.025 : null), // Smaller RRP text for 'both'
          ],
        ),
      ),
    ),
    );
  }
}
