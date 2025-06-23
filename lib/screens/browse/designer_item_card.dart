import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/styled_text.dart';

// ignore: must_be_immutable
class DesignerItemCard extends StatefulWidget {
  const DesignerItemCard(this.item, {super.key});

  final Item item;

  @override
  State<DesignerItemCard> createState() => _DesignerItemCardState();
}

class _DesignerItemCardState extends State<DesignerItemCard> {
  late String itemType;
  late String imageName;

  late String itemName;

  late String brandName;

  bool isFav = false;

  String setItemImage() {
    itemType = widget.item.type.replaceAll(RegExp(' +'), '_');
    itemName = widget.item.name.replaceAll(RegExp(' +'), '_');
    brandName = widget.item.brand.replaceAll(RegExp(' +'), '_');
    imageName = '${brandName}_${itemName}_${itemType}_1.jpg';
    return imageName;
  }

  bool isAFav(Item d, List favs) {
    if (favs.contains(d)) {
      return true;
    } else {
      return false;
    }
  }

  void _toggleFav() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      if (isFav == true) {
        isFav = false;
      } else {
        isFav = true;
      }
    });
  }

  String convertedrentPriceDaily = '-1';
  String convertedBuyPrice = '-1';
  String convertedRRPPrice = '-1';
  String symbol = '?';

  @override
  void initState() {
    List currListOfFavs =
        Provider.of<ItemStoreProvider>(context, listen: false).favourites;
    isFav = isAFav(widget.item, currListOfFavs);
    super.initState();
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
      String country = Provider.of<ItemStoreProvider>(context, listen: false)
          .renter
          .location;
      if (country == 'BANGKOK') {
      convertedrentPriceDaily = getPricePerDay(5).toString();
      convertedBuyPrice = convertFromTHB(widget.item.buyPrice, country);
      convertedRRPPrice = convertFromTHB(widget.item.rrp, country);
      symbol = getCurrencySymbol(country);
    } else {
      convertedrentPriceDaily = getPricePerDay(5).toString();
      convertedBuyPrice = widget.item.buyPrice.toString();
      convertedRRPPrice = widget.item.rrp.toString();
      symbol = globals.thb;
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    setPrice();
    return Card(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Center(child: StyledHeading(widget.item.brand)),
            // Image.asset('assets/img/items2/${setItemImage()}', width: 200, height: 600),
            Expanded(
              child: Image.asset('assets/img/items2/${setItemImage()}'),
            ),
            // Image.asset('assets/img/items2/${setItemImage()}', fit: BoxFit.fill),
            Row(
              // mainAxisAlignment: MainAxisAlignment.left,
              children: [
                StyledHeading(widget.item.name),
                const Expanded(child: SizedBox()),
                isFav
                    ? IconButton(
                        icon: Icon(Icons.favorite, size: width * 0.06),
                        color: Colors.red,
                        onPressed: () {
                          // isFav = false;
                          _toggleFav();
                          // Provider.of<ItemStoreProvider>(context, listen: false)
                          //   .toggleItemFav(item);
                          Renter toSave = Provider.of<ItemStoreProvider>(
                                  context,
                                  listen: false)
                              .renter;

                          toSave.favourites.remove(widget.item.id);
                          Provider.of<ItemStoreProvider>(context, listen: false)
                              .saveRenter(toSave);
                        })
                    : IconButton(
                        icon: Icon(Icons.favorite_border_outlined,
                            size: width * 0.06),
                        onPressed: () {
                          // isFav = true;
                          _toggleFav();
                          // Provider.of<ItemStoreProvider>(context, listen: false)
                          //   .toggleItemFav(item);
                          Renter toSave = Provider.of<ItemStoreProvider>(
                                  context,
                                  listen: false)
                              .renter;

                          toSave.favourites.add(widget.item.id);
                          Provider.of<ItemStoreProvider>(context, listen: false)
                              .saveRenter(toSave);
                        })
              ],
            ),
            // StyledText('Size: ${item.size.toString()}'),
            StyledBody('Rent from $convertedrentPriceDaily$symbol per day',
                weight: FontWeight.normal),
            StyledBodyStrikeout('RRP $convertedRRPPrice$symbol',
                weight: FontWeight.normal),
          ],
        ),
      ),
    );
  }
}
