import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/profile_avatar.dart';
import 'package:revivals/shared/styled_text.dart';

class UserCard extends StatelessWidget {
  const UserCard(this.ownerName, this.location, {super.key});

  final String ownerName;
  final String location;

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    String initialLetter = ownerName.substring(0, 1);

    // Get the correct renter from the provider using ownerName
    final renters = Provider.of<ItemStoreProvider>(context, listen: false).renters;
    final ownerList = renters.where((r) => r.name == ownerName).toList();
    final owner = ownerList.isNotEmpty ? ownerList.first : null;
    final profilePicUrl = owner?.profilePicUrl ?? '';

    return Row(
      children: [
        ProfileAvatar(
          imageUrl: profilePicUrl,
          userName: ownerName,
          radius: width * 0.06,
        ),
        SizedBox(width: width * 0.02),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StyledBody(ownerName),
            StyledBody(location, weight: FontWeight.normal)
          ],
        ),
        SizedBox(width: width * 0.03),
      ],
    );
  }
}
