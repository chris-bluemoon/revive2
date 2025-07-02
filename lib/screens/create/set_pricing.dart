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
  final String? dailyPrice;
  final String? rentPrice3;
  final String? rentPrice5;
  final String? rentPrice7;
  final String? rentPrice14;
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
    this.rentPrice3,
    this.rentPrice5,
    this.rentPrice7,
    this.rentPrice14,
    this.minRentalPeriod,
    required this.hashtags,
    this.id,
  });

  @override
  State<SetPricing> createState() => _SetPricingState();
}

class _SetPricingState extends State<SetPricing> {
  bool _isUploading = false;
  
  // Controllers for the new pricing fields
  final TextEditingController _price7Controller = TextEditingController();
  final TextEditingController _price14Controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    final spp = Provider.of<SetPriceProvider>(context, listen: false);
    
    // Check if this is a new item creation (no existing data) - clear all fields
    bool isNewItem = widget.dailyPrice == null && 
                     widget.rentPrice3 == null && 
                     widget.rentPrice5 == null && 
                     widget.rentPrice7 == null && 
                     widget.rentPrice14 == null && 
                     widget.minRentalPeriod == null;
    
    // Always clear controllers first to ensure clean state for any new item creation
    spp.clearAllFields();
    _price7Controller.clear();
    _price14Controller.clear();
    
