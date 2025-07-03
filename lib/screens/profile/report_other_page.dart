import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/report.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/services/firestore_service.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

class ReportOtherPage extends StatefulWidget {
  final String reportedUserId;
  final String reportedUserName;
  
  const ReportOtherPage({
    super.key,
    required this.reportedUserId,
    required this.reportedUserName,
  });

  @override
  State<ReportOtherPage> createState() => _ReportOtherPageState();
}

class _ReportOtherPageState extends State<ReportOtherPage> {
  final TextEditingController _textController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    if (_isSubmitting || _textController.text.trim().isEmpty) return;
    
    setState(() {
      _isSubmitting = true;
    });

    try {
      final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
      final report = Report(
        id: const Uuid().v4(),
        reporterId: itemStore.renter.id,
        reportedUserId: widget.reportedUserId,
        reason: 'Other: ${_textController.text.trim()}',
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
        // Pop back to profile page (pop twice - this page and report page)
        Navigator.of(context).pop();
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
            const StyledTitle('What happened?'),
            const SizedBox(height: 16),
            const StyledBody(
              'Describe your issue',
              color: Colors.grey,
              weight: FontWeight.normal,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: _textController,
                maxLines: null,
                maxLength: 400,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                onChanged: (text) => setState(() {}), // Trigger rebuild to enable/disable button
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Tell us what happened...",
                  hintStyle: TextStyle(
                    color: Colors.grey[600],
                    fontSize: MediaQuery.of(context).size.width * 0.04,
                  ),
                  contentPadding: const EdgeInsets.all(16),
                  counterText: "${_textController.text.length}/400",
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting || _textController.text.trim().isEmpty 
                  ? null 
                  : _submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSubmitting || _textController.text.trim().isEmpty 
                    ? Colors.grey 
                    : Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const StyledHeading(
                      'Report', 
                      weight: FontWeight.bold, 
                      color: Colors.white
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
