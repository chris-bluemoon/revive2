import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/providers/set_price_provider.dart';
import 'package:revivals/screens/create/create_item.dart';
import 'package:revivals/shared/smooth_page_route.dart';

class CreateItemTemp extends StatefulWidget {
  const CreateItemTemp({super.key});

  @override
  State<CreateItemTemp> createState() => _CreateItemTempState();
}

class _CreateItemTempState extends State<CreateItemTemp> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to ensure navigation happens after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear pricing provider for new item creation
      final spp = Provider.of<SetPriceProvider>(context, listen: false);
      spp.clearAllFields();
      
      Navigator.of(context).pushReplacement(
        SmoothTransitions.luxury(const CreateItem(item: null,)),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // Placeholder while navigating
    final userName = Provider.of<ItemStoreProvider>(context, listen: false).renter.name;
    log('Current userName: $userName');
    if (userName == 'no_user') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/sign_in');
      });
      return const SizedBox.shrink();
    }
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}