    if (!isNewItem) {
      // Only populate if we have existing data (editing mode)
      if (widget.dailyPrice != null) {
        spp.dailyPriceController.text = widget.dailyPrice!;
        int dailyPrice = int.tryParse(widget.dailyPrice!) ?? 0;
        
        // If multi-day prices aren't provided, calculate them with discounts
        if (widget.rentPrice3 != null) {
          spp.weeklyPriceController.text = widget.rentPrice3!;
        } else if (dailyPrice > 0) {
          // Calculate 3-day price with 5% discount
          spp.weeklyPriceController.text = ((dailyPrice * 3 * 0.95).floor()).toString();
        }
        
        if (widget.rentPrice5 != null) {
          spp.monthlyPriceController.text = widget.rentPrice5!;
        } else if (dailyPrice > 0) {
          // Calculate 5-day price with 10% discount
          spp.monthlyPriceController.text = ((dailyPrice * 5 * 0.90).floor()).toString();
        }
        
        if (widget.rentPrice7 != null) {
          _price7Controller.text = widget.rentPrice7!;
        } else if (dailyPrice > 0) {
          // Calculate 7-day price with 15% discount
          _price7Controller.text = ((dailyPrice * 7 * 0.85).floor()).toString();
        }
        
        if (widget.rentPrice14 != null) {
          _price14Controller.text = widget.rentPrice14!;
        } else if (dailyPrice > 0) {
          // Calculate 14-day price with 20% discount
          _price14Controller.text = ((dailyPrice * 14 * 0.80).floor()).toString();
        }
      } else {
        // If no daily price, just populate existing values
        if (widget.rentPrice3 != null) {
          spp.weeklyPriceController.text = widget.rentPrice3!;
        }
        if (widget.rentPrice5 != null) {
          spp.monthlyPriceController.text = widget.rentPrice5!;
        }
        if (widget.rentPrice7 != null) {
          _price7Controller.text = widget.rentPrice7!;
        }
        if (widget.rentPrice14 != null) {
          _price14Controller.text = widget.rentPrice14!;
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
                title: const StyledTitle(
                  'SET PRICING',
                ),
                leading: IconButton(
                  icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
                  onPressed: () {
                    // Clear all fields before navigating back
                    spp.clearAllFields();
                    // Clear local controllers too
                    _price7Controller.clear();
                    _price14Controller.clear();
                    
                    // Also clear CreateItemProvider to ensure CreateItem form is reset
                    final cip = Provider.of<CreateItemProvider>(context, listen: false);
                    cip.reset();
                    
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
                            // When daily price changes, update multi-day prices with discounts
                            // BUT only if they haven't been manually set by the user
                            if (text.isNotEmpty) {
                              int dailyPrice = int.tryParse(text) ?? 0;
                              
                              if (dailyPrice > 0) {
                                // Only auto-calculate prices that haven't been manually set
                                if (!spp.weeklyPriceManuallySet) {
                                  spp.weeklyPriceController.text = ((dailyPrice * 3 * 0.95).floor()).toString();
                                }
                                if (!spp.monthlyPriceManuallySet) {
                                  spp.monthlyPriceController.text = ((dailyPrice * 5 * 0.90).floor()).toString();
                                }
                                if (!spp.price7ManuallySet) {
                                  _price7Controller.text = ((dailyPrice * 7 * 0.85).floor()).toString();
                                }
                                if (!spp.price14ManuallySet) {
                                  _price14Controller.text = ((dailyPrice * 14 * 0.80).floor()).toString();
                                }
                              }
                            } else {
                              // If daily price is cleared, clear all multi-day prices
                              // But reset the manual flags since we're clearing everything
                              spp.weeklyPriceController.clear();
                              spp.monthlyPriceController.clear();
                              _price7Controller.clear();
                              _price14Controller.clear();
                              // Reset manual flags when daily price is cleared
                              spp.resetManualFlags();
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
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        const StyledBody('3 Day Price'),
                        const StyledBody(
                            'In order to facilitate longer rentals such as holidays, we recommend offering multi-day rental prices',
                            weight: FontWeight.normal),
                        SizedBox(height: width * 0.03),
                        TextField(
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 6,
                          controller: spp.weeklyPriceController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (text) {
                            // Mark as manually set when user edits this field
                            spp.markWeeklyPriceAsManual();
                            
                            // Validate that 3-day price provides a discount (lower per-day rate)
                            if (text.isNotEmpty && spp.dailyPriceController.text.isNotEmpty) {
                              int dailyPrice = int.tryParse(spp.dailyPriceController.text) ?? 0;
                              int price3Day = int.tryParse(text) ?? 0;
                              double pricePerDay = price3Day / 3.0;
                              if (pricePerDay >= dailyPrice) {
                                // Set to 95% of daily price * 3 to ensure discount
                                int discountedPrice = ((dailyPrice * 3 * 0.95).floor());
                                spp.weeklyPriceController.text = discountedPrice.toString();
                                spp.weeklyPriceController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: spp.weeklyPriceController.text.length),
                                );
                              }
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
                            hintText: (() {
                              // Remove any currency symbol and commas, then parse
                              String priceStr = widget.retailPrice.replaceAll(RegExp(r'[^\d.]'), '');
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
                        const StyledBody('5 Day Price'),
                        SizedBox(height: width * 0.03),
                        TextField(
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 6,
                          controller: spp.monthlyPriceController,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (text) {
                            // Mark as manually set when user edits this field
                            spp.markMonthlyPriceAsManual();
                            
                            // Validate that 5-day price provides a discount (lower per-day rate)
                            if (text.isNotEmpty && spp.dailyPriceController.text.isNotEmpty) {
                              int dailyPrice = int.tryParse(spp.dailyPriceController.text) ?? 0;
                              int price5Day = int.tryParse(text) ?? 0;
                              double pricePerDay = price5Day / 5.0;
                              if (pricePerDay >= dailyPrice) {
                                // Set to 90% of daily price * 5 to ensure discount
                                int discountedPrice = ((dailyPrice * 5 * 0.90).floor());
                                spp.monthlyPriceController.text = discountedPrice.toString();
                                spp.monthlyPriceController.selection = TextSelection.fromPosition(
                                  TextPosition(offset: spp.monthlyPriceController.text.length),
                                );
                              }
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
                            hintText: (() {
                              // Remove any currency symbol and commas, then parse
                              String priceStr = widget.retailPrice.replaceAll(RegExp(r'[^\d.]'), '');
                              int retail = int.tryParse(priceStr) ?? 0;
                              if (retail == 0) return "5 Day Price";
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
                        const StyledBody('7 Day Price'),
                        SizedBox(height: width * 0.03),
                        TextField(
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 6,
                          controller: _price7Controller,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (text) {
                            // Mark as manually set when user edits this field
                            final spp = Provider.of<SetPriceProvider>(context, listen: false);
                            spp.markPrice7AsManual();
                            
                            // Validate that 7-day price provides a discount (lower per-day rate)
                            if (text.isNotEmpty) {
                              if (spp.dailyPriceController.text.isNotEmpty) {
                                int dailyPrice = int.tryParse(spp.dailyPriceController.text) ?? 0;
                                int price7Day = int.tryParse(text) ?? 0;
                                double pricePerDay = price7Day / 7.0;
                                if (pricePerDay >= dailyPrice) {
                                  // Set to 85% of daily price * 7 to ensure discount
                                  int discountedPrice = ((dailyPrice * 7 * 0.85).floor());
                                  _price7Controller.text = discountedPrice.toString();
                                  _price7Controller.selection = TextSelection.fromPosition(
                                    TextPosition(offset: _price7Controller.text.length),
                                  );
                                }
                              }
                            }
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
                              if (retail == 0) return "7 Day Price (Optional)";
                              // Calculate suggested price: retail/1.8, rounded up to nearest 10
                              int suggested = (retail / 1.8).ceil();
                              if (suggested % 10 != 0) {
                                suggested = ((suggested / 10).ceil()) * 10;
                              }
                              return "e.g. $suggested";
                            })(),
                            fillColor: Colors.white70,
                          ),
                        ),
                        const StyledBody('14 Day Price'),
                        SizedBox(height: width * 0.03),
                        TextField(
                          keyboardType: TextInputType.number,
                          maxLines: null,
                          maxLength: 6,
                          controller: _price14Controller,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                          onChanged: (text) {
                            // Mark as manually set when user edits this field
                            final spp = Provider.of<SetPriceProvider>(context, listen: false);
                            spp.markPrice14AsManual();
                            
                            // Validate that 14-day price provides a discount (lower per-day rate)
                            if (text.isNotEmpty) {
                              if (spp.dailyPriceController.text.isNotEmpty) {
                                int dailyPrice = int.tryParse(spp.dailyPriceController.text) ?? 0;
                                int price14Day = int.tryParse(text) ?? 0;
                                double pricePerDay = price14Day / 14.0;
                                if (pricePerDay >= dailyPrice) {
                                  // Set to 80% of daily price * 14 to ensure discount
                                  int discountedPrice = ((dailyPrice * 14 * 0.80).floor());
                                  _price14Controller.text = discountedPrice.toString();
                                  _price14Controller.selection = TextSelection.fromPosition(
                                    TextPosition(offset: _price14Controller.text.length),
                                  );
                                }
                              }
                            }
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
                              if (retail == 0) return "14 Day Price (Optional)";
                              // Calculate suggested price: retail/1.5, rounded up to nearest 10
                              int suggested = (retail / 1.5).ceil();
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
                            'Tip: The most common minimum rental period is 4 days (max 30 days)',
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
      id: widget.dailyPrice != null && widget.rentPrice3 != null && widget.rentPrice5 != null && widget.minRentalPeriod != null && widget.title.isNotEmpty
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
      rentPrice3: int.parse(spp.weeklyPriceController.text),
      rentPrice5: int.parse(spp.monthlyPriceController.text),
      rentPrice7: _price7Controller.text.isNotEmpty ? int.parse(_price7Controller.text) : 0,
      rentPrice14: _price14Controller.text.isNotEmpty ? int.parse(_price14Controller.text) : 0,
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
    if (widget.dailyPrice != null && widget.rentPrice3 != null && widget.rentPrice5 != null && widget.minRentalPeriod != null && widget.title.isNotEmpty && (widget as dynamic).id != null) {
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
