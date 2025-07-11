import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/badges.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/models/review.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/providers/payment_option_provider.dart';
import 'package:revivals/services/notification_service.dart';
import 'package:revivals/services/stripe_sevice.dart';
import 'package:revivals/shared/animated_logo_spinner.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:revivals/widgets/payment_option_widget.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class RentersRentalsPage extends StatefulWidget {
  const RentersRentalsPage({super.key});

  @override
  State<RentersRentalsPage> createState() => _RentersRentalsPageState();
}

class _RentersRentalsPageState extends State<RentersRentalsPage> {
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
        .where((r) => r.renterId == userId && r.transactionType == "rental")
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
                            final DateTime endDate =
                                DateTime.parse(rental.endDate);
                            final formattedStartDate =
                                DateFormat('d MMM yyyy').format(startDate);
                            final formattedEndDate =
                                DateFormat('d MMM yyyy').format(endDate);
                            final status = rental.status;
                            // Handle null item gracefully
                            final itemType = item?.type ?? 'Unknown Type';
                            final itemName = item?.name ?? 'Unknown Item';

                            // Find the owner by ID - use nullable approach
                            final Renter? owner =
                                itemStore.renters.cast<Renter?>().firstWhere(
                                      (r) => r?.id == rental.ownerId,
                                      orElse: () => null,
                                    );

                            final String ownerName =
                                owner?.name ?? 'Unknown Owner';

