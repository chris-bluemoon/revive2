import 'dart:developer';
import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_image.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/providers/create_item_provider.dart';
import 'package:revivals/screens/create/set_pricing.dart';
import 'package:revivals/screens/to_rent/view_image.dart';
import 'package:revivals/shared/item_types.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class CreateItem extends StatefulWidget {
  const CreateItem({required this.item, super.key});

  final Item? item;

  // final item;

  @override
  State<CreateItem> createState() => _CreateItemState();
}

class _CreateItemState extends State<CreateItem> {
  bool _initialized = false;

  late final bool isEditItemActive;

  @override
  void initState() {
    super.initState();
    isEditItemActive = widget.item != null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized && widget.item != null) {
      final cip = Provider.of<CreateItemProvider>(context, listen: false);
      cip.sizeValue = (widget.item!.size.isNotEmpty) ? widget.item!.size[0].toString() : '';
      cip.productTypeValue = widget.item!.type;
      cip.colourValue = widget.item!.colour[0];
      cip.brandValue = widget.item!.brand;
      cip.retailPriceValue = widget.item!.rrp.toString();
      cip.retailPriceController.text = widget.item!.rrp.toString();
      cip.shortDescController.text = widget.item!.description.toString();
      cip.longDescController.text = widget.item!.longDescription.toString();
      cip.titleController.text = widget.item!.name.toString();
      cip.images.clear();
      for (ItemImage i in Provider.of<ItemStoreProvider>(context, listen: false).images) {
        for (String itemImageString in widget.item!.imageId) {
          if (i.id == itemImageString) {
            cip.images.add(i.imageId);
          }
        }
      }
      _initialized = true;
      // Schedule checkFormComplete after build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        cip.checkFormComplete();
      });
    }
  }

  late Image thisImage;

  // List<String> productTypes = ['Dress', 'Bag', 'Jacket', 'Coat','Trouser', 'Top', 'Skirt', 'Shorts', 'Trousers', 'Jumpsuit', 'Shoes', 'Hat','Accessory','Suit'];
  // List<String> productTypes = ['Dress', 'Bag', 'Jacket', 'Coat','Trouser', 'Top', 'Skirt', 'Shorts', 'Trousers', 'Jumpsuit', 'Shoes', 'Accessories'];
  final List<String> productTypes = itemTypes.map((e) => e['label'] as String).toList();
  List<String> colours = [
    'Black',
    'White',
    'Blue',
    'Red',
    'Green',
    'Yellow',
    'Grey',
    'Brown',
    'Purple',
    'Pink',
    'Cyan',
  ];

  // String productTypeValue = '';
  // String colourValue = '';
  // String brandValue = '';
  // String retailPriceValue = '';

  List<String> brands = [
    'BARDOT',
    'HOUSE OF CB',
    'LEXI',
    'AJE',
    'ALC',
    'BRONX AND BANCO',
    'ELIYA',
    'NADINE MERABI',
    'REFORMATION',
    'SELKIE',
    'ZIMMERMANN',
    'ROCOCO SAND',
    'BAOBAB'
  ];

  List<String> sizes = [
    '4',
    '6',
    '8',
    '10',
  ];

  List<String> imagePath = [];

  bool readyToSubmit = false;

  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  final List<XFile> _imageFiles = [];
  // final List<XFile> _images = [];
  // final List<Image> _images = [];

  FirebaseStorage storage = FirebaseStorage.instance;

  String number = '';

  final TextEditingController _hashtagsController = TextEditingController();
  List<String> hashtags = [];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    // checkFormComplete();
    return Consumer<CreateItemProvider>(
        builder: (context, CreateItemProvider cip, child) {
              log('Images size: ${cip.images.length}');
      // if (widget.item != null) {
      //   cip.productTypeValue = widget.item!.type;
      //   cip.colourValue = widget.item!.colour[0];
      //   cip.brandValue = widget.item!.brand;
      //   cip.retailPriceValue = widget.item!.rrp.toString();
      //   cip.shortDescController.text = widget.item!.description.toString();
      //   cip.longDescController.text = widget.item!.longDescription.toString();
      //   cip.titleController.text = widget.item!.name.toString();
      //   // for (ItemImage i
      //   //     in Provider.of<ItemStoreProvider>(context, listen: false).images) {
      //   //   for (String itemImageString in widget.item!.imageId) {
      //   //     if (i.id == itemImageString) {
      //   //       cip.images.add(i.imageId);
      //   //       log('Added image: ${i.imageId}');
      //   //     }
      //   //   }
      //   // }
      //         log('Images size: ${cip.images.length}');
      // }

      return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.chevron_left, size: width * 0.08),
              onPressed: () {
                if (isEditItemActive) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.of(context).pushReplacementNamed("/");
                }
              },
            ),
            toolbarHeight: width * 0.2,
            centerTitle: true,
            title: StyledTitle(widget.item != null ? 'EDIT ITEM' : 'LIST ITEM'),
            // leading: IconButton(
            //   icon: Icon(Icons.chevron_left, size: width * 0.08),
            //   onPressed: () {
            //     // Clear all fields before navigating back
            //     cip.productTypeValue = '';
            //     cip.colourValue = '';
            //     cip.brandValue = '';
            //     cip.retailPriceValue = '';
            //     cip.titleController.clear();
            //     cip.shortDescController.clear();
            //     cip.longDescController.clear();
            //     cip.retailPriceController.clear();
            //     cip.images.clear();
            //     _imageFiles.clear();
            //     cip.checkFormComplete();
            //     Navigator.pop(context);
            //   },
            // ),
          ),
          body: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(width * 0.05, 0, width * 0.05, 0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          child: (cip.images.isNotEmpty)
                              ? SizedBox(
                                  width: 80,
                                  child: cip.images[0].startsWith('http')
                                      ? Image.network(cip.images[0])
                                      : Image.file(File(cip.images[0])))
                              : Icon(Icons.image_outlined, size: width * 0.2),
                          onTap: () {
                            if (cip.images.isNotEmpty) {
                              showModal('edit', 1, width);
                            } else {
                              showModal('create', 1, width);
                            }
                            cip.checkFormComplete();
                          },
                        ),
                        SizedBox(width: width * 0.02),
                        GestureDetector(
                          child: (cip.images.length > 1)
                              ? SizedBox(
                                  width: 80,
                                  child: cip.images[1].startsWith('http')
                                      ? Image.network(cip.images[1])
                                      : Image.file(File(cip.images[1])))
                              : Icon(Icons.image_outlined, size: width * 0.2),
                          onTap: () {
                            if (cip.images.length > 1) {
                              showModal('edit', 2, width);
                            } else {
                              showModal('create', 2, width);
                            }
                            cip.checkFormComplete();
                          },
                        ),
                        SizedBox(width: width * 0.02),
                        GestureDetector(
                          child: (cip.images.length > 2)
                              ? SizedBox(
                                  width: 80,
                                  child: cip.images[2].startsWith('http')
                                      ? Image.network(cip.images[2])
                                      : Image.file(File(cip.images[2])))
                              : Icon(Icons.image_outlined, size: width * 0.2),
                          onTap: () {
                            if (cip.images.length > 2) {
                              showModal('edit', 3, width);
                            } else {
                              showModal('create', 3, width);
                            }
                            cip.checkFormComplete();
                          },
                        ),
                        SizedBox(width: width * 0.02),
                        GestureDetector(
                          child: (cip.images.length > 3)
                              ? SizedBox(
                                  width: 80,
                                  child: cip.images[3].startsWith('http')
                                      ? Image.network(cip.images[3])
                                      : Image.file(File(cip.images[3])))
                              : Icon(Icons.image_outlined, size: width * 0.2),
                          onTap: () {
                            if (cip.images.length > 3) {
                              showModal('edit', 4, width);
                            } else {
                              showModal('create', 4, width);
                            }
                            cip.checkFormComplete();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.02),
                    const Divider(),
                    InkWell(
                      onTap: () => showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: 0.9,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(width * 0.03),
                                    child: ListTile(
                                      trailing: Icon(Icons.close,
                                          color: Colors.white,
                                          size: width * 0.04),
                                      leading: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Icon(Icons.close,
                                              color: Colors.black,
                                              size: width * 0.04)),
                                      title: const Center(
                                          child: StyledBody('PRODUCT TYPE')),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            width * 0.05,
                                            width * 0.05,
                                            width * 0.05,
                                            width * 0.05),
                                        child: ListView.separated(
                                            itemCount: productTypes.length,
                                            separatorBuilder: (BuildContext
                                                        context,
                                                    int index) =>
                                                Divider(height: height * 0.05),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    // formComplete = true;
                                                    cip.productTypeValue =
                                                        productTypes[index];
                                                  });
                                                  Navigator.pop(context);
                                                  cip.checkFormComplete();
                                                },
                                                child: SizedBox(
                                                    // height: 50,
                                                    child: StyledBody(
                                                        productTypes[index])),
                                              );
                                            }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      child: SizedBox(
                        height: width * 0.1,
                        child: Row(
                          children: [
                            const StyledBody('Product Type'),
                            const Expanded(child: SizedBox()),
                            StyledBody(cip.productTypeValue),
                            Icon(Icons.chevron_right_outlined, size: width * 0.05)
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    InkWell(
                      onTap: () => showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: 0.9,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(width * 0.03),
                                    child: ListTile(
                                      trailing: Icon(Icons.close,
                                          color: Colors.white,
                                          size: width * 0.04),
                                      leading: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Icon(Icons.close,
                                              color: Colors.black,
                                              size: width * 0.04)),
                                      title: const Center(
                                          child: StyledBody('BRAND')),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            width * 0.05,
                                            width * 0.05,
                                            width * 0.05,
                                            width * 0.05),
                                        child: ListView.separated(
                                            itemCount: brands.length,
                                            separatorBuilder: (BuildContext
                                                        context,
                                                    int index) =>
                                                Divider(height: height * 0.05),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    cip.brandValue =
                                                        brands[index];
                                                  });
                                                  Navigator.pop(context);
                                                  cip.checkFormComplete();
                                                },
                                                child: SizedBox(
                                                    // height: 50,
                                                    child: StyledBody(
                                                        brands[index])),
                                              );
                                            }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      child: SizedBox(
                        height: width * 0.1,
                        child: Row(
                          children: [
                            const StyledBody('Brand'),
                            const Expanded(child: SizedBox()),
                            StyledBody(cip.brandValue),
                            Icon(Icons.chevron_right_outlined, size: width * 0.05)
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    InkWell(
                      onTap: () => showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context,
                          isScrollControlled: true,
                          builder: (context) {
                            return FractionallySizedBox(
                              heightFactor: 0.9,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(width * 0.03),
                                    child: ListTile(
                                      trailing: Icon(Icons.close,
                                          color: Colors.white,
                                          size: width * 0.04),
                                      leading: GestureDetector(
                                          onTap: () {
                                            Navigator.pop(context);
                                          },
                                          child: Icon(Icons.close,
                                              color: Colors.black,
                                              size: width * 0.04)),
                                      title: const Center(
                                          child: StyledBody('COLOURS')),
                                    ),
                                  ),
                                  Expanded(
                                    child: SizedBox(
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            width * 0.05,
                                            width * 0.05,
                                            width * 0.05,
                                            width * 0.05),
                                        child: ListView.separated(
                                            itemCount: colours.length,
                                            separatorBuilder: (BuildContext
                                                        context,
                                                    int index) =>
                                                Divider(height: height * 0.05),
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    cip.colourValue =
                                                        colours[index];
                                                  });
                                                  Navigator.pop(context);
                                                  cip.checkFormComplete();
                                                },
                                                child: SizedBox(
                                                    // height: 50,
                                                    child: StyledBody(
                                                        colours[index])),
                                              );
                                            }),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                      child: SizedBox(
                        height: width * 0.1,
                        child: Row(
                          children: [
                            const StyledBody('Colour'),
                            const Expanded(child: SizedBox()),
                            StyledBody(cip.colourValue),
                            Icon(Icons.chevron_right_outlined, size: width * 0.05)
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          const StyledBody('Size (UK)'),
                          const Expanded(child: SizedBox()), // <-- Use Expanded to fill the gap
                          ...['4', '6', '8', '10'].map((size) => Row(
                            children: [
                              Radio<String>(
                                value: size,
                                groupValue: cip.sizeValue,
                                onChanged: (val) {
                                  cip.sizeValue = val!;
                                  cip.checkFormComplete();
                                },
                                activeColor: Colors.black,
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                visualDensity: const VisualDensity(horizontal: -4, vertical: -4),
                              ),
                              SizedBox(width: width * 0.01),
                              StyledBody(size),
                              SizedBox(width: width * 0.03),
                            ],
                          )),
                        ],
                      ),
                    ),
                    const Divider(),
                    SizedBox(
                      height: width * 0.1,
                      child: Row(
                        children: [
                          const StyledBody('Retail Price'),
                          const Expanded(child: SizedBox()),
                          SizedBox(
                            width: width * 0.4,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              controller: cip.retailPriceController,
                              maxLength: 6, // <-- Limit to 6 digits
                              onChanged: (text) {
                                cip.retailPriceValue = text;
                                cip.checkFormComplete();
                              },
                              decoration: InputDecoration(
                                counterText: "", // Hide character counter if you want
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(
                                  vertical: width * 0.025, // Increase vertical padding for centering
                                  horizontal: 12,
                                ),
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
                                hintStyle: TextStyle(
                                    color: Colors.grey[800], fontSize: width * 0.03),
                                // hintText: "Enter price",
                                fillColor: Colors.white70,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(),
                    SizedBox(height: width * 0.04),
                    const Row(
                      children: [
                        StyledBody('Describe your item'),
                      ],
                    ),
                    SizedBox(height: width * 0.01),
                    // SizedBox(height: width * 0.02), // <-- Add this line for extra space
                    TextField(
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      maxLength: 30,
                      controller: cip.titleController,
                      onChanged: (text) {
                        cip.checkFormComplete();
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
                        hintStyle: TextStyle(
                            color: Colors.grey[800], fontSize: width * 0.03),
                        hintText: "Title",
                        fillColor: Colors.white70,
                      ),
                    ),
                    // SizedBox(height: width * 0.01),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      minLines: 2,
                      maxLines: null,
                      maxLength: 200,
                      controller: cip.shortDescController,
                      onChanged: (text) {
                        // checkContents(text);
                        cip.checkFormComplete();
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
                        hintStyle: TextStyle(
                            color: Colors.grey[800], fontSize: width * 0.03),
                        hintText: "Short Description",
                        fillColor: Colors.white70,
                      ),
                    ),
                    TextField(
                      keyboardType: TextInputType.multiline,
                      minLines: 5,
                      maxLines: null,
                      maxLength: 1000,
                      controller: cip.longDescController,
                      onChanged: (text) {
                        // checkContents(text);
                        cip.checkFormComplete();
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
                        hintStyle: TextStyle(
                            color: Colors.grey[800], fontSize: width * 0.03),
                        hintText: "Long Description",
                        fillColor: Colors.white70,
                      ),
                    ),
                    SizedBox(height: width * 0.03),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: StyledHeading('Add hashtags to your listing'),
                    ),
                    const SizedBox(height: 4),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: StyledBody(
                        'To help your listing reach more renters, we recommend you add some hashtags e.g. #summer, #holiday, #halloween, etc.',
                        color: Colors.black54,
                      ),
                    ),
                    SizedBox(height: width * 0.02),
                    Row(
                      children: [
                        const StyledBody('Hashtags'),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () => showHashtagModal(width, height),
                        ),
                      ],
                    ),
                    SizedBox(height: width * 0.01),
                    // Display the hashtags as chips
                    Wrap(
                      spacing: 8,
                      children: hashtags
                          .map((tag) => Chip(
                                label: Text('#$tag'),
                                onDeleted: () {
                                  setState(() {
                                    hashtags.remove(tag);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border:
                  Border.all(color: Colors.black.withOpacity(0.3), width: 1),
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
              onPressed: cip.isCompleteForm
                  ? () async {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => SetPricing(
                          cip.productTypeValue,
                          cip.brandValue,
                          cip.titleController.text,
                          cip.colourValue,
                          cip.retailPriceValue,
                          cip.shortDescController.text,
                          cip.longDescController.text,
                          cip.sizeValue,
                          const [],
                          _imageFiles,
                          dailyPrice: widget.item?.rentPriceDaily.toString(),
                          weeklyPrice: widget.item?.rentPriceWeekly.toString(),
                          monthlyPrice: widget.item?.rentPriceMonthly.toString(),
                          minRentalPeriod: widget.item?.minDays.toString(),
                          hashtags: hashtags,
                          id: widget.item?.id, // <-- Pass the id here
                        ),
                      ));
                    }
                  : null,
              style: OutlinedButton.styleFrom(
                backgroundColor: cip.isCompleteForm ? Colors.black : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(1.0),
                ),
                side: const BorderSide(width: 1.0, color: Colors.black),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StyledHeading(
                  'CONTINUE',
                  color: cip.isCompleteForm ? Colors.white : Colors.grey,
                ),
              ),
            ),
          ));
    });
  }

  uploadFile() async {
    String id =
        Provider.of<ItemStoreProvider>(context, listen: false).renter.id;
    String rng = uuid.v4();
    Reference ref = storage.ref().child('items').child(id).child('$rng.png');

    File file = File(_image!.path);
    UploadTask uploadTask = ref.putFile(file);

    await uploadTask;
    //
    imagePath.add(ref.fullPath.toString());
    log('Added imagePath of: ${ref.fullPath.toString()}');

    setState(() {
      readyToSubmit = true;
    });
    // return await taskSnapshot.ref.getDownloadURL();
  }

  // listFiles() async {
  //   final storageRef = FirebaseStorage.instance.ref();
  //   final listResult = await storageRef.listAll();
  //   // for (var prefix in listResult.prefixes) {
  //   // The prefixes under storageRef.
  //   // You can call listAll() recursively on them.
  //   // // }
  //   // for (var ref in listResult.items) {
  //   //   print('Found file: $ref');
  //   // }
  //   // for (var item in listResult.items) {}
  // }

  void showModal(type, n, width) {
    CreateItemProvider cip =
        Provider.of<CreateItemProvider>(context, listen: false);
    if (type == 'create') {
      showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          isScrollControlled: false,
          constraints:
              BoxConstraints(maxHeight: width * 0.4, minWidth: width * 0.8),
          builder: (context) {
            return Column(
              children: [
                SizedBox(height: width * 0.04),
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.gallery,
                      maxWidth: 1000,
                      maxHeight: 1500,
                      imageQuality: 100,
                    );
                    if (image != null) {
                      // Crop the image to 3:4 ratio before adding
                      final croppedFile = await ImageCropper().cropImage(
                        sourcePath: image.path,
                        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
                        uiSettings: [
                          AndroidUiSettings(
                            toolbarTitle: 'Crop Image',
                            toolbarColor: Colors.black,
                            toolbarWidgetColor: Colors.white,
                            initAspectRatio: CropAspectRatioPreset.original,
                            lockAspectRatio: true,
                          ),
                          IOSUiSettings(
                            title: 'Crop Image',
                            aspectRatioLockEnabled: true,
                          ),
                        ],
                      );
                      if (croppedFile != null) {
                        cip.images.add(croppedFile.path);
                        _imageFiles.add(XFile(croppedFile.path));
                        log('Added cropped imageFile: ${croppedFile.path}');
                      }
                    }

                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: const Center(child: StyledBody('ADD FROM GALLERY')),
                ),
                Divider(height: width * 0.04),
                GestureDetector(
                  onTap: () async {
                    final XFile? image = await _picker.pickImage(
                      source: ImageSource.camera,
                      maxWidth: 1000,
                      maxHeight: 1500,
                      imageQuality: 100,
                    );
                    if (image != null) {
                      // Crop the image to 3:4 ratio before adding
                      final croppedFile = await ImageCropper().cropImage(
                        sourcePath: image.path,
                        aspectRatio: const CropAspectRatio(ratioX: 3, ratioY: 4),
                        uiSettings: [
                          AndroidUiSettings(
                            toolbarTitle: 'Crop Image',
                            toolbarColor: Colors.black,
                            toolbarWidgetColor: Colors.white,
                            initAspectRatio: CropAspectRatioPreset.original,
                            lockAspectRatio: true,
                          ),
                          IOSUiSettings(
                            title: 'Crop Image',
                            aspectRatioLockEnabled: true,
                          ),
                        ],
                      );
                      if (croppedFile != null) {
                        cip.images.add(croppedFile.path);
                        _imageFiles.add(XFile(croppedFile.path));
                        log('Added cropped imageFile: ${croppedFile.path}');
                      }
                    }

                    setState(() {});
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Center(child: StyledBody('ADD FROM CAMERA')),
                ),
                // SizedBox(height: 400)
              ],
            );
          });
    } else if (type == 'edit') {
      showModalBottomSheet(
          backgroundColor: Colors.white,
          context: context,
          isScrollControlled: false,
          constraints:
              BoxConstraints(maxHeight: width * 0.4, minWidth: width * 0.8),
          builder: (context) {
            return Column(children: [
              SizedBox(height: width * 0.04),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);

                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => (ViewImage(
                            cip.images,
                            n,
                            isNetworkImage: false,
                          ))));
                },
                child: const Center(child: StyledBody('VIEW IMAGE')),
              ),
              Divider(height: width * 0.04),
              GestureDetector(
                onTap: () {
                  setState(() {
                    cip.images.removeAt(n - 1);
                    _imageFiles.removeAt(n - 1);
                  });
                  Navigator.pop(context);
                  cip.checkFormComplete();
                },
                child: const Center(child: StyledBody('DELETE')),
              ),
            ]);
          });
    }
  }

  // void checkFormComplete() {
  //   formComplete = true;
  //   if (_images.isNotEmpty &&
  //       productTypeValue != '' &&
  //       colourValue != '' &&
  //       brandValue != '' &&
  //       titleController.text != '' &&
  //       shortDescController.text != '' &&
  //       longDescController.text != '') {
  //     formComplete = true;
  //   }
  // }

  void showHashtagModal(double width, double height) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        String newHashtag = '';
        List<String> allHashtags = [
          // Example: populate with your app's global hashtags or fetch from backend
          'summer', 'wedding', 'party', 'vintage', 'designer', 'classic', 'new', 'sale'
        ];
        // Remove already selected hashtags from the list
        final availableHashtags = allHashtags.where((tag) => !hashtags.contains(tag)).toList();

        return FractionallySizedBox(
          heightFactor: 0.7,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: EdgeInsets.all(width * 0.05),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Free text entry at the top
                    TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Enter a hashtag (no # needed)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            final text = newHashtag.trim();
                            if (text.isNotEmpty && !hashtags.contains(text)) {
                              setState(() {
                                hashtags.add(text);
                              });
                              setModalState(() {
                                newHashtag = '';
                              });
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                      onChanged: (val) {
                        setModalState(() {
                          newHashtag = val;
                        });
                      },
                      onSubmitted: (val) {
                        final text = val.trim();
                        if (text.isNotEmpty && !hashtags.contains(text)) {
                          setState(() {
                            hashtags.add(text);
                          });
                          setModalState(() {
                            newHashtag = '';
                          });
                          Navigator.pop(context);
                        }
                      },
                    ),
                    SizedBox(height: width * 0.04),
                    const StyledBody('Choose from existing hashtags:'),
                    SizedBox(height: width * 0.02),
                    Expanded(
                      child: availableHashtags.isEmpty
                          ? const Center(child: StyledBody('No more hashtags'))
                          : ListView.separated(
                              itemCount: availableHashtags.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final tag = availableHashtags[index];
                                return ListTile(
                                  title: Text('#$tag'),
                                  trailing: const Icon(Icons.add, color: Colors.black),
                                  onTap: () {
                                    setState(() {
                                      hashtags.add(tag);
                                    });
                                    Navigator.pop(context);
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

