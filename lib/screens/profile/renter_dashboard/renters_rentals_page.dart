import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/ledger.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/models/review.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/services/stripe_sevice.dart';
import 'package:revivals/shared/styled_text.dart';
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
    _refreshItemRenters();
  }

  void _refreshItemRenters() async {
    await Provider.of<ItemStoreProvider>(context, listen: false)
        .fetchItemRentersAgain();
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
          actions: [
            IconButton(
                onPressed: () async {
                  await StripeService.instance
                      .initPaymentSheet(context, amount: 100);
                },
                icon: const Icon(Icons.access_alarm))
          ],
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
                      final Renter owner = itemStore.renters.firstWhere(
                        (r) => r.id == rental.ownerId,
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
                            following: []), // Provide a default Renter
                      );

                      final String ownerName = owner.name;

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
  final String ownerName;
  final int price;

  ItemRenterCard({
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
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat("#,##0", "en_US").format(widget.price);

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
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 19,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _statusColor(widget.status).withOpacity(0.13),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    widget.status.toUpperCase(),
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
            // if (widget.itemRenter.status == "accepted")
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await StripeService.instance
                        .initPaymentSheet(context, amount: widget.price);

                    setState(() {
                      widget.itemRenter.status = "paid";
                    });
                    widget.status = "paid";
                    ItemStoreProvider itemStore =
                        Provider.of<ItemStoreProvider>(context, listen: false);
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
                    // Make payment logic here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('MAKE PAYMENT'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      widget.itemRenter.status = "cancelled";
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('CANCEL'),
                ),
              ],
            ),
            if (DateTime.parse(widget.itemRenter.endDate)
                    .isBefore(DateTime.now()) &&
                widget.status != "reviewed")
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    widget.itemRenter.status = "reviewed";
                    widget.status = "reviewed";
                  });
                  // Update in itemStore (if using Provider or similar)
                  Provider.of<ItemStoreProvider>(context, listen: false)
                      .saveItemRenter(widget.itemRenter);

                  // int selectedStars = 0;
                  // TextEditingController reviewController =
                  //     TextEditingController();

                  await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) {
                      int selectedStars = 0;
                      final reviewController = TextEditingController();
                      return StatefulBuilder(
                        builder: (context, setState) => AlertDialog(
                          backgroundColor: Colors.white, // Set dialog background to white
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(0)), // Square corners
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
                                  border: OutlineInputBorder(),
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
                                        content: Text(
                                            'Please select a star rating.')),
                                  );
                                  return;
                                }
                                Provider.of<ItemStoreProvider>(context,
                                        listen: false)
                                    .addReview(Review(
                                  id: uuid.v4(),
                                  reviewerId: Provider.of<ItemStoreProvider>(
                                          context,
                                          listen: false)
                                      .renter
                                      .id,
                                  reviewedUserId: widget.itemRenter.ownerId,
                                  itemRenterId: widget.itemRenter.id,
                                  itemId: widget.itemRenter.itemId,
                                  rating: selectedStars,
                                  text: reviewController.text,
                                  date: DateTime.now(),
                                ));
                                // setState(() {
                                //   widget.itemRenter.status = "reviewed";
                                //   widget.status = "reviewed";
                                // });
                                // Provider.of<ItemStoreProvider>(context, listen: false).saveItemRenter(widget.itemRenter);
                                // Navigator.of(context).pop();
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
                    borderRadius:
                        BorderRadius.all(Radius.circular(0)), // Square corners
                  ),
                ),
                child: const Text('LEAVE REVIEW'),
              ),
          ],
        ),
      ),
    );
  }
}
