import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/payment_option_provider.dart';

void showPaymentOptionBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      final provider = Provider.of<PaymentOptionProvider>(context);
      return PaymentOptionBottomSheet(
        onContinue: () {
          // ScaffoldMessenger.of(context).showSnackBar(
          //   const SnackBar(
          //     content: Text('Processing payment. Please wait...'),
          //   ),
          // );
          provider.makePayment(context);
        },
      );
    },
  );
}

class PaymentOptionBottomSheet extends StatelessWidget {
  final VoidCallback onContinue;

  const PaymentOptionBottomSheet({
    super.key,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PaymentOptionProvider>(context);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Select Payment Method",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          RadioListTile<String>(
            title: const Text("Card"),
            value: "Card",
            groupValue: provider.selectedPaymentMethod,
            onChanged: provider.setPaymentMethod,
          ),
          RadioListTile<String>(
            title: const Text("PromptPay"),
            value: "PromptPay",
            groupValue: provider.selectedPaymentMethod,
            onChanged: provider.setPaymentMethod,
          ),
          RadioListTile<String>(
            title: const Text("TrueMoney"),
            value: "TrueMoney",
            groupValue: provider.selectedPaymentMethod,
            onChanged: provider.setPaymentMethod,
          ),
          RadioListTile<String>(
            title: const Text("Line Pay"),
            value: "Line Pay",
            groupValue: provider.selectedPaymentMethod,
            onChanged: provider.setPaymentMethod,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onContinue,
              child: const Text("Continue"),
            ),
          ),
        ],
      ),
    );
  }
}
