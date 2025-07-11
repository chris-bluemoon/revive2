library promptpay_qrcode_generate;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:revivals/widgets/format_amount.dart';
import 'package:revivals/widgets/generate_qrcode.dart';

void showPromptPayQRCodeBottomSheet(
  BuildContext context, {
  required String promptPayId,
  required int amount,
}) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    isScrollControlled: true,
    builder: (BuildContext context) {
      return QRCodeGenerate(
        promptPayId: promptPayId,
        amount: amount.toDouble(),
      );
    },
  );
}

class QRCodeGenerate extends StatelessWidget {
  /// The optional [amount] double default to 0 use to generate prompt-pay qr code.
  final double amount;

  /// The required [promptPayId] use to generate prompt-pay qr code.
  final String promptPayId;

  /// The optional [isShowAccountDetail] boolean defaults to true display Prompt-pay Account Detail.
  final bool isShowAccountDetail;

  /// The optional [promptPayDetailCustom] Create new Widget to display Prompt-pay Account Detail.
  final Widget? promptPayDetailCustom;

  /// The optional [isShowAmountDetail] boolean defaults to true display amount Detail.
  final bool isShowAmountDetail;

  /// The optional [promptPayDetailCustom] Create new Widget to display amount Detail.
  final Widget? amountDetailCustom;

  const QRCodeGenerate({
    super.key,
    this.amount = 0,
    required this.promptPayId,
    this.isShowAccountDetail = true,
    this.promptPayDetailCustom,
    this.isShowAmountDetail = true,
    this.amountDetailCustom,
  });

  @override
  Widget build(BuildContext context) {
    String qrCodeGenerate =
        generateQRCode(promptPayID: promptPayId, amount: amount);

    return Container(
      color: Colors.white,
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.6,
      // padding: EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.blue.shade900,
              width: double.infinity,
              child: Image.asset(
                "assets/logos/thai_qr_payment.png",
              ),
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Expanded(
            flex: 1,
            child: Image.asset(
              "assets/logos/prompt_pay_logo.png",
            ),
          ),
          Expanded(
            flex: 4,
            child: qrCodeGenerate.isNotEmpty
                ? QrImageView(
                    data: qrCodeGenerate,
                  )
                : const Align(
                    alignment: Alignment.center,
                    child: Text("PromptPay ID must have 10 or 13 character."),
                  ),
          ),
          if (isShowAccountDetail)
            promptPayDetailCustom == null
                ? Text("Account ($promptPayId)")
                : promptPayDetailCustom!,
          if (isShowAmountDetail)
            amountDetailCustom == null
                ? Text("Amount ${formatAmount(amount.toStringAsFixed(2))} Baht")
                : amountDetailCustom!,
          const SizedBox(
            height: 100,
          )
        ],
      ),
    );
  }
}
