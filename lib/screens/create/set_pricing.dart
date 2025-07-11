import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/providers/create_item_provider.dart';
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
  final String? rentPrice1;
  final String? rentPrice2;
  final String? rentPrice3;
  final String? rentPrice4;
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
    this.rentPrice1,
    this.rentPrice2,
    this.rentPrice3,
    this.rentPrice4,
    this.minRentalPeriod,
    required this.hashtags,
    this.id,
  });

  @override
  State<SetPricing> createState() => _SetPricingState();
}

class _SetPricingState extends State<SetPricing> {
  bool _isUploading = false;
  final TextEditingController _price7Controller = TextEditingController();
  final TextEditingController _price14Controller = TextEditingController();

  int? _selectedMinDays; // Track selected minimum days

  @override
  void initState() {
    super.initState();
    final spp = Provider.of<SetPriceProvider>(context, listen: false);
    // Check if this is a new item creation (no existing data) - clear all fields
    bool isNewItem = widget.rentPrice1 == null && 
                     widget.rentPrice2 == null && 
                     widget.rentPrice3 == null && 
                     widget.rentPrice4 == null && 
                     widget.minRentalPeriod == null;
    // Always clear controllers first to ensure clean state for any new item creation
    spp.clearAllFields(deferNotifyListeners: true); // <-- FIXED HERE
    _price7Controller.clear();
    _price14Controller.clear();
    
    if (!isNewItem) {
      // Only populate if we have existing data (editing mode)
      if (widget.rentPrice1 != null) {
        spp.dailyPriceController.text = widget.rentPrice1!;
        int dailyPrice = int.tryParse(widget.rentPrice1!) ?? 0;
        if (widget.rentPrice2 != null) {
          spp.price3Controller.text = widget.rentPrice2!;
        } else if (dailyPrice > 0) {
          spp.price3Controller.text = ((dailyPrice * 1.2).floor()).toString();
        }
        if (widget.rentPrice3 != null) {
          spp.price5Controller.text = widget.rentPrice3!;
        } else if (dailyPrice > 0) {
          spp.price5Controller.text = ((dailyPrice * 1.4).floor()).toString();
        }
        if (widget.rentPrice4 != null) {
          _price7Controller.text = widget.rentPrice4!;
        } else if (dailyPrice > 0) {
          _price7Controller.text = ((dailyPrice * 1.7).floor()).toString();
        }
      } else {
        if (widget.rentPrice2 != null) {
          spp.price3Controller.text = widget.rentPrice2!;
        }
        if (widget.rentPrice3 != null) {
          spp.price5Controller.text = widget.rentPrice3!;
        }
        if (widget.rentPrice4 != null) {
          _price7Controller.text = widget.rentPrice4!;
        }
      }
      if (widget.minRentalPeriod != null) {
        spp.minimalRentalPeriodController.text = widget.minRentalPeriod!;
      }
    }
    
    // Ensure form completeness is checked after initialization
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
              backgroundColor: Colors.grey[50],
              appBar: AppBar(
                backgroundColor: Colors.white,
                elevation: 0,
                toolbarHeight: width * 0.2,
                centerTitle: true,
                title: const StyledTitle('SET PRICING'),
                leading: IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
                  onPressed: () {
                    // Do NOT clear fields when popping back
                    // spp.clearAllFields();
                    // final cip = Provider.of<CreateItemProvider>(context, listen: false);
                    // cip.reset();
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
                        SizedBox(height: width * 0.05),
                        const StyledBody('First, select the minimum of days you are willing to rent'),
                        SizedBox(height: width * 0.03),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(5, (i) {
                            int day = i + 1;
                            bool isSelected = _selectedMinDays == day;
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ChoiceChip(
                                label: Text(
                                  day.toString(),
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: width * 0.045,
                                  ),
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedMinDays = day;
                                    spp.minimalRentalPeriodController.text = day.toString();
                                  });
                                },
                                selectedColor: Colors.black,
                                backgroundColor: Colors.white,
                                avatar: isSelected ? Icon(Icons.check, color: Colors.white, size: width * 0.045) : null,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: isSelected ? Colors.black : Colors.grey[300]!,
                                    width: 2,
                                  ),
                                ),
                              ),
                            );
                          }),
                        ),
                        SizedBox(height: width * 0.05),
                        if (_selectedMinDays != null) ...[
                          const StyledBody('Based on our price analytics we have provided you with optimal pricing to maximise rentals', weight: FontWeight.normal),
                          SizedBox(height: width * 0.05),
                          // Show X Day Price for selected min days
                          StyledBody('${_selectedMinDays} Day Price'),
                          StyledBody('Please provide a price for ${_selectedMinDays} days', weight: FontWeight.normal),
                          SizedBox(height: width * 0.03),
                          TextField(
                            keyboardType: TextInputType.number,
                            maxLines: null,
                            maxLength: 5,
                            controller: spp.dailyPriceController,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (text) {
                              // When min day price changes, update multi-day prices
                              if (text.isEmpty) {
                                spp.price3Controller.clear();
                                spp.price5Controller.clear();
                                _price7Controller.clear();
                                spp.price14Controller.clear();
                                spp.resetManualFlags();
                                spp.checkFormComplete();
                                return;
                              }
                              int minDayPrice = int.tryParse(text) ?? 0;
                              // No enforcement here; allow user to delete freely
                              if (minDayPrice > 0) {
                                // 3 Day Price: minDayPrice * 1.2
                                if (!spp.price3ManuallySet) {
                                  spp.price3Controller.text = (minDayPrice * 1.2).floor().toString();
                                }
                                // 5 Day Price: minDayPrice * 1.4
                                if (!spp.price5ManuallySet) {
                                  spp.price5Controller.text = (minDayPrice * 1.4).floor().toString();
                                }
                                // 14 Day Price: double the previous day price (5-day or 3-day)
                                if (!spp.price14ManuallySet) {
                                  int prevDayPrice = 0;
                                  if (spp.price5Controller.text.isNotEmpty) {
                                    prevDayPrice = int.tryParse(spp.price5Controller.text) ?? 0;
                                  } else if (spp.price3Controller.text.isNotEmpty) {
                                    prevDayPrice = int.tryParse(spp.price3Controller.text) ?? 0;
                                  }
                                  spp.price14Controller.text = (prevDayPrice * 2).toString();
                                  spp.price14Controller.selection = TextSelection.fromPosition(
                                    TextPosition(offset: spp.price14Controller.text.length),
                                  );
                                }
                              }
                              spp.checkFormComplete();
                            },
                            decoration: InputDecoration(
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: Colors.black, width: 2),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey[300]!),
                              ),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                              hintText: (() {
                                // Remove any currency symbol and commas, then parse
                                String priceStr = widget.retailPrice.replaceAll(RegExp(r'[^ -\u007F]+'), '');
                                int retail = int.tryParse(priceStr) ?? 0;
                                if (retail == 0) return "1 Day Price"; // Changed hint from 'Daily Price' to '1 Day Price'
                                // Calculate suggested price: retail/25, rounded up to nearest 10
                                int suggested = ((retail / 25).ceil());
                                // Round up to nearest 10
                                if (suggested % 10 != 0) {
                                  suggested = ((suggested / 10).ceil()) * 10;
                                }
                                return "e.g. $suggested";
                              })(),
                              filled: true,
                              fillColor: Colors.white,
                            ),
                          ),
                          // Show subsequent price fields for min+2 and min+4 days
                          ...[2, 4].map((addDays) {
                            int labelDay = (_selectedMinDays ?? 1) + addDays;
                            TextEditingController controller;
                            String label;
                            VoidCallback markManual;
                            if (addDays == 2) {
                              controller = spp.price3Controller;
                              label = '${labelDay} Day Price';
                              markManual = spp.markWeeklyPriceAsManual;
                            } else {
                              controller = spp.price5Controller;
                              label = '${labelDay} Day Price';
                              markManual = spp.markMonthlyPriceAsManual;
                            }
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StyledBody(label),
                                SizedBox(height: width * 0.03),
                                TextField(
                                  keyboardType: TextInputType.number,
                                  maxLines: null,
                                  maxLength: 6,
                                  controller: controller,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (text) {
                                    // Mark as manually set when user edits this field
                                    markManual();
                                    // Remove auto-correction: manual edits should always be respected
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
                                      String priceStr = widget.retailPrice.replaceAll(RegExp(r'[^ -\u007F]+'), '');
                                      int retail = int.tryParse(priceStr) ?? 0;
                                      if (retail == 0) return "3 Day Price";
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
                              ],
                            );
                          }),
                          // Always show 14 Day Price
                          StyledBody('14 Day Price'),
                          SizedBox(height: width * 0.03),
                          TextField(
                            keyboardType: TextInputType.number,
                            maxLines: null,
                            maxLength: 6,
                            controller: spp.price14Controller,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (text) {
                              // Mark as manually set when user edits this field
                              spp.markPrice14AsManual();
                              if (text.isEmpty) {
                                spp.price14Controller.clear();
                                spp.checkFormComplete();
                                return;
                              }
                              // Remove auto-correction: manual edits should always be respected
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
                                String priceStr = widget.retailPrice.replaceAll(RegExp(r'[^ -\u007F]+'), '');
                                int retail = int.tryParse(priceStr) ?? 0;
                                if (retail == 0) return "14 Day Price";
                                // Calculate suggested price: retail/10, rounded up to nearest 10
                                int suggested = ((retail / 10).ceil());
                                if (suggested % 10 != 0) {
                                  suggested = ((suggested / 10).ceil()) * 10;
                                }
                                return "e.g. $suggested";
                              })(),
                              fillColor: Colors.white70,
                            ),
                          ),
                        ],
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
                child: ElevatedButton(
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
                  style: ElevatedButton.styleFrom(
                    backgroundColor: spp.isCompleteForm ? Colors.black : Colors.grey[300],
                    foregroundColor: spp.isCompleteForm ? Colors.white : Colors.grey[500],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'SUBMIT',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: spp.isCompleteForm ? Colors.white : Colors.grey[500],
                      ),
                    ),
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

  Future<void> uploadFile(XFile passedFile, String itemId) async {
    String id =
        Provider.of<ItemStoreProvider>(context, listen: false).renter.id;
    String rng = uuid.v4();
    // Add a directory after 'items' as the id of the user
    Reference ref = storage.ref().child('items').child(id).child(itemId).child('$rng.png');

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
    String newItemId = uuid.v4(); // Generate a new ID for the item if not editing
    for (XFile passedFile in widget.imageFiles) {
      await uploadFile(passedFile, newItemId); // This adds to imagePaths
      log('Image uploaded: ${passedFile.path}');
    }

    final item = Item(
      id: widget.rentPrice1 != null && widget.rentPrice2 != null && widget.rentPrice3 != null && widget.minRentalPeriod != null && widget.title.isNotEmpty
          ? (widget as dynamic).id ?? newItemId // Use existing id if editing, else new
          : newItemId,
      owner: ownerId,
      type: widget.productType,
      bookingType: 'rental',
      dateAdded: DateTime.now().toIso8601String(),
      name: widget.title,
      brand: widget.brand,
      colour: widget.colour,
      size: widget.size,
      rentPrice1: int.parse(spp.dailyPriceController.text),
      rentPrice2: int.parse(spp.price3Controller.text),
      rentPrice3: int.parse(spp.price5Controller.text),
      rentPrice4: _price7Controller.text.isNotEmpty ? int.parse(_price7Controller.text) : 0,
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
    if (widget.rentPrice1 != null && widget.rentPrice2 != null && widget.rentPrice3 != null && widget.minRentalPeriod != null && widget.title.isNotEmpty && (widget as dynamic).id != null) {
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
          borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(12),
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
                
                // Clear both providers to ensure next item creation is clean
                final spp = Provider.of<SetPriceProvider>(context, listen: false);
                spp.clearAllFields();
                final cip = Provider.of<CreateItemProvider>(context, listen: false);
                cip.reset();
                
                Navigator.of(context).pushReplacementNamed('/home'); // Go to home/root
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
