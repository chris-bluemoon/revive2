// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/styled_text.dart';

class DeliveryRadioWidget extends StatefulWidget {
  const DeliveryRadioWidget(this.updatePrice, this.symbol, {super.key});

  final Function(int) updatePrice;
  final String symbol;

  @override
  State<DeliveryRadioWidget> createState() => _DeliveryRadioWidget();
}

class _DeliveryRadioWidget extends State<DeliveryRadioWidget> {
  int selectedOption = 1;

  int deliveryPrice = 0;

  @override
  void initState() {
    if (Provider.of<ItemStoreProvider>(context, listen: false)
            .renter
            .location ==
        'BANGKOK') {
      deliveryPrice = 100;
    } else {
      deliveryPrice = 20;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const StyledHeading('DELIVERY OPTION'),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            title: StyledBody(
                'We will deliver at $deliveryPrice${widget.symbol}',
                weight: FontWeight.normal),
            trailing: Radio<int>(
              value: 0,
              groupValue: selectedOption,
              // fillColor: Colors.black,
              onChanged: (value) {
                setState(() {
                  selectedOption = value!;
                  widget.updatePrice(deliveryPrice);
                });
              },
            ),
          ),
          ListTile(
            dense: true,
            visualDensity: const VisualDensity(vertical: -3),
            title: const StyledBody('I will ararnge a collection',
                weight: FontWeight.normal),
            trailing: Radio<int>(
              value: 1,
              groupValue: selectedOption,
              onChanged: (value2) {
                setState(() {
                  selectedOption = value2!;
                  widget.updatePrice(0);
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
