import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/providers/set_price_provider.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class SetPricing extends StatefulWidget {
  final String productType;
  final String brand;
  final String title;
  final String colour;
  final String retailPrice;
  final String shortDesc;
  final String longDesc;
  final String size;
  final List<String> existingImagePaths;
  final List<XFile> imageFiles;
  final String? dailyPrice;
  final String? weeklyPrice;
  final String? monthlyPrice;
  final String? minRentalPeriod;
  final List<String> hashtags;
  final String? id;

  const SetPricing({
    super.key,
    required this.productType,
    required this.brand,
    required this.title,
    required this.colour,
    required this.retailPrice,
    required this.shortDesc,
    required this.longDesc,
    required this.size,
    required this.existingImagePaths,
    required this.imageFiles,
    this.dailyPrice,
    this.weeklyPrice,
    this.monthlyPrice,
    this.minRentalPeriod,
    required this.hashtags,
    this.id,
  });

  @override
  State<SetPricing> createState() => _SetPricingState();
}

class _SetPricingState extends State<SetPricing> {
  bool _isUploading = false; // Add this line

  @override
  void initState() {
    super.initState();
    final spp = Provider.of<SetPriceProvider>(context, listen: false);
    if (widget.dailyPrice != null) {
      spp.dailyPriceController.text = widget.dailyPrice!;
    }
    if (widget.weeklyPrice != null) {
      spp.weeklyPriceController.text = widget.weeklyPrice!;
    }
    if (widget.monthlyPrice != null) {
      spp.monthlyPriceController.text = widget.monthlyPrice!;
    }
    if (widget.minRentalPeriod != null) {
      spp.minimalRentalPeriodController.text = widget.minRentalPeriod!;
    }
    // Ensure form completeness is checked after pre-population
    WidgetsBinding.instance.addPostFrameCallback((_) {
      spp.checkFormComplete();
    });
    // Combine existing image paths and new image files
    imagePaths = List<String>.from(widget.existingImagePaths);
  }

  List<String> imagePaths = [];

  bool postageSwitch = false;

  bool formComplete = false;

