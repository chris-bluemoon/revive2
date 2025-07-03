import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/report.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/services/firestore_service.dart';
import 'package:revivals/shared/smooth_page_route.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

import 'report_other_page.dart';

class ReportPage extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;
  
  const ReportPage({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  bool _isSubmitting = false;

  final List<String> _reportReasons = [
    'User is asking for payment outside the app',
    'User has damaged or lost an item',
    'User is inappropriate',
    'User is unresponsive',
    'Other'
  ];

  Future<void> _submitReport(String reason) async {
    if (_isSubmitting) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
      final report = Report(
        id: const Uuid().v4(),
        reporterId: itemStore.renter.id,
        reportedUserId: widget.reportedUserId,
        reason: reason,
        timestamp: DateTime.now(),
      );

      await FirestoreService.submitReport(report);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Report submitted successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error submitting report: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: StyledTitle('Report ${widget.reportedUserName}'),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const StyledTitle('Tell us more'),
            const SizedBox(height: 16),
            const StyledBody(
              'This will only be shared with our support team. We aim to get back to you within 24 hours.',
              color: Colors.grey,
              weight: FontWeight.normal,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: _reportReasons.length,
                separatorBuilder: (context, index) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final reason = _reportReasons[index];
                  final isOtherOption = reason == 'Other';
                  
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      title: StyledBody(
                        reason,
                        color: Colors.black,
                        weight: FontWeight.normal,
                      ),
                      trailing: isOtherOption 
                        ? (_isSubmitting 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.chevron_right, color: Colors.grey))
                        : (_isSubmitting 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : null),
                      onTap: _isSubmitting 
                        ? null 
                        : isOtherOption
                          ? () {
                              Navigator.of(context).push(
                                SmoothTransitions.luxury(ReportOtherPage(
                                  reportedUserId: widget.reportedUserId,
                                  reportedUserName: widget.reportedUserName,
                                )),
                              );
                            }
                          : () => _submitReport(reason),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
