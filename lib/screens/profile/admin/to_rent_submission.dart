import 'package:carousel_slider/carousel_slider.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/authenticate/sign_in_up.dart';
import 'package:revivals/screens/to_rent/item_widget.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

// ignore: must_be_immutable
class ToRentSubmission extends StatefulWidget {
  ToRentSubmission(this.item, {super.key});

  @override
  State<ToRentSubmission> createState() => _ToRentSubmissionState();

  final Item item;
  late String itemName;
  late String imageName;
  late String itemType;

  // String setItemImage() {
  //   itemType = item.type.replaceAll(RegExp(' '), '_');
  //   itemName = item.name.replaceAll(RegExp(' '), '_');
  //   imageName = '${item.brand}_${itemName}_${itemType}.webp';
  //   return imageName;
  // }

  // final ValueNotifier<int> rentalDays = ValueNotifier<int>(0);
}

class _ToRentSubmissionState extends State<ToRentSubmission> {
  List items = [];
  int currentIndex = 0;
  bool itemCheckComplete = false;
  List<Color> dotColours = [];

  CarouselSliderController buttonCarouselSliderController =
      CarouselSliderController();

  String convertedrentPriceDaily = '-1';
  String convertedBuyPrice = '-1';
  String convertedRRPPrice = '-1';
  String symbol = '?';

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

  @override
  void initState() {
    setPrice();
    _initImages();
    super.initState();
  }

  void setPrice() {
      String country = 'BANGKOK';
      //
      if (country == 'BANGKOK') {
      convertedrentPriceDaily = getPricePerDay(5).toString();
      // convertedrentPriceDaily = convertFromTHB(getPricePerDay(1), country);
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

  Future _initImages() async {
    int counter = 0;
    for (String i in widget.item.imageId) {
      counter++;
      items.add(counter);
      dotColours.add(Colors.grey);
    }
    setState(() {
      itemCheckComplete = true;
    });
  }
  // Future _initImages() async {
  //   // >> To get paths you need these 2 lines
  //   // List<String> someImages = [];
  //   final manifestContent = await rootBundle.loadString('AssetManifest.json');

  //   final Map<String, dynamic> manifestMap = json.decode(manifestContent);
  //   // >> To get paths you need these 2 lines

  //   int counter = 0;
  //   for (String i in widget.item.imageId) {
  //     String brand = widget.item.brand.replaceAll(RegExp(' +'), '_');
  //     String name = widget.item.name.replaceAll(RegExp(' +'), '_');
  //     String toCompare = '${brand}_$name';
  //     if (i.contains(toCompare)) {
  //
  //       counter++;
  //       items.add(counter);
  //       dotColours.add(Colors.grey);
  //     }
  //     setState(() {
  //       itemCheckComplete = true;
  //
  //     });
  //   }
  // setState(() {
  // someImages = imagePaths;
  // });
  // }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StyledTitle(widget.item.name.toUpperCase()),
            // Image.asset(
            //   'assets/logos/unearthed_logo_2.png',
            //   fit: BoxFit.contain,
            //   height: 200,
            // ),
          ],
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
              onPressed: () =>
                  {Navigator.of(context).popUntil((route) => route.isFirst)},
              icon: Padding(
                padding: EdgeInsets.fromLTRB(0, 0, width * 0.01, 0),
                child: Icon(Icons.close, size: width * 0.06),
              )),
        ],
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(4.0),
        //   child: Container(
        //     color: Colors.grey[300],
        //     height: 1.0,
        //   )
        // ),
      ),
      body: (!itemCheckComplete)
          ? const Text('Loading')
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: width * 0.01),
                  (items.length == 1)
                      ? SizedBox(
                          height: width,
                          child: Center(
                              child:
                                  ItemWidget(item: widget.item, itemNumber: 1)))
                      : CarouselSlider(
                          carouselController: buttonCarouselSliderController,
                          options: CarouselOptions(
                              onPageChanged: (index, reason) {
                                setState(() {
                                  currentIndex = index;
                                });
                              },
                              height: width * 1,
                              autoPlay: true),
                          items: items.map((i) {
                            return Builder(
                              builder: (BuildContext context) {
                                return ItemWidget(
                                    item: widget.item, itemNumber: i);
                                // return const SizedBox(child: Text("BOX"), height: 20, width: 20);
                              },
                            );
                          }).toList(),
                        ),
                  SizedBox(height: width * 0.03),
                  if (items.length > 1)
                    Center(
                      child: DotsIndicator(
                        dotsCount: items.length,
                        position: currentIndex,
                        decorator: DotsDecorator(
                          colors: dotColours,
                          activeColor: Colors.black,
                          // colors: [Colors.grey[300], Colors.grey[600], Colors.grey[900]], // Inactive dot colors
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.all(width * 0.05),
                    child: StyledHeading(widget.item.description),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.05, bottom: width * 0.05),
                    child: StyledBody(
                        'Rental price: From $convertedrentPriceDaily$symbol'),
                    // child: StyledBody('Rental price: ${widget.item.rentPriceDaily.toString()} ${getCurrency()}'),
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: width * 0.05, bottom: width * 0.05),
                    child: StyledBody(widget.item.longDescription,
                        weight: FontWeight.normal),
                  ),
                  // if (widget.item.rentPriceDaily > 0) Padding(
                  // padding: const EdgeInsets.only(left: 20, bottom: 10),
                  // child: RentalDaysRadioWidget(updateRentalDays),
                  // ),
                ],
              ),
            ),
      bottomNavigationBar: Container(
        // height: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 3,
            )
          ],
        ),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Expanded(
                child: OutlinedButton(
              onPressed: () {
                // Navigator.of(context).push(MaterialPageRoute(builder: (context) => (SummaryPurchase(widget.item, DateTime.now(), DateTime.now(), 0, widget.item.buyPrice, 'booked', symbol))));
                widget.item.status = 'denied';
                Provider.of<ItemStoreProvider>(context, listen: false)
                    .saveItem(widget.item);
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1.0),
                ),
                side: const BorderSide(width: 1.0, color: Colors.black),
              ),
              child: const StyledHeading('DENY'),
            )),
            const SizedBox(width: 5),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  widget.item.status = 'accepted';
                  Provider.of<ItemStoreProvider>(context, listen: false)
                      .saveItem(widget.item);
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(10),
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(1.0),
                  ),
                  side: const BorderSide(width: 1.0, color: Colors.black),
                ),
                child: const StyledHeading('ACCEPT', color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

showAlertDialog(BuildContext context) {
  // Create button
  double width = MediaQuery.of(context).size.width;

  Widget okButton = ElevatedButton(
    style: OutlinedButton.styleFrom(
      textStyle: const TextStyle(color: Colors.white),
      foregroundColor: Colors.white, //change background color of button
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0.0),
      ),
      side: const BorderSide(width: 1.0, color: Colors.black),
    ),
    onPressed: () {
      // Navigator.of(context).pop();
      // Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => (const GoogleSignInScreen())));
    },
    child: const Center(child: StyledHeading("OK", color: Colors.white)),
  );
  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white,
    title: const Center(child: Text("NOT LOGGED IN")),
    content: SizedBox(
      height: width * 0.2,
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("Please log in"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("or register to continue"),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StyledHeading("to rent a dress"),
            ],
          ),
        ],
      ),
    ),
    actions: [
      okButton,
    ],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(0.0)),
    ),
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
