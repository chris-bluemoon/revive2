import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/services/notification_service.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class LendersRentalsPage extends StatefulWidget {
  const LendersRentalsPage({super.key});

  @override
  State<LendersRentalsPage> createState() => _LendersRentalsPageState();
}

class _LendersRentalsPageState extends State<LendersRentalsPage> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refreshItemRenters();
  }

  void _refreshItemRenters() async {
    await Provider.of<ItemStoreProvider>(context, listen: false)
        .fetchItemRentersAgain();
    log('Loaded item renters');
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final width = MediaQuery.of(context).size.width;
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    final String userId = itemStore.renter.id;
    final rentals = itemStore.itemRenters
        .where((r) => r.ownerId == userId && r.transactionType == "rental")
        .toList();
    final purchases = itemStore.itemRenters
        .where((r) => r.ownerId == userId && r.transactionType == "purchase")
        .toList();
    final items = itemStore.items; // items should be a list or map of all items

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: width * 0.08),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          title: const StyledTitle(
            "TRANSACTIONS",
          ),
          elevation: 0,
          bottom: const TabBar(
            labelColor: Colors.black,
            indicatorColor: Colors.black,
            tabs: [
              Tab(text: "Rentals"),
              Tab(text: "Purchases"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Rentals Tab
            rentals.isEmpty
                ? const Center(child: Text('No rentals found.'))
                : ListView.separated(
                    itemCount: rentals.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final rental = rentals[index];
                      // Find the item by ID
                      final item = items.firstWhere(
                        (it) => it.id == rental.itemId,
                        orElse: () => Item(
                            id: '',
                            name: 'Unknown Item',
                            owner: '',
                            type: '',
                            bookingType: '',
                            dateAdded: '',
                            brand: '',
                            colour: '',
                            size: '',
                            rentPriceDaily: 0,
                            rentPriceWeekly: 0,
                            rentPriceMonthly: 0,
                            buyPrice: 0,
                            rrp: 0,
                            description: '',
                            longDescription: '',
                            imageId: [],
                            status: '',
                            minDays: 1,
                            hashtags: []), // Provide a default Item
                      );

                      // Format endDate using intl package for better readability
                      final DateTime startDate =
                          DateTime.parse(rental.startDate);
                      final DateTime endDate = DateTime.parse(rental.endDate);
                      final formattedStartDate =
                          DateFormat('d MMM yyyy').format(startDate);
                      final formattedEndDate =
                          DateFormat('d MMM yyyy').format(endDate);
                      final status = rental.status;
                      final itemType = item.type;
                      final itemName =
                          item != null ? item.name : 'Unknown Item';

                      // Assuming you have a renters table/list in itemStore and itemRenter.owner is the renter's id
                      final renter = itemStore.renters.firstWhere(
                        (r) => r.id == rental.renterId,
                        orElse: () => Renter(
                            id: '',
                            name: 'Unknown Renter',
                            email: '',
                            type: '',
                            size: 0,
                            address: '',
                            countryCode: '',
                            phoneNum: '',
                            favourites: [],
                            verified: '',
                            imagePath: '',
                            creationDate: '',
                            location: '',
                            bio: '',
                            followers: [],
                            following: [],
                            avgReview: 0.0,
                            lastLogin: DateTime.now(),
                            vacations: [],
                            status: 'not active'
                            ), // Provide a default Renter
                      );
                      final renterName = renter.name;

                      return ItemRenterCard(
                        itemRenter: rental,
                        itemName: itemName,
                        itemType: itemType,
                        startDate: formattedStartDate,
                        endDate: formattedEndDate,
                        status: status,
                        renterName: renterName,
                        price: rental.price,
                        renterId: renter.id,
                      );
                    },
                  ),
            // Purchases Tab
            purchases.isEmpty
                ? const Center(child: Text('No purchases found.'))
                : ListView.separated(
                    itemCount: purchases.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final purchase = purchases[index];
                      return ListTile(
                        title: Text(purchase.itemId),
                        subtitle: Text(
                          'Date: ${purchase.endDate}/${purchase.endDate}/${purchase.endDate}',
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}

// Create a custom widget to display more details from ItemRenter

class ItemRenterCard extends StatefulWidget {
  final ItemRenter itemRenter;
  final String itemName;
  final String itemType;
  String status;
  final String startDate;
  final String endDate;
  final String renterName;
  final String renterId;
  final int price;
  // Add more fields as needed

  ItemRenterCard({
    super.key,
    required this.itemRenter,
    required this.itemName,
    required this.itemType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.renterName,
    required this.price,
    required this.renterId,
    // Add more required parameters as needed
  });

  @override
  State<ItemRenterCard> createState() => _ItemRenterCardState();
}

class _ItemRenterCardState extends State<ItemRenterCard> {
    Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'paid':
        return Colors.green;
      case 'completed':
        return Colors.blue;
      case 'requested':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat("#,##0", "en_US").format(widget.price);
    final DateTime rentalStartDate = DateTime.parse(widget.itemRenter.startDate);
    final bool canCancel = rentalStartDate.isAfter(DateTime.now().add(const Duration(days: 2)));
    // Show ACCEPT/REJECT only if status is "requested" AND startDate is today or in the future
    final bool showAcceptReject = widget.itemRenter.status == "requested" &&
        (rentalStartDate.isAtSameMomentAs(DateTime.now()) || rentalStartDate.isAfter(DateTime.now()));

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.itemName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(widget.status).withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.status.toLowerCase() == "cancelledlender"
                        ? "CANCELLED"
                        : widget.status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(widget.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Item type and renter
            Row(
              children: [
                Icon(Icons.category, size: 17, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  widget.itemType,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 17, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  widget.renterName,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Dates and price
            Row(
              children: [
                Icon(Icons.calendar_today, size: 15, color: Colors.grey[700]),
                const SizedBox(width: 4),
                Text(
                  '${widget.startDate} - ${widget.endDate}',
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(child: Container()), // pushes the price to the right
                Text(
                  '฿$formattedPrice',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
            if (showAcceptReject)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.itemRenter.status = "accepted";
                        widget.status = "accepted";
                      });
                      ItemStoreProvider itemStore =
                          Provider.of<ItemStoreProvider>(context,
                              listen: false);
                      itemStore.saveItemRenter(widget.itemRenter);
                      NotificationService.sendNotification(notiType: NotiType.accept, item: widget.itemName, notiReceiverId:widget.renterId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('ACCEPT'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        widget.itemRenter.status = "rejected";
                        widget.status = "rejected";
                      });
                      ItemStoreProvider itemStore =
                          Provider.of<ItemStoreProvider>(context,
                              listen: false);
                      itemStore.saveItemRenter(widget.itemRenter);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('REJECT'),
                  ),
                ],
              ),
              // Only show CANCEL if showAcceptReject is false
              if (!showAcceptReject && canCancel && (widget.itemRenter.status == "accepted" || widget.itemRenter.status == "requested"))
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          widget.itemRenter.status = "cancelledLender";
                          widget.status = "cancelledLender";
                        });
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .saveItemRenter(widget.itemRenter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ],
                ),
            // Add this to show CANCELLED status
          ],
        ),
      ),
    );
  }
}

// Usage in your list:
// ListView.builder(
//   itemCount: itemStore.itemRenters.length,
//   itemBuilder: (context, index) {
//     final itemRenter = itemStore.itemRenters[index];
//     return ItemRenterCard(itemRenter: itemRenter);
//   },
// )
