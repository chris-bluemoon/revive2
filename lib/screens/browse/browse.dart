import 'package:flutter/material.dart';
import 'package:revivals/shared/item_results.dart';
import 'package:revivals/shared/item_types.dart';
import 'package:revivals/shared/smooth_page_route.dart';
import 'package:revivals/shared/styled_text.dart';

class Browse extends StatefulWidget {
  const Browse({super.key});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: width * 0.22,
        title: const Text(
          'BROWSE',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.fromLTRB(width * 0.05, width * 0.06, width * 0.05, width * 0.05),
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.search_rounded,
                          color: Colors.black54,
                          size: 20,
                        ),
                      ),
                      hintText: 'Search for items, brands, or keywords...',
                      hintStyle: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.0),
                        borderSide: const BorderSide(color: Colors.black, width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.clear_rounded,
                                color: Colors.grey,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  searchQuery = '';
                                });
                              },
                            )
                          : null,
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                    onChanged: (value) {
                      setState(() {
                        searchQuery = value;
                      });
                    },
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        Navigator.of(context).push(
                          SmoothTransitions.luxury(ItemResults(
                              'search',
                              '', // value is not used for search, only values is used
                              values: value
                                  .split(RegExp(r'\s+|,'))
                                  .where((s) => s.isNotEmpty)
                                  .toList(),
                            )),
                        );
                      }
                    },
                  ),
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
            ), // Column
          ), // Padding
        ), // SingleChildScrollView
      ), // GestureDetector
    ), // Container
    ); // Scaffold
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
          SmoothTransitions.luxury(ItemResults(
              'type',
              label,
            )),
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