                            return ItemRenterCard(
                              itemRenter: rental,
                              itemName: itemName,
                              itemType: itemType,
                              startDate: formattedStartDate,
                              endDate: formattedEndDate,
                              status: status,
                              ownerName: ownerName,
                              price: rental.price,
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
                            final DateTime startDate =
                                DateTime.parse(purchase.startDate);
                            final DateTime endDate =
                                DateTime.parse(purchase.endDate);
                            final formattedStartDate =
                                DateFormat('d MMM yyyy').format(startDate);
                            final formattedEndDate =
                                DateFormat('d MMM yyyy').format(endDate);
                            final status = purchase.status;
                            // Handle null item gracefully
                            final itemType = item?.type ?? 'Unknown Type';
                            final itemName = item?.name ?? 'Unknown Item';

                            // Find the owner by ID - use nullable approach
                            final Renter? owner =
                                itemStore.renters.cast<Renter?>().firstWhere(
                                      (r) => r?.id == purchase.ownerId,
                                      orElse: () => null,
                                    );

                            final String ownerName =
                                owner?.name ?? 'Unknown Owner';

                            return PurchaseCard(
                              itemRenter: purchase,
                              itemName: itemName,
                              itemType: itemType,
                              startDate: formattedStartDate,
                              endDate: formattedEndDate,
                              status: status,
                              ownerName: ownerName,
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
  final String ownerName;
  final int price;

  const ItemRenterCard({
    super.key,
    required this.itemRenter,
    required this.itemName,
    required this.itemType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.ownerName,
    required this.price,
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
    final DateTime rentalStartDate =
        DateTime.parse(widget.itemRenter.startDate);
    final bool canCancel = rentalStartDate.isAfter(DateTime.now());

    // Check if the start date is today or in the future for expired status
    final DateTime today = DateTime.now();
    final DateTime startDateOnly = DateTime(
        rentalStartDate.year, rentalStartDate.month, rentalStartDate.day);
    final DateTime todayOnly = DateTime(today.year, today.month, today.day);
    final bool isExpired = startDateOnly.isBefore(todayOnly) ||
        startDateOnly.isAtSameMomentAs(todayOnly);

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

    final double width = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Item name and status
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(effectiveStatus).withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    effectiveStatus.toLowerCase() == "cancelledrenter" ||
                            effectiveStatus.toLowerCase() == "cancelledlender"
                        ? "CANCELLED"
                        : effectiveStatus.toLowerCase() == "reviewedbylender"
                            ? "REVIEWED BY LENDER"
                            : effectiveStatus.toLowerCase() ==
                                    "reviewedbyrenter"
                                ? "REVIEWED BY RENTER"
                                : effectiveStatus.toLowerCase() ==
                                        "reviewedbyboth"
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
                  widget.ownerName,
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
            // if (widget.itemRenter.status == "accepted" && !isExpired)
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    PaymentOptionProvider paymentProvider =
                        Provider.of<PaymentOptionProvider>(context,
                            listen: false);
                    paymentProvider.amount = widget.price;
                    showPaymentOptionBottomSheet(context);

                    bool paymentSuccess = paymentProvider.paymentSuccess;
                    if (paymentSuccess) {
                      Navigator.pop(context);
                      NotificationService.sendNotification(
                        notiType: NotiType.payment,
                        item: widget.itemName,
                        notiReceiverId: widget.itemRenter.ownerId,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment successful!'),
                        ),
                      );
                      setState(() {
                        widget.itemRenter.status = "paid";
                      });
                      ItemStoreProvider itemStore =
                          Provider.of<ItemStoreProvider>(context,
                              listen: false);
                      itemStore.saveItemRenter(widget.itemRenter);
                      Ledger newLedgerEntry = Ledger(
                        id: uuid.v4(), // Use uuid v4 for unique id
                        itemRenterId: widget.itemRenter.id,
                        owner: widget.itemRenter.ownerId,
                        date: DateTime.now().toIso8601String(),
                        type: "rental",
                        desc: "Payment for rental of ${widget.itemName}",
                        amount: widget.price,
                        balance: itemStore.getBalance() +
                            widget.price, // Update balance logic
                      );
                      itemStore.addLedger(newLedgerEntry);
                    } else {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Payment failed.'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('MAKE PAYMENT'),
                ),
                const SizedBox(width: 12),
              ],
            ),
            if (canCancel &&
                (widget.itemRenter.status == "accepted" ||
                    widget.itemRenter.status == "requested"))
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        widget.itemRenter.status = "cancelledRenter";
                      });
                      Provider.of<ItemStoreProvider>(context, listen: false)
                          .saveItemRenter(widget.itemRenter);

                      // Send notification to the lender
                      NotificationService.sendNotification(
                        notiType: NotiType.cancel,
                        item: widget.itemName,
                        notiReceiverId: widget.itemRenter.ownerId,
                      );

                      // Show alert dialog
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
                            "Booking Cancelled",
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          content: const Text(
                            "Your booking has been cancelled and the lender has been notified.",
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
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop(); // Close dialog
                                  // Navigator.of(context).pop(); // Go back to previous page
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
                    child: const Text('CANCEL'),
                  ),
                ],
              ),
            if (DateTime.parse(widget.itemRenter.endDate)
                    .isBefore(DateTime.now()) &&
                widget.itemRenter.status != "reviewedByRenter" &&
                widget.itemRenter.status != "reviewedByBoth")
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      String newStatus;
                      if (widget.itemRenter.status == "reviewedByLender") {
                        newStatus = "reviewedByBoth";
                      } else {
                        newStatus = "reviewedByRenter";
                      }

                      bool submitted = false;
                      await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          int selectedStars = 0;
                          final reviewController = TextEditingController();
                          // Only show badges relevant to reviews (e.g., trust badges)
                          final reviewBadges = allBadges
                              .where((b) =>
                                  b.title == 'Top Rated Lender' ||
                                  b.title == 'Great Communication' ||
                                  b.title == 'Flexible Pickup/Return' ||
                                  b.title == 'Super Lender' ||
                                  b.title == 'First Rental Complete' ||
                                  b.title == '10 Rentals' ||
                                  b.title == '50 Rentals' ||
                                  b.title == '100 Rentals' ||
                                  b.title == 'Sustainability Star' ||
                                  b.title == 'Fast Responder' ||
                                  b.title == 'Helpful Rater')
                              .toList();
                          final Map<String, bool> badgeSelections = {
                            for (var badge in reviewBadges) badge.title: false
                          };
                          return StatefulBuilder(
                            builder: (context, setState) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: const Text(
                                'Leave a Review',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              contentPadding:
                                  const EdgeInsets.fromLTRB(24, 20, 24, 0),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Text(
                                      'How was your experience?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade50,
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(5, (index) {
                                          return GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedStars = index + 1;
                                              });
                                            },
                                            child: Container(
                                              padding: const EdgeInsets.all(8),
                                              child: Icon(
                                                index < selectedStars
                                                    ? Icons.star_rounded
                                                    : Icons.star_border_rounded,
                                                color: index < selectedStars
                                                    ? Colors.amber.shade600
                                                    : Colors.grey.shade400,
                                                size: 32,
                                              ),
                                            ),
                                          );
                                        }),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                            color: Colors.grey.shade300),
                                      ),
                                      child: TextField(
                                        controller: reviewController,
                                        maxLines: 4,
                                        decoration: InputDecoration(
                                          hintText:
                                              'Share your thoughts about this rental...',
                                          hintStyle: TextStyle(
                                              color: Colors.grey.shade500),
                                          border: InputBorder.none,
                                          contentPadding:
                                              const EdgeInsets.all(16),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    // Badge checkboxes
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Award Badges:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    ...reviewBadges.map((badge) =>
                                        CheckboxListTile(
                                          value: badgeSelections[badge.title],
                                          onChanged: (val) {
                                            setState(() {
                                              badgeSelections[badge.title] =
                                                  val ?? false;
                                            });
                                          },
                                          title: Row(
                                            children: [
                                              Icon(badge.icon, size: 20),
                                              const SizedBox(width: 8),
                                              Text(badge.title),
                                            ],
                                          ),
                                          subtitle: Text(badge.description,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          dense: true,
                                        )),
                                  ],
                                ),
                              ),
                              actionsPadding:
                                  const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              actions: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          side: BorderSide(
                                              color: Colors.grey.shade400),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (selectedStars == 0) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'Please select a star rating.')),
                                            );
                                            return;
                                          }
                                          final selectedBadges = reviewBadges
                                              .where((b) =>
                                                  badgeSelections[b.title] ==
                                                  true)
                                              .map((b) => b.title)
                                              .toList();
                                          submitted = true;
                                          Provider.of<ItemStoreProvider>(
                                                  context,
                                                  listen: false)
                                              .addReview(Review(
                                            id: uuid.v4(),
                                            reviewerId:
                                                Provider.of<ItemStoreProvider>(
                                                        context,
                                                        listen: false)
                                                    .renter
                                                    .id,
                                            reviewedUserId:
                                                widget.itemRenter.ownerId,
                                            itemRenterId: widget.itemRenter.id,
                                            itemId: widget.itemRenter.itemId,
                                            rating: selectedStars,
                                            text: reviewController.text,
                                            date: DateTime.now(),
                                            badges: selectedBadges,
                                          ));
                                          Navigator.of(context).pop();
                                          setState(() {});
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Submit Review',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      if (submitted) {
                        setState(() {
                          widget.itemRenter.status = newStatus;
                        });
                        // Update in itemStore (if using Provider or similar)
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .saveItemRenter(widget.itemRenter);
                        // After submitting a review, update badges for the lender (owner)
                        final itemStore = Provider.of<ItemStoreProvider>(
                            context,
                            listen: false);
                        final owner = itemStore.renters.firstWhere(
                          (r) => r.id == widget.itemRenter.ownerId,
                          orElse: () => null,
                        );
                        if (owner != null) {
                          itemStore.checkAndAwardBadges(owner);
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(
                            Radius.circular(12)), // Rounded corners
                      ),
                    ),
                    child: const Text('LEAVE REVIEW'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// Create a custom widget to display purchase details for renters (status only, no buttons)
class PurchaseCard extends StatelessWidget {
  final ItemRenter itemRenter;
  final String itemName;
  final String itemType;
  final String status;
  final String startDate;
  final String endDate;
  final String ownerName;
  final int price;

  const PurchaseCard({
    super.key,
    required this.itemRenter,
    required this.itemName,
    required this.itemType,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.ownerName,
    required this.price,
  });

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
    final formattedPrice = NumberFormat("#,##0", "en_US").format(price);
    final double width = MediaQuery.of(context).size.width;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Item name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    itemName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: width * 0.045, // Reduced and responsive
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(itemRenter.status).withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    itemRenter.status.toLowerCase() == "cancelledrenter" ||
                            itemRenter.status.toLowerCase() == "cancelledlender"
                        ? "CANCELLED"
                        : itemRenter.status.toLowerCase() == "reviewedbylender"
                            ? "REVIEWED BY LENDER"
                            : itemRenter.status.toLowerCase() ==
                                    "reviewedbyrenter"
                                ? "REVIEWED BY RENTER"
                                : itemRenter.status.toLowerCase() ==
                                        "reviewedbyboth"
                                    ? "BOTH REVIEWED"
                                    : itemRenter.status.toUpperCase(),
                    style: TextStyle(
                      color: _statusColor(itemRenter.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Item type and owner
            Row(
              children: [
                Icon(Icons.category, size: 17, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  itemType,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
                const SizedBox(width: 16),
                Icon(Icons.person, size: 17, color: Colors.grey[700]),
                const SizedBox(width: 6),
                Text(
                  ownerName,
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
                  '$startDate - $endDate',
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
            // Add LEAVE REVIEW button condition for purchases (same as lender dashboard)
            if (DateTime.parse(itemRenter.endDate).isBefore(DateTime.now()) &&
                itemRenter.status != "booked" &&
                itemRenter.status != "reviewedByRenter" &&
                itemRenter.status != "reviewedByBoth")
              Row(
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // Determine new status based on current status
                      String newStatus;
                      if (itemRenter.status == "reviewedByLender") {
                        newStatus = "reviewedByBoth";
                      } else {
                        newStatus = "reviewedByRenter";
                      }
                      bool submitted = false;
                      await showDialog(
                        barrierDismissible: false,
                        context: context,
                        builder: (context) {
                          int selectedStars = 0;
                          final reviewController = TextEditingController();
                          // Only show badges relevant to reviews (e.g., trust badges)
                          final reviewBadges = allBadges
                              .where((b) =>
                                  b.title == 'Top Rated Lender' ||
                                  b.title == 'Great Communication' ||
                                  b.title == 'Flexible Pickup/Return' ||
                                  b.title == 'Super Lender' ||
                                  b.title == 'First Rental Complete' ||
                                  b.title == '10 Rentals' ||
                                  b.title == '50 Rentals' ||
                                  b.title == '100 Rentals' ||
                                  b.title == 'Sustainability Star' ||
                                  b.title == 'Fast Responder' ||
                                  b.title == 'Helpful Rater')
                              .toList();
                          final Map<String, bool> badgeSelections = {
                            for (var badge in reviewBadges) badge.title: false
                          };
                          return StatefulBuilder(
                            builder: (context, setState) => AlertDialog(
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                              ),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
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
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide:
                                              BorderSide(color: Colors.black),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.black, width: 2),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    // Badge checkboxes
                                    const Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text('Award Badges:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                    ...reviewBadges.map((badge) =>
                                        CheckboxListTile(
                                          value: badgeSelections[badge.title],
                                          onChanged: (val) {
                                            setState(() {
                                              badgeSelections[badge.title] =
                                                  val ?? false;
                                            });
                                          },
                                          title: Row(
                                            children: [
                                              Icon(badge.icon, size: 20),
                                              const SizedBox(width: 8),
                                              Text(badge.title),
                                            ],
                                          ),
                                          subtitle: Text(badge.description,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          dense: true,
                                        )),
                                  ],
                                ),
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
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Please select a star rating.')),
                                      );
                                      return;
                                    }
                                    final selectedBadges = reviewBadges
                                        .where((b) =>
                                            badgeSelections[b.title] == true)
                                        .map((b) => b.title)
                                        .toList();
                                    submitted = true;
                                    Provider.of<ItemStoreProvider>(context,
                                            listen: false)
                                        .addReview(Review(
                                      id: uuid.v4(),
                                      reviewerId:
                                          Provider.of<ItemStoreProvider>(
                                                  context,
                                                  listen: false)
                                              .renter
                                              .id,
                                      reviewedUserId: itemRenter
                                          .ownerId, // Reviewing the owner (lender)
                                      itemRenterId: itemRenter.id,
                                      itemId: itemRenter.itemId,
                                      rating: selectedStars,
                                      text: reviewController.text,
                                      date: DateTime.now(),
                                      badges: selectedBadges,
                                    ));
                                    Navigator.of(context).pop();
                                    // setState will be called below if submitted
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
                      if (submitted) {
                        // Update status and save
                        (context as Element).markNeedsBuild(); // force rebuild
                        itemRenter.status = newStatus;
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .saveItemRenter(itemRenter);
                      }
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
          ],
        ),
      ),
    );
  }
}
