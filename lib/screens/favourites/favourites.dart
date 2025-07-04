import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/to_rent/to_rent.dart';
import 'package:revivals/shared/item_card.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Favourites extends StatefulWidget {
  const Favourites({super.key});

  @override
  State<Favourites> createState() => _FavouritesState();
}

class _FavouritesState extends State<Favourites> {
  bool anyFavourites = true;

  @override
  initState() {
    // Provider.of<ItemStoreProvider>(context, listen: false).populateFavourites();
    super.initState();
  }

  // Not needed for this screen but included to satisfy ItemCard
  void updateFittingsCount(fittingsCount) {
    fittingsCount = fittingsCount;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (Provider.of<ItemStoreProvider>(context, listen: false)
            .favourites
            .length >
        0) {
      anyFavourites = true;
    } else {
      anyFavourites = false;
    }
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          centerTitle: true,
          title: const StyledTitle('WISH LIST'),
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: width * 0.08),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: anyFavourites
            ? Container(
                color: Colors.white,
                child: Consumer<ItemStoreProvider>(
                    // child not required
                    builder: (context, value, child) {
                  // Get the current user's favourites list
                  final currentUser = value.renter;
                  final allItems = value.items;
                  final favouriteItems = allItems.where((item) => currentUser.favourites.contains(item.id) && item.status == 'accepted').toList();

                  return (favouriteItems.isNotEmpty)
                      ? GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2, childAspectRatio: 0.5),
                          itemBuilder: (_, index) => GestureDetector(
                              child: ItemCard(favouriteItems[index]),
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        (ToRent(favouriteItems[index]))));
                              }),
                          itemCount: favouriteItems.length,
                        )
                      : const NoFavWidget();
                }))
            : const NoFavWidget());
  }
}

class NoFavWidget extends StatelessWidget {
  const NoFavWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.favorite_outline, size: width * 0.1),
        const StyledHeading('No Favourites Yet'),
        SizedBox(height: width * 0.05),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: const Text(
            'Browse our extensive range of gorgeous dresses and hit that heart icon to save here!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }
}