  FirebaseStorage storage = FirebaseStorage.instance;
  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    log('Image files length: ${widget.imageFiles.length}');
    return Consumer<SetPriceProvider>(
      builder: (context, SetPriceProvider spp, child) {
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                toolbarHeight: width * 0.2,
                centerTitle: true,
                title: const StyledTitle('SET PRICING'),
                leading: IconButton(
                  icon: Icon(Icons.chevron_left, size: width * 0.08),
                  onPressed: () {
                    // Clear all fields in SetPriceProvider before navigating back
                    spp.dailyPriceController.clear();
                    spp.weeklyPriceController.clear();
                    spp.monthlyPriceController.clear();
                    spp.minimalRentalPeriodController.clear();
                    spp.checkFormComplete();
                    Navigator.pop(context);
                  },
                ),
              ),
              body: GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: width * 0.02),
                        const StyledBody(
                            'Based on our price analytics we have provided you with optimal pricing to maximise rentals',
                            weight: FontWeight.normal),
                        SizedBox(height: width * 0.05),
                        const StyledBody('Daily Price'),
                        const StyledBody('Please provide a price per day for the item',
                            weight: FontWeight.normal),
                        SizedBox(height: width * 0.03),
                        TextField(
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 5,
                          controller: spp.dailyPriceController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (text) {
                            spp.checkFormComplete();
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Colors.black)),
                            filled: true,
                            hintStyle: TextStyle(color: Colors.grey[800], fontSize: width * 0.03),
                            hintText: (() {
                              // Remove any currency symbol and commas, then parse
                              String priceStr = widget.retailPrice.replaceAll(RegExp(r'[^\d.]'), '');
                              int retail = int.tryParse(priceStr) ?? 0;
                              if (retail == 0) return "Daily Price";
                              // Calculate suggested price: retail/25, rounded up to nearest 10
                              int suggested = ((retail / 25).ceil());
                              // Round up to nearest 10
                              if (suggested % 10 != 0) {
                                suggested = ((suggested / 10).ceil()) * 10;
                              }
                              return "e.g. $suggested";
                            })(),
                            fillColor: Colors.white70,
                          ),
                        ),
                        const StyledBody('Weekly Price'),
                        const StyledBody(
                            'In order to facilitate longer rentals such as holidays, we recommend offering weekly and/or monthly rental prices',
                            weight: FontWeight.normal),
                        SizedBox(height: width * 0.03),
                        TextField(
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 6,
                          controller: spp.weeklyPriceController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (text) {
                            // checkContents(text);
                            spp.checkFormComplete();
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Colors.black)),
                            filled: true,
                            hintStyle: TextStyle(color: Colors.grey[800], fontSize: width * 0.03),
                            hintText: (() {
                              // Remove any currency symbol and commas, then parse
                              String priceStr = widget.retailPrice.replaceAll(RegExp(r'[^\d.]'), '');
                              int retail = int.tryParse(priceStr) ?? 0;
                              if (retail == 0) return "Weekly Price";
                              // Calculate suggested price: retail/6, rounded up to nearest 10
                              int suggested = ((retail / 6).ceil());
                              if (suggested % 10 != 0) {
                                suggested = ((suggested / 10).ceil()) * 10;
                              }
                              return "e.g. $suggested";
                            })(),
                            fillColor: Colors.white70,
                          ),
                        ),
                        const StyledBody('Monthly Price'),
                        SizedBox(height: width * 0.03),
                        TextField(
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 6,
                          controller: spp.monthlyPriceController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (text) {
                            // checkContents(text);
                            spp.checkFormComplete();
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Colors.black)),
                            filled: true,
                            hintStyle: TextStyle(color: Colors.grey[800], fontSize: width * 0.03),
                            hintText: (() {
                              // Remove any currency symbol and commas, then parse
                              String priceStr = widget.retailPrice.replaceAll(RegExp(r'[^\d.]'), '');
                              int retail = int.tryParse(priceStr) ?? 0;
                              if (retail == 0) return "Monthly Price";
                              // Calculate suggested price: retail/2.2, rounded up to nearest 10
                              int suggested = (retail / 2.2).ceil();
                              if (suggested % 10 != 0) {
                                suggested = ((suggested / 10).ceil()) * 10;
                              }
                              return "e.g. $suggested";
                            })(),
                            fillColor: Colors.white70,
                          ),
                        ),
                        const StyledBody('Minimal Rental Period'),
                        const StyledBody(
                            'Tip: The most common minimum rental period is 4 days',
                            weight: FontWeight.normal),
                        SizedBox(height: width * 0.03),
                        TextField(
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 3,
                          controller: spp.minimalRentalPeriodController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (text) {
                            // Only allow minDays between 1 and 30
                            if (text.isNotEmpty) {
                              int value = int.tryParse(text) ?? 1;
                              if (value > 30) {
                                spp.minimalRentalPeriodController.text = '30';
                              } else if (value < 1) {
                                spp.minimalRentalPeriodController.text = '1';
                              }
                              spp.minimalRentalPeriodController.selection = TextSelection.fromPosition(
                                TextPosition(offset: spp.minimalRentalPeriodController.text.length),
                              );
                            }
                            spp.checkFormComplete();
                          },
                          decoration: InputDecoration(
                            isDense: true,
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: const BorderSide(color: Colors.black)),
                            filled: true,
                            hintStyle: TextStyle(color: Colors.grey[800], fontSize: width * 0.03),
                            hintText: 'Minimal Rental Period (days)',
                            fillColor: Colors.white70,
                          ),
                        ),
                        // const StyledBody('Postage Option'),
                        // const StyledBody(
                        //     'You can offer the option of local country tracked mail by charging a flat rate for this. The item should be received on the day the rental period begins at the very latest. The renter is in charge of sending back the item to you and icurring the fee',
                        //     weight: FontWeight.normal),
                        // SizedBox(height: width * 0.03),
                        // Row(
                        //   children: [
                        //     const StyledBody('Allow Postage Option'),
                        //     const Expanded(child: SizedBox()),
                        //     Switch(
                        //         value: postageSwitch,
                        //         onChanged: (value) {
                        //           setState(() {
                        //             postageSwitch = value;
                        //           });
                        //         }),
                        //   ],
                        // ),
                        SizedBox(height: width * 0.03),
                      ],
                    ),
                  ),
                ),
              ),
              bottomNavigationBar: Container(
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
                child: OutlinedButton(
                  onPressed: spp.isCompleteForm
                      ? () async {
                          setState(() {
                            _isUploading = true;
                          });
                          await handleSubmit();
                          setState(() {
                            _isUploading = false;
                          });
                          // Do not pop here! Navigation is handled in the dialog.
                        }
                      : null,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: spp.isCompleteForm ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                    side: const BorderSide(width: 1.0, color: Colors.black),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: StyledHeading('SUBMIT',
                        color: spp.isCompleteForm ? Colors.white : Colors.grey),
                  ),
                ),
              ),
            ),
            if (_isUploading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> uploadFile(XFile passedFile) async {
    String id =
        Provider.of<ItemStoreProvider>(context, listen: false).renter.id;
    String rng = uuid.v4();
    Reference ref = storage.ref().child('items').child(id).child('$rng.png');

    File file = File(passedFile.path);
    UploadTask uploadTask = ref.putFile(file);

    try {
      if (!file.existsSync()) {
        log('File does not exist: ${file.path}');
        return;
      }
      log('File exists: ${file.existsSync()} at ${file.path}');
      log('Uploading file at path: ${file.path}');
      await uploadTask; // Wait for upload to complete
      imagePaths.add(ref.fullPath.toString());
      log('uploadTask has completed');
    } catch (e) {
      log('Upload failed: $e');
    }
  }

  handleSubmit() async {
    String ownerId =
        Provider.of<ItemStoreProvider>(context, listen: false).renter.id;
    log('OwnerId when submitting: $ownerId');
    SetPriceProvider spp =
        Provider.of<SetPriceProvider>(context, listen: false);
    // Only upload new images
    for (XFile passedFile in widget.imageFiles) {
      await uploadFile(passedFile); // This adds to imagePaths
    }

    final item = Item(
      id: widget.dailyPrice != null && widget.weeklyPrice != null && widget.monthlyPrice != null && widget.minRentalPeriod != null && widget.title.isNotEmpty
          ? (widget as dynamic).id ?? uuid.v4() // Use existing id if editing, else new
          : uuid.v4(),
      owner: ownerId,
      type: widget.productType,
      bookingType: 'rental',
      dateAdded: DateTime.now().toIso8601String(),
      name: widget.title,
      brand: widget.brand,
      colour: widget.colour,
      size: widget.size,
      rentPriceDaily: int.parse(spp.dailyPriceController.text),
      rentPriceWeekly: int.parse(spp.weeklyPriceController.text),
      rentPriceMonthly: int.parse(spp.monthlyPriceController.text),
      buyPrice: 0,
      rrp: int.tryParse(widget.retailPrice.replaceAll(RegExp(r'[^\d]'), '')) ?? 0,
      description: widget.shortDesc,
      longDescription: widget.longDesc,
      imageId: imagePaths, // This now includes both old and new images
      status: 'submitted',
      minDays: int.tryParse(spp.minimalRentalPeriodController.text) ?? 1,
      hashtags: widget.hashtags,
    );

    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);

    // If editing, call updateItem, else addItem
    if (widget.dailyPrice != null && widget.weeklyPrice != null && widget.monthlyPrice != null && widget.minRentalPeriod != null && widget.title.isNotEmpty && (widget as dynamic).id != null) {
      itemStore.updateItem(item);
    } else {
      itemStore.addItem(item);
    }

    // Show thank you alert
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0), // Square corners
        ),
        backgroundColor: Colors.white,
        titlePadding: const EdgeInsets.only(top: 32, left: 24, right: 24, bottom: 0),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        actionsPadding: const EdgeInsets.only(bottom: 16),
        title: const Text(
          "Thank You!",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold, // Make bold
            fontSize: 22,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
        content: const Text(
          "You're item has been sent for verification by our team.",
          style: TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.normal,
          ),
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: 120,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.black, // Black background
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(0),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 0.5,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pushReplacementNamed('/'); // Go to home/root
              },
              child: const Text(
                "OK",
                style: TextStyle(
                  color: Colors.white, // White text
                  fontWeight: FontWeight.bold, // Bold
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
