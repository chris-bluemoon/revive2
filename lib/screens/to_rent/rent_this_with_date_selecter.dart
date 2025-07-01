// import 'dart:developer';

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/globals.dart' as globals;
import 'package:revivals/models/item.dart';
import 'package:revivals/models/item_renter.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/authenticate/sign_in_up.dart';
import 'package:revivals/screens/summary/summary_rental.dart';
import 'package:revivals/shared/get_country_price.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class RentThisWithDateSelecter extends StatefulWidget {
  const RentThisWithDateSelecter(this.item, {super.key});

  final Item item;
  // final int rentalDays;

  @override
  State<RentThisWithDateSelecter> createState() =>
      _RentThisWithDateSelecterState();
}

class _RentThisWithDateSelecterState extends State<RentThisWithDateSelecter> {
  DateTimeRange? dateRange;
  DateTime? startDate;
  DateTime? endDate;

  late int noOfDays = 0;
  // late int totalPrice = 0;
  bool bothDatesSelected = false;
  bool showConfirm = false;

  int getPricePerDay(noOfDays) {
    // Use the new rental pricing structure
    if (noOfDays <= 3) {
      return widget.item.rentPriceDaily;
    }
    
    if (noOfDays <= 5) {
      return widget.item.rentPrice3 ~/ 3;
    }
    
    if (noOfDays <= 7) {
      return widget.item.rentPrice5 ~/ 5;
    }
    
    if (noOfDays <= 14) {
      return widget.item.rentPrice7 ~/ 7;
    }
    
    if (noOfDays >= 14) {
      return widget.item.rentPrice14 ~/ 14;
    }

    return widget.item.rentPriceDaily;
  }

  List<DateTime> getBlackoutDates(String itemId, int daysToRent) {
    List<ItemRenter> itemRenters =
        Provider.of<ItemStoreProvider>(context, listen: false).itemRenters;
    List<DateTime> tempList = [];

    for (int i = 0; i < itemRenters.length; i++) {
      // Skip cancelled rentals
      if (itemRenters[i].status == "cancelledLender" || itemRenters[i].status == "cancelledRenter") {
        continue;
      }
      DateTime startDate =
          DateFormat("yyyy-MM-dd").parse(itemRenters[i].startDate);
      DateTime endDate = DateFormat("yyyy-MM-dd").parse(itemRenters[i].endDate);
      String itemIdDB = itemRenters[i].itemId;
      if (itemIdDB == itemId) {
        // Add blackout days before and after the booking
        for (int y = 0;
            y <= endDate
                .add(const Duration(days: 1)) // <-- Add 1 extra day after booking
                .difference(startDate.subtract(Duration(days: daysToRent)))
                .inDays;
            y++) {
          tempList.add(startDate
              .subtract(Duration(days: daysToRent))
              .add(Duration(days: y)));
        }
      }
    }

    log(tempList.toString());
    return tempList;
  }

  // Future pickDateRange() async {
  //   DateTimeRange? newDateRange = await showDateRangePicker(
  //     context: context,
  //     initialDateRange: dateRange,
  //     firstDate: DateTime(1900),
  //     lastDate: DateTime(2100),
  //   );
  //   if (newDateRange == null) return;
  //   setState(() => dateRange = newDateRange);
  // }

  // DateRange selectedDateRange = DateRange(DateTime.now(), DateTime.now());

  int selectedOption = -1;
  String symbol = globals.thb;
  final DateRangePickerController controller = DateRangePickerController();


