import 'package:flutter/material.dart';
import 'package:revivals/shared/item_results.dart';
import 'package:revivals/shared/item_types.dart';
import 'package:revivals/shared/styled_text.dart';

class Browse extends StatefulWidget {
  const Browse({super.key});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StyledTitle('BROWSE'),
          ],
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(width * 0.05, width * 0.05, width * 0.05, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search any keywords..',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: const BorderSide(color: Colors.black, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ItemResults(
                            'search',
                            '', // value is not used for search, only values is used
                            values: value
                                .split(RegExp(r'\s+|,'))
                                .where((s) => s.isNotEmpty)
                                .toList(),
                          ),
                        ),
                      );
                    }
                  },
                ),
                SizedBox(height: width * 0.05),
                // Item type boxes
                Center(
                  child: Wrap(
                    spacing: width * 0.04,
                    runSpacing: width * 0.04,
                    children: itemTypes.map((type) {
                      return _buildTypeBox(context, width, type['label'], type['image']);
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeBox(BuildContext context, double width, String label, String imagePath) {
    // Simple pluralisation logic
    String pluralLabel;
    if (label == 'Accessory') {
      pluralLabel = 'Accessories';
    } else if (label == 'Dress') {
      pluralLabel = 'Dresses';
    } else if (label == 'Jacket') {
      pluralLabel = 'Jackets';
    } else if (label == 'Coat') {
      pluralLabel = 'Coats';
    } else if (label == 'Bag') {
      pluralLabel = 'Bags';
    } else if (label == 'Hat') {
      pluralLabel = 'Hats';
    } else if (label == 'Suit') {
      pluralLabel = 'Suits';
    } else if (label == 'Top') {
      pluralLabel = 'Tops';
    } else if (label == 'Skirt') {
      pluralLabel = 'Skirts';
    } else if (label == 'Shorts') {
      pluralLabel = 'Shorts';
    } else if (label == 'Trouser' || label == 'Trousers') {
      pluralLabel = 'Trousers';
    } else if (label == 'Jumpsuit') {
      pluralLabel = 'Jumpsuits';
    } else if (label == 'Shoes') {
      pluralLabel = 'Shoes';
    } else if (label.endsWith('s')) {
      pluralLabel = label;
    } else {
      pluralLabel = '${label}s';
    }

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => ItemResults(
              'type',
              label,
            ),
          ),
        );
      },
      child: Container(
        width: width * 0.4,
        height: width * 0.4,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.black12, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.7),
              BlendMode.lighten,
            ),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: width * 0.025),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.85),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Center(child: StyledHeading(pluralLabel)),
            ),
          ],
        ),
      ),
    );
  }
}
