import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';


class VacationDatesPage extends StatefulWidget {
  const VacationDatesPage({super.key});

  @override
  State<VacationDatesPage> createState() => _VacationDatesPageState();
}

class _VacationDatesPageState extends State<VacationDatesPage> {
  DateTime? startDate;
  DateTime? endDate;

  Future<void> _selectDateRange() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 365 * 2));

    // Get current user's vacation blackout dates
    final renter = Provider.of<ItemStoreProvider>(context, listen: false).renter;
    final vacations = renter.vacations ?? [];
    Set<DateTime> blackoutDates = {};
    for (final vacation in vacations) {
      final startRaw = vacation['startDate'];
      final endRaw = vacation['endDate'];
      if (startRaw != null && endRaw != null) {
        DateTime start = startRaw is DateTime ? startRaw : DateTime.parse(startRaw.toString());
        DateTime end = endRaw is DateTime ? endRaw : DateTime.parse(endRaw.toString());
        for (DateTime d = start; !d.isAfter(end); d = d.add(const Duration(days: 1))) {
          blackoutDates.add(DateTime(d.year, d.month, d.day));
        }
      }
    }

    DateTimeRange? picked;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        DateTime? tempStart = startDate;
        DateTime? tempEnd = endDate;
        String? errorText;
        return StatefulBuilder(
          builder: (context, setState) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Colors.black,
                  onPrimary: Colors.white,
                ),
                textButtonTheme: TextButtonThemeData(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                  ),
                ),
                dialogTheme: const DialogThemeData(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(0)),
                  ),
                ),
              ),
              child: AlertDialog(
                backgroundColor: Colors.white,
                content: SizedBox(
                  height: 370,
                  width: 350,
                  child: Column(
                    children: [
                      SfDateRangePicker(
                        backgroundColor: Colors.white,
                        initialSelectedRange: startDate != null && endDate != null
                            ? PickerDateRange(startDate, endDate)
                            : null,
                        selectionMode: DateRangePickerSelectionMode.range,
                        minDate: firstDate,
                        maxDate: lastDate,
                        onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                          if (args.value is PickerDateRange) {
                            final PickerDateRange range = args.value;
                            tempStart = range.startDate;
                            tempEnd = range.endDate;
                            errorText = null;
                            // Check if the selected range spans any blackout dates
                            if (tempStart != null && tempEnd != null) {
                              bool hasBlackout = false;
                              for (DateTime d = tempStart!;
                                  !d.isAfter(tempEnd!);
                                  d = d.add(const Duration(days: 1))) {
                                if (blackoutDates.contains(DateTime(d.year, d.month, d.day))) {
                                  hasBlackout = true;
                                  break;
                                }
                              }
                              if (hasBlackout) {
                                errorText = "Selection cannot include blackout dates.";
                                tempStart = null;
                                tempEnd = null;
                              }
                            }
                            setState(() {});
                          }
                        },
                        selectionColor: Colors.black,
                        rangeSelectionColor: Colors.black.withOpacity(0.2),
                        startRangeSelectionColor: Colors.black,
                        endRangeSelectionColor: Colors.black,
                        todayHighlightColor: Colors.black,
                        monthViewSettings: DateRangePickerMonthViewSettings(
                          viewHeaderStyle: const DateRangePickerViewHeaderStyle(
                            backgroundColor: Colors.white,
                          ),
                          blackoutDates: blackoutDates.toList(),
                        ),
                        headerStyle: const DateRangePickerHeaderStyle(
                          textAlign: TextAlign.center,
                          backgroundColor: Colors.white,
                          textStyle: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        monthCellStyle: const DateRangePickerMonthCellStyle(
                          blackoutDateTextStyle: TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ),
                      if (errorText != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            errorText!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('CANCEL'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (tempStart != null && tempEnd != null) {
                        picked = DateTimeRange(start: tempStart!, end: tempEnd!);
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (picked != null) {
      setState(() {
        startDate = picked!.start;
        endDate = picked!.end;
      });
    }
    }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, yyyy');
    return Scaffold(
      appBar: AppBar(
        // title: Text('Vacation Dates'),
        // centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select your vacation period:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            GestureDetector(
              onTap: _selectDateRange,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: Colors.black54),
                    const SizedBox(width: 12),
                    Text(
                      (startDate != null && endDate != null)
                          ? 'From: ${dateFormat.format(startDate!)}  To: ${dateFormat.format(endDate!)}'
                          : 'Select Vacation Dates',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                onPressed: endDate != null
                    ? () async {
                        // Get the current renter (replace with your actual retrieval logic)
                        Renter renter = Provider.of<ItemStoreProvider>(context, listen: false).renter;
                        
                        // Add the new vacation period
                        renter.vacations = [
                          ...renter.vacations,
                          {
                            'startDate': startDate!,
                            'endDate': endDate!,
                          }
                        ];

                        // Save to Firestore (replace with your actual update logic)
                        Provider.of<ItemStoreProvider>(context, listen: false)
                            .saveRenterNoEmail(renter);
                        Navigator.of(context).pop({'start': startDate, 'end': endDate});
                      }
                    : null,
                child: const Text('SAVE'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}