import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/models/review.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/services/notification_service.dart';
import 'package:revivals/shared/animated_logo_spinner.dart';
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
    // Delay data loading to allow smooth transition
    _delayedLoadData();
  }

  void _delayedLoadData() async {
    // Wait for the transition to complete before loading data
    await Future.delayed(const Duration(milliseconds: 500));
    _refreshItemRenters();
  }

  void _refreshItemRenters() async {
    await Provider.of<ItemStoreProvider>(context, listen: false)
        .fetchItemRentersAgain();
    log('Loaded item renters');
    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
          toolbarHeight: width * 0.2,
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
        body: _loading
            ? const Center(child: AnimatedLogoSpinner(size: 60))
            : TabBarView(
                children: [
                  // Rentals Tab
                  rentals.isEmpty
                      ? const Center(child: Text('No rentals yet'))
                      : ListView.separated(
                    itemCount: rentals.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final rental = rentals[index];
                      // Find the item by ID - use nullable approach
                      final Item? item = items.cast<Item?>().firstWhere(
                        (it) => it?.id == rental.itemId,
                        orElse: () => null,
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
                      // Handle null item gracefully
                      final itemType = item?.type ?? 'Unknown Type';
                      final itemName = item?.name ?? 'Unknown Item';

                      // Find the renter by ID - use nullable approach
                      final Renter? renter = itemStore.renters.cast<Renter?>().firstWhere(
                        (r) => r?.id == rental.renterId,
                        orElse: () => null,
                      );
                      final renterName = renter?.name ?? 'Unknown Renter';

                      return ItemRenterCard(
                        itemRenter: rental,
                        itemName: itemName,
                        itemType: itemType,
                        startDate: formattedStartDate,
                        endDate: formattedEndDate,
                        status: status,
                        renterName: renterName,
                        price: rental.price,
                        renterId: renter?.id ?? '',
                      );
                    },
                  ),
                  // Purchases Tab
                  purchases.isEmpty
                      ? const Center(child: Text('No purchases yet'))
                      : ListView.separated(
                          itemCount: purchases.length,
                          separatorBuilder: (context, index) => const Divider(),
                          itemBuilder: (context, index) {
                            final purchase = purchases[index];
                            // Find the item by ID - use nullable approach
                            final Item? item = items.cast<Item?>().firstWhere(
                              (it) => it?.id == purchase.itemId,
                              orElse: () => null,
                            );

                            // Format dates using intl package for better readability
                            final DateTime startDate = DateTime.parse(purchase.startDate);
                            final DateTime endDate = DateTime.parse(purchase.endDate);
                            final formattedStartDate = DateFormat('d MMM yyyy').format(startDate);
                            final formattedEndDate = DateFormat('d MMM yyyy').format(endDate);
                            final status = purchase.status;
                            // Handle null item gracefully
                            final itemType = item?.type ?? 'Unknown Type';
                            final itemName = item?.name ?? 'Unknown Item';

                            // Find the renter by ID - use nullable approach
                            final Renter? renter = itemStore.renters.cast<Renter?>().firstWhere(
                              (r) => r?.id == purchase.renterId,
                              orElse: () => null,
                            );
                            final renterName = renter?.name ?? 'Unknown Renter';

                            return PurchaseCardLender(
                              itemRenter: purchase,
                              itemName: itemName,
                              itemType: itemType,
                              startDate: formattedStartDate,
                              endDate: formattedEndDate,
                              status: status,
                              renterName: renterName,
                              price: purchase.price,
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
  final String status;
  final String startDate;
  final String endDate;
  final String renterName;
  final String renterId;
  final int price;
  // Add more fields as needed

  const ItemRenterCard({
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
      case 'expired':
        return Colors.grey;
      case 'reviewedbyrenter':
      case 'reviewedbylender':
      case 'reviewedbyboth':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat("#,##0", "en_US").format(widget.price);
    final DateTime rentalStartDate = DateTime.parse(widget.itemRenter.startDate);
    final bool canCancel = rentalStartDate.isAfter(DateTime.now().add(const Duration(days: 2)));
    
    // Check if the start date is today or in the future for expired status
    final DateTime today = DateTime.now();
    final DateTime startDateOnly = DateTime(rentalStartDate.year, rentalStartDate.month, rentalStartDate.day);
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);
    final bool isExpired = startDateOnly.isBefore(todayOnly) || startDateOnly.isAtSameMomentAs(todayOnly);
    
    // Determine the effective status
    String effectiveStatus = widget.itemRenter.status;
    if (isExpired && effectiveStatus == "accepted") {
      effectiveStatus = "expired";
      // Update the database status if needed
      if (widget.itemRenter.status != "expired") {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          widget.itemRenter.status = "expired";
          Provider.of<ItemStoreProvider>(context, listen: false)
              .saveItemRenter(widget.itemRenter);
        });
      }
    }
    
    // Show ACCEPT/REJECT only if status is "requested" AND startDate is today or in the future
    final bool showAcceptReject = widget.itemRenter.status == "requested" &&
        (rentalStartDate.isAtSameMomentAs(DateTime.now()) || rentalStartDate.isAfter(DateTime.now()));
    
    final double width = MediaQuery.of(context).size.width;

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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.045, // Reduced and responsive
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(effectiveStatus).withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    effectiveStatus.toLowerCase() == "cancelledlender" ||
                    effectiveStatus.toLowerCase() == "cancelledrenter"
                        ? "CANCELLED"
                        : effectiveStatus.toLowerCase() == "reviewedbylender"
                        ? "REVIEWED BY LENDER"
                        : effectiveStatus.toLowerCase() == "reviewedbyrenter"
                        ? "REVIEWED BY RENTER"
                        : effectiveStatus.toLowerCase() == "reviewedbyboth"
                        ? "BOTH REVIEWED"
                        : effectiveStatus.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(effectiveStatus),
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
                    onPressed: () async {
                      setState(() {
                        widget.itemRenter.status = "accepted";
                      });
                      ItemStoreProvider itemStore =
                          Provider.of<ItemStoreProvider>(context,
                              listen: false);
                      itemStore.saveItemRenter(widget.itemRenter);
                      NotificationService.sendNotification(notiType: NotiType.accept, item: widget.itemName, notiReceiverId:widget.renterId);
                      
                      // Show confirmation dialog
                      if (!context.mounted) return;
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          title: const Text(
                            "Request Accepted",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          content: const Text(
                            "The renter has been informed and we'll notify you when payment is made.",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                },
                                child: const Text(
                                  "OK",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('ACCEPT'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        widget.itemRenter.status = "rejected";
                      });
                      ItemStoreProvider itemStore =
                          Provider.of<ItemStoreProvider>(context,
                              listen: false);
                      itemStore.saveItemRenter(widget.itemRenter);
                      
                      // Show confirmation dialog
                      if (!context.mounted) return;
                      await showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          title: const Text(
                            "Request Rejected",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          content: const Text(
                            "The renter has been informed of your decision.",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          actionsAlignment: MainAxisAlignment.center,
                          actions: [
                            SizedBox(
                              width: 100,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(12)),
                                  ),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                },
                                child: const Text(
                                  "OK",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
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
                        });
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .saveItemRenter(widget.itemRenter);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('CANCEL'),
                    ),
                  ],
                ),
            // Add LEAVE REVIEW button condition
            if (DateTime.parse(widget.itemRenter.endDate).isBefore(DateTime.now()) &&
                widget.itemRenter.status != "reviewedByLender" && 
                widget.itemRenter.status != "reviewedByBoth")
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Determine new status based on current status
                      String newStatus;
                      if (widget.itemRenter.status == "reviewedByRenter") {
                        newStatus = "reviewedByBoth";
                      } else {
                        newStatus = "reviewedByLender";
                      }
                      
                      setState(() {
                        widget.itemRenter.status = newStatus;
                      });
                      // Update in itemStore
                      Provider.of<ItemStoreProvider>(context, listen: false)
                          .saveItemRenter(widget.itemRenter);

                      await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          int selectedStars = 0;
                          final reviewController = TextEditingController();
                          return StatefulBuilder(
                            builder: (context, setState) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      return IconButton(
                                        icon: Icon(
                                          index < selectedStars
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedStars = index + 1;
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: reviewController,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      hintText: 'Write your review here...',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (selectedStars == 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Please select a star rating.')),
                                      );
                                      return;
                                    }
                                    Provider.of<ItemStoreProvider>(context, listen: false)
                                        .addReview(Review(
                                      id: uuid.v4(),
                                      reviewerId: Provider.of<ItemStoreProvider>(context, listen: false)
                                          .renter
                                          .id,
                                      reviewedUserId: widget.itemRenter.renterId, // Reviewing the renter
                                      itemRenterId: widget.itemRenter.id,
                                      itemId: widget.itemRenter.itemId,
                                      rating: selectedStars,
                                      text: reviewController.text,
                                      date: DateTime.now(),
                                    ));
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  },
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    child: const Text('LEAVE REVIEW'),
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

// Create a custom widget to display purchase details for lenders
class PurchaseCardLender extends StatefulWidget {
  final ItemRenter itemRenter;
  final String itemName;
  final String itemType;
  final String status;
  final String startDate;
  final String endDate;
  final String renterName;
  final int price;

  const PurchaseCardLender({
    super.key,
    required this.itemRenter,
    required this.itemName,
    required this.itemType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.renterName,
    required this.price,
  });

  @override
  State<PurchaseCardLender> createState() => _PurchaseCardLenderState();
}

class _PurchaseCardLenderState extends State<PurchaseCardLender> {

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
      case 'expired':
        return Colors.grey;
      case 'reviewedbyrenter':
      case 'reviewedbylender':
      case 'reviewedbyboth':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat("#,##0", "en_US").format(widget.price);
    final double width = MediaQuery.of(context).size.width;
    
    // Check if the start date is today or in the future for expired status
    final DateTime purchaseStartDate = DateTime.parse(widget.itemRenter.startDate);
    final DateTime today = DateTime.now();
    final DateTime startDateOnly = DateTime(purchaseStartDate.year, purchaseStartDate.month, purchaseStartDate.day);
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);
    final bool isExpired = startDateOnly.isBefore(todayOnly) || startDateOnly.isAtSameMomentAs(todayOnly);
    
    // Determine the effective status
    String effectiveStatus = widget.itemRenter.status;
    if (isExpired && effectiveStatus == "accepted") {
      effectiveStatus = "expired";
    }

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
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.045, // Reduced and responsive
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(effectiveStatus).withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    effectiveStatus.toLowerCase() == "cancelledlender" ||
                    effectiveStatus.toLowerCase() == "cancelledrenter"
                        ? "CANCELLED"
                        : effectiveStatus.toLowerCase() == "reviewedbylender"
                        ? "REVIEWED BY LENDER"
                        : effectiveStatus.toLowerCase() == "reviewedbyrenter"
                        ? "REVIEWED BY RENTER"
                        : effectiveStatus.toLowerCase() == "reviewedbyboth"
                        ? "BOTH REVIEWED"
                        : effectiveStatus.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(effectiveStatus),
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
            // Dates
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
            // Add LEAVE REVIEW button condition for purchases
            if (DateTime.parse(widget.itemRenter.endDate).isBefore(DateTime.now()) &&
                widget.itemRenter.status != "reviewedByLender" && 
                widget.itemRenter.status != "reviewedByBoth")
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Determine new status based on current status
                      String newStatus;
                      if (widget.itemRenter.status == "reviewedByRenter") {
                        newStatus = "reviewedByBoth";
                      } else {
                        newStatus = "reviewedByLender";
                      }
                      
                      setState(() {
                        widget.itemRenter.status = newStatus;
                      });
                      // Update in itemStore
                      Provider.of<ItemStoreProvider>(context, listen: false)
                          .saveItemRenter(widget.itemRenter);

                      await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          int selectedStars = 0;
                          final reviewController = TextEditingController();
                          return StatefulBuilder(
                            builder: (context, setState) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(12)),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(5, (index) {
                                      return IconButton(
                                        icon: Icon(
                                          index < selectedStars
                                              ? Icons.star
                                              : Icons.star_border,
                                          color: Colors.amber,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            selectedStars = index + 1;
                                          });
                                        },
                                      );
                                    }),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    controller: reviewController,
                                    maxLines: 4,
                                    decoration: const InputDecoration(
                                      hintText: 'Write your review here...',
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide(color: Colors.black, width: 2),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (selectedStars == 0) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                            content: Text('Please select a star rating.')),
                                      );
                                      return;
                                    }
                                    Provider.of<ItemStoreProvider>(context, listen: false)
                                        .addReview(Review(
                                      id: uuid.v4(),
                                      reviewerId: Provider.of<ItemStoreProvider>(context, listen: false)
                                          .renter
                                          .id,
                                      reviewedUserId: widget.itemRenter.renterId, // Reviewing the renter
                                      itemRenterId: widget.itemRenter.id,
                                      itemId: widget.itemRenter.itemId,
                                      rating: selectedStars,
                                      text: reviewController.text,
                                      date: DateTime.now(),
                                    ));
                                    Navigator.of(context).pop();
                                    setState(() {});
                                  },
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                    ),
                    child: const Text('LEAVE REVIEW'),
                  ),
                ],
              ),
            // No other action buttons for purchases
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
