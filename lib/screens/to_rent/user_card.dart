import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
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
        CircleAvatar(
          backgroundColor: Colors.greenAccent[400],
          radius: width * 0.06,
          child: (profilePicUrl.isEmpty)
              ? ClipOval(
                  child: Image.asset(
                    'assets/img/items/No_Image_Available.jpg',
                    width: width * 0.12,
                    height: width * 0.12,
                    fit: BoxFit.cover,
                  ),
                )
              : ClipOval(
                  child: Image.network(
                    profilePicUrl,
                    width: width * 0.12,
                    height: width * 0.12,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: SizedBox(
                          width: width * 0.06,
                          height: width * 0.06,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      // Return Image.asset directly, not inside Image.network
                      return Image.asset(
                        'assets/img/items/No_Image_Available.jpg',
                        width: width * 0.12,
                        height: width * 0.12,
                        fit: BoxFit.cover,
                      );
                    },
                  ),
                ),
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