  @override
  Widget build(BuildContext context) {
    // rebuildAllChildren(context);
    String country = 'BANGKOK';
    symbol = getCurrencySymbol(country);

    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: const StyledTitle('SELECT RENTAL PERIOD', weight: FontWeight.bold),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
          splashRadius: width * 0.07,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        actions: [
          IconButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            icon: Padding(
              padding: EdgeInsets.fromLTRB(0, 0, width * 0.01, 0),
              child: Icon(Icons.close, size: width * 0.06, color: Colors.black),
            ),
            splashRadius: width * 0.07,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // const Text('RENTAL TERM', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 30),
            SizedBox(height: width * 0.03),

            // Add day options
            // if (startDate == null && endDate == null)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    LayoutBuilder(
                      builder: (context, constraints) {
                        double chipWidth = (MediaQuery.of(context).size.width * 0.7).clamp(220, 400);
                        return Column(
                          children: [
                            // Show 3-day option if minDays <= 3
                            if (widget.item.minDays <= 3)
                              SizedBox(
                                width: chipWidth,
                                child: RadioListTile<int>(
                                  value: 3,
                                  groupValue: selectedOption,
                                  onChanged: (val) {
                                    setState(() {
                                      selectedOption = val!;
                                      noOfDays = 3;
                                      // Reset date selection when changing rental period or if current range doesn't meet new minimum
                                      if (startDate != null && endDate != null) {
                                        int currentDays = endDate!.difference(startDate!).inDays + 1;
                                        if (currentDays < 3) {
                                          dateRange = null;
                                          startDate = null;
                                          endDate = null;
                                          showConfirm = false;
                                          controller.selectedRange = null; // Clear the controller
                                        }
                                      }
                                    });
                                  },
                                  title: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: width * 0.042,
                                        color: Colors.black,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: '3+ days @ ',
                                        ),
                                        TextSpan(
                                          text: '${getPricePerDay(3)}$symbol',
                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                        ),
                                        const TextSpan(
                                          text: ' per day',
                                        ),
                                      ],
                                    ),
                                  ),
                                  activeColor: Colors.black,
                                  contentPadding: EdgeInsets.zero,
                                  dense: true,
                                ),
                              ),
                            // Show 5-day option if minDays <= 5
                            if (widget.item.minDays <= 5)
                              Column(
                                children: [
                                  if (widget.item.minDays <= 3)
                                    const Divider(
                                      height: 1,
                                      thickness: 2,
                                      color: Color(0xFF444444),
                                    ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: chipWidth,
                                    child: RadioListTile<int>(
                                      value: 5,
                                      groupValue: selectedOption,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedOption = val!;
                                          noOfDays = 5;
                                          // Reset date selection when changing rental period or if current range doesn't meet new minimum
                                          if (startDate != null && endDate != null) {
                                            int currentDays = endDate!.difference(startDate!).inDays + 1;
                                            if (currentDays < 5) {
                                              dateRange = null;
                                              startDate = null;
                                              endDate = null;
                                              showConfirm = false;
                                              controller.selectedRange = null; // Clear the controller
                                            }
                                          }
                                        });
                                      },
                                      title: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: width * 0.042,
                                            color: Colors.black,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: '5+ days @ ',
                                            ),
                                            TextSpan(
                                              text: '${getPricePerDay(5)}$symbol',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const TextSpan(
                                              text: ' per day',
                                            ),
                                          ],
                                        ),
                                      ),
                                      activeColor: Colors.black,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  ),
                                ],
                              ),
                            // Show 7-day option if minDays <= 7
                            if (widget.item.minDays <= 7)
                              Column(
                                children: [
                                  const Divider(
                                    height: 1,
                                    thickness: 2,
                                    color: Color(0xFF444444),
                                  ),
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: chipWidth,
                                    child: RadioListTile<int>(
                                      value: 7,
                                      groupValue: selectedOption,
                                      onChanged: (val) {
                                        setState(() {
                                          selectedOption = val!;
                                          noOfDays = 7;
                                          // Reset date selection when changing rental period or if current range doesn't meet new minimum
                                          if (startDate != null && endDate != null) {
                                            int currentDays = endDate!.difference(startDate!).inDays + 1;
                                            if (currentDays < 7) {
                                              dateRange = null;
                                              startDate = null;
                                              endDate = null;
                                              showConfirm = false;
                                              controller.selectedRange = null; // Clear the controller
                                            }
                                          }
                                        });
                                      },
                                      title: RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            fontSize: width * 0.042,
                                            color: Colors.black,
                                          ),
                                          children: [
                                            const TextSpan(
                                              text: '7+ days @ ',
                                            ),
                                            TextSpan(
                                              text: '${getPricePerDay(7)}$symbol',
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                            const TextSpan(
                                              text: ' per day',
                                            ),
                                          ],
                                        ),
                                      ),
                                      activeColor: Colors.black,
                                      contentPadding: EdgeInsets.zero,
                                      dense: true,
                                    ),
                                  ),
                                ],
                              ),
                            // Always show the 14+ days option
                            const Divider(
                              height: 1,
                              thickness: 2,
                              color: Color(0xFF444444),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: chipWidth,
                              child: RadioListTile<int>(
                                value: 14,
                                groupValue: selectedOption,
                                onChanged: (val) {
                                  setState(() {
                                    selectedOption = val!;
                                    noOfDays = 14;
                                    // Reset date selection when changing rental period or if current range doesn't meet new minimum
                                    if (startDate != null && endDate != null) {
                                      int currentDays = endDate!.difference(startDate!).inDays + 1;
                                      if (currentDays < 14) {
                                        dateRange = null;
                                        startDate = null;
                                        endDate = null;
                                        showConfirm = false;
                                        controller.selectedRange = null; // Clear the controller
                                      }
                                    }
                                  });
                                },
                                title: RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: width * 0.042,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: '14+ days @ ',
                                      ),
                                      TextSpan(
                                        text: '${getPricePerDay(14)}$symbol',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const TextSpan(
                                        text: ' per day',
                                      ),
                                    ],
                                  ),
                                ),
                                activeColor: Colors.black,
                                contentPadding: EdgeInsets.zero,
                                dense: true,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            if (selectedOption > 0)
              const SizedBox(height: 32), // <-- Add this line for more gap between chips and button
            if (selectedOption > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(0), // <-- Square corners
                      ),
                      side: const BorderSide(
                        color: Colors.black, // or your preferred border color
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    ),
                    onPressed: () async {
                      final now = DateTime.now();
                      final onlyDateToday = DateTime(now.year, now.month, now.day);
                      final onlyDateTomorrow = onlyDateToday.add(const Duration(days: 1));
                      final firstDate = onlyDateTomorrow;
                      final lastDate = onlyDateTomorrow.add(const Duration(days: 60));

                      // Get blackout dates from rentals
                      final blackoutDates = getBlackoutDates(widget.item.id, widget.item.minDays)
                          .map((d) => DateTime(d.year, d.month, d.day))
                          .toSet();

                      // Get vacation blackout dates for the item owner and add to blackoutDates
                      final vacationDates = getVacationBlackoutDates(widget.item.owner);
                      log('Vacation Dates: $vacationDates');
                      blackoutDates.addAll(vacationDates);
                      log('Blackout Dates: $blackoutDates');

                      // Find the next selectable start date
                      DateTime nextSelectable = onlyDateTomorrow;
                      while (blackoutDates.contains(nextSelectable)) {
                        nextSelectable = nextSelectable.add(const Duration(days: 1));
                      }

                      // Find the next selectable end date after start
                      DateTime nextSelectableEnd = nextSelectable.add(Duration(days: widget.item.minDays - 1));
                      while (blackoutDates.contains(nextSelectableEnd)) {
                        nextSelectableEnd = nextSelectableEnd.add(const Duration(days: 1));
                      }



                      DateTimeRange initialRange = DateTimeRange(
                        start: nextSelectable,
                        end: nextSelectableEnd,
                      );

                      DateTimeRange? picked = await showSfDateRangePicker(
                        context,
                        firstDate,
                        lastDate,
                        blackoutDates,
                        initialRange,
                      );
                      if (picked != null) {
                        int selectedDays = picked.end.difference(picked.start).inDays + 1;
                        // Check for blackout days in the selected range
                        bool hasBlackout = false;
                        for (int i = 0; i < selectedDays; i++) {
                          final d = picked.start.add(Duration(days: i));
                          if (blackoutDates.contains(DateTime(d.year, d.month, d.day))) {
                            hasBlackout = true;
                            break;
                          }
                        }
                        if (hasBlackout) {
                          setState(() {
                            dateRange = null;
                            startDate = null;
                            endDate = null;
                            showConfirm = false;
                            controller.selectedRange = null; // Clear the controller
                          });
                          return;
                        }
                        
                        // Auto-assign radio button based on selected days
                        int newSelectedOption = selectedOption;
                        if (selectedDays >= 14) {
                          newSelectedOption = 14;
                        } else if (selectedDays >= 7 && widget.item.minDays <= 7) {
                          newSelectedOption = 7;
                        } else if (selectedDays >= 5 && widget.item.minDays <= 5) {
                          newSelectedOption = 5;
                        } else if (selectedDays >= 3 && widget.item.minDays <= 3) {
                          newSelectedOption = 3;
                        }
                        
                        setState(() {
                          dateRange = picked;
                          startDate = picked.start;
                          endDate = picked.end;
                          noOfDays = selectedDays;
                          selectedOption = newSelectedOption; // Update radio button selection
                          showConfirm = true;
                        });
                      } else {
                        // User cancelled - reset the date selection to ensure consistency
                        setState(() {
                          dateRange = null;
                          startDate = null;
                          endDate = null;
                          showConfirm = false;
                          controller.selectedRange = null; // Clear the controller
                        });
                      }
                    },
                    child: StyledBody(
                      (startDate != null && endDate != null)
                          ? '${DateFormat('dd MMM yyyy').format(startDate!)} - ${DateFormat('dd MMM yyyy').format(endDate!)}'
                          : 'SELECT DATES', // <-- Changed to all capitals
                      weight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
        ],
      ),
    ),
    bottomNavigationBar: (startDate != null && endDate != null)
        ? SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                    height: 48,
                    width: 120, // Shorter width for the button
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0), // Square corners
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      child: const Text(
                        'NEXT',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.1,
                        ),
                      ),
                      onPressed: () {
                        bool loggedIn = Provider.of<ItemStoreProvider>(context, listen: false).loggedIn;
                        log('No of days: $noOfDays');
                        int totalPrice = getPricePerDay(noOfDays) * noOfDays;
                        int days = startDate!.difference(endDate!).inDays.abs() + 1;
                        if (loggedIn) {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => SummaryRental(
                              widget.item,
                              startDate!,
                              endDate!,
                              days,
                              totalPrice,
                              'requested',
                              symbol,
                            ),
                          ));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const GoogleSignInScreen(),
                          ));
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
          )
        : null,
  );
  }

  Future<DateTimeRange?> showSfDateRangePicker(
  BuildContext context,
  DateTime firstDate,
  DateTime lastDate,
  Set<DateTime> blackoutDates,
  DateTimeRange initialRange,
) async {
  DateTimeRange? pickedRange;
  DateTime? start = initialRange.start;
  DateTime? end = initialRange.end;
  Set<DateTime> dynamicBlackoutDates = {...blackoutDates};
  int minDays = selectedOption > 0 ? selectedOption : widget.item.minDays;    await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.zero, // <-- Square corners
            ),
            title: const Text('Select Rental Dates'),
            content: SizedBox(
              width: 350,
              height: 400,
              child: SfDateRangePicker(
                controller: controller,
                // initialSelectedRange: selectedRange, // <-- Removed
                minDate: firstDate,
                maxDate: lastDate,
                selectionMode: DateRangePickerSelectionMode.range,
                enablePastDates: false,
                backgroundColor: Colors.white,
                viewSpacing: 0,
                headerStyle: const DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  backgroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.black,
                  ),
                ),
                monthViewSettings: DateRangePickerMonthViewSettings(
                  blackoutDates: dynamicBlackoutDates.toList(),
                ),
                monthCellStyle: const DateRangePickerMonthCellStyle(
                  blackoutDateTextStyle: TextStyle(
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
                selectionShape: DateRangePickerSelectionShape.circle, // <-- Make selection circular
                startRangeSelectionColor: Colors.black,
                endRangeSelectionColor: Colors.black,
                rangeSelectionColor: Colors.black12,
                todayHighlightColor: Colors.black,
                selectionColor: Colors.black,
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is PickerDateRange) {
                    final PickerDateRange range = args.value;
                    if (range.startDate != null) {
                      start = range.startDate;
                      setState(() {
                        dynamicBlackoutDates = {...blackoutDates};
                      });
                    }
                    if (range.endDate != null) {
                      end = range.endDate;
                      int selectedDays = end!.difference(start!).inDays + 1;

                      // Check if any blackout date is in the selected range
                      bool hasBlackout = false;
                      DateTime temp = start!;
                      while (!temp.isAfter(end!)) {
                        if (dynamicBlackoutDates.contains(DateTime(temp.year, temp.month, temp.day))) {
                          hasBlackout = true;
                          break;
                        }
                        temp = temp.add(const Duration(days: 1));
                      }

                      // Only enforce minimum days if there are NO blackout days in the range
                      if (!hasBlackout && selectedDays < minDays) {
                        end = start!.add(Duration(days: minDays - 1));
                        controller.selectedRange = PickerDateRange(start, end);
                        setState(() {});
                        return;
                      }

                      if (hasBlackout) {
                        // Reset selection to single day (end date)
                        start = end;
                        controller.selectedRange = PickerDateRange(start, end);
                        setState(() {});
                      } else {
                        setState(() {});
                      }
                    } else {
                      setState(() {});
                    }
                  }
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'CANCEL',
                  style: TextStyle(color: Colors.black), // <-- Black text
                ),
              ),
              TextButton(
                onPressed: () {
                  if (start != null && end != null) {
                    pickedRange = DateTimeRange(start: start!, end: end!);
                  }
                  Navigator.pop(context);
                },
                child: const Text(
                  'OK',
                  style: TextStyle(color: Colors.black), // <-- Black text
                ),
              ),
            ],
          );
        },
      );
    },
  );
  return pickedRange;
}

// Add this helper to get all vacation blackout dates for the owner
List<DateTime> getVacationBlackoutDates(String ownerId) {
  final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
  // Find the owner by ID - use nullable approach
  log('Owner ID: $ownerId');
  final Renter? owner = itemStore.renters.cast<Renter?>().firstWhere(
    (user) => user?.id == ownerId,
    orElse: () => null,
  );
  
  log('Owner: ${owner?.name ?? 'Unknown'}, Vacations: ${owner?.vacations ?? []}');
  if (owner?.vacations == null) return [];
  
  final vacations = owner!.vacations;
  List<DateTime> vacationDates = [];
  for (final vacation in vacations) {
    final startRaw = vacation['startDate'];
    final endRaw = vacation['endDate'];
    if (startRaw != null && endRaw != null) {
      DateTime start = startRaw;
      DateTime end = endRaw;
      for (DateTime d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
        vacationDates.add(DateTime(d.year, d.month, d.day));
      }
    }
  }
  log('Vacation Dates: $vacationDates');
  return vacationDates;
}}