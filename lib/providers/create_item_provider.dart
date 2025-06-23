import 'package:flutter/material.dart';

class CreateItemProvider with ChangeNotifier {
  bool isCompleteForm = false;
  final List<String> images = [];
  String productTypeValue = '';
  String colourValue = '';
  String brandValue = '';
  String retailPriceValue = '';
  String _sizeValue = '';
  String get sizeValue => _sizeValue;
  set sizeValue(String value) {
    _sizeValue = value;
    // notifyListeners();
  }

  final titleController = TextEditingController();
  final retailPriceController = TextEditingController();
  final shortDescController = TextEditingController();
  final longDescController = TextEditingController();
  void checkFormComplete() {
    if (images.isNotEmpty &&
        productTypeValue.isNotEmpty &&
        colourValue.isNotEmpty &&
        brandValue.isNotEmpty &&
        sizeValue.isNotEmpty && // <-- Add this line
        titleController.text.isNotEmpty &&
        shortDescController.text.isNotEmpty &&
        longDescController.text.isNotEmpty) {
      isCompleteForm = true;
    } else {
      isCompleteForm = false;
    }
    notifyListeners();
  }

  void reset() {
    sizeValue = '';
    productTypeValue = '';
    colourValue = '';
    brandValue = '';
    retailPriceValue = '';
    retailPriceController.clear(); // <-- Add this line
    shortDescController.clear();
    longDescController.clear();
    titleController.clear();
    images.clear();
    // Reset any other fields as needed
  }
}

class SizeRadioGroup extends StatelessWidget {
  final CreateItemProvider cip;

  const SizeRadioGroup({super.key, required this.cip});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Radio<String>(
          value: '4',
          groupValue: cip.sizeValue,
          onChanged: (val) {
            cip.sizeValue = val!;
            cip.checkFormComplete();
          },
        ),
        Radio<String>(
          value: '6',
          groupValue: cip.sizeValue,
          onChanged: (val) {
            cip.sizeValue = val!;
            cip.checkFormComplete();
          },
        ),
        Radio<String>(
          value: '8',
          groupValue: cip.sizeValue,
          onChanged: (val) {
            cip.sizeValue = val!;
            cip.checkFormComplete();
          },
        ),
        Radio<String>(
          value: '10',
          groupValue: cip.sizeValue,
          onChanged: (val) {
            cip.sizeValue = val!;
            cip.checkFormComplete();
          },
        ),
      ],
    );
  }
}

class YourWidget extends StatefulWidget {
  final item; // Define the type of item

  const YourWidget({super.key, this.item});

  @override
  _YourWidgetState createState() => _YourWidgetState();
}

class _YourWidgetState extends State<YourWidget> {
  late CreateItemProvider cip;

  @override
  void initState() {
    super.initState();
    cip = CreateItemProvider();
    if (widget.item != null) {
      // Assign values to cip fields from widget.item
      cip.titleController.text = widget.item.title ?? '';
      cip.retailPriceController.text = widget.item.retailPrice?.toString() ?? '';
      cip.shortDescController.text = widget.item.shortDesc ?? '';
      cip.longDescController.text = widget.item.longDesc ?? '';
      cip.productTypeValue = widget.item.productType ?? '';
      cip.colourValue = widget.item.colour ?? '';
      cip.brandValue = widget.item.brand ?? '';
      cip.sizeValue = widget.item.size ?? '';
      // Add image handling if necessary
    }
    // Use post-frame callback to ensure listeners are attached
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cip.checkFormComplete();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: cip.titleController,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        TextField(
          controller: cip.retailPriceController,
          decoration: const InputDecoration(labelText: 'Retail Price'),
        ),
        TextField(
          controller: cip.shortDescController,
          decoration: const InputDecoration(labelText: 'Short Description'),
        ),
        TextField(
          controller: cip.longDescController,
          decoration: const InputDecoration(labelText: 'Long Description'),
        ),
        // Other fields and widgets
        SizeRadioGroup(cip: cip),
        ElevatedButton(
          onPressed: () {
            // Handle form submission
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}
