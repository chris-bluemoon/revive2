import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/to_rent/to_rent.dart';
import 'package:revivals/shared/item_card.dart';
import 'package:revivals/shared/smooth_page_route.dart';

class YouMayAlsoLike extends StatelessWidget {
  final Item item;
  final bool isOwner;
  const YouMayAlsoLike({required this.item, required this.isOwner, super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Consumer<ItemStoreProvider>(
      builder: (context, store, _) {
        final allAcceptedItems = store.items.where((i) => i.status == "accepted").toList();
        final brandItems = allAcceptedItems
            .where((i) => i.brand == item.brand && i.id != item.id)
            .toList();
        if (brandItems.isEmpty || isOwner) {
          log("RETURNING EMPTY HERE");
          return const SizedBox.shrink();
        }
        // Only show items that are actually visible (e.g., not filtered out by other logic)
        final visibleItems = brandItems.where((i) => i != null).toList();
        log("visible items count: ${visibleItems.length}");
        if (visibleItems.isEmpty) {
          log("RETURNING EMPTY");
          return const SizedBox.shrink();
        }
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.05,
                right: width * 0.05,
                top: width * 0.04,
                bottom: width * 0.01,
              ),
              child: const Text(
                "YOU MAY ALSO LIKE",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                left: width * 0.05,
                right: width * 0.05,
                bottom: width * 0.03,
              ),
              child: SizedBox(
                height: width * 1,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: visibleItems.length,
                  itemBuilder: (context, index) {
                    final otherItem = visibleItems[index];
                    return Padding(
                      padding: EdgeInsets.only(right: width * 0.03),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            SmoothTransitions.luxury(ToRent(otherItem)),
                          );
                        },
                        child: SizedBox(
                          width: width * 0.5,
                          height: width * 1,
                          child: ItemCard(otherItem),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
