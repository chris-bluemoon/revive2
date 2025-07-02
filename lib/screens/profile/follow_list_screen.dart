import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/profile/profile.dart';
import 'package:revivals/shared/profile_avatar.dart';
import 'package:revivals/shared/styled_text.dart';

class FollowListScreen extends StatefulWidget {
  final List<String> followersIds;
  final List<String> followingIds;

  const FollowListScreen({
    required this.followersIds,
    required this.followingIds,
    super.key,
  });

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  @override
  Widget build(BuildContext context) {
    final renters = Provider.of<ItemStoreProvider>(context, listen: false).renters;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: MediaQuery.of(context).size.width * 0.2,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: MediaQuery.of(context).size.width * 0.08),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          bottom: const TabBar(
            labelColor: Colors.black, // Selected tab text color
            unselectedLabelColor: Colors.grey, // Unselected tab text color
            indicatorColor: Colors.black, // Highlight underscore bar color
            tabs: [
              Tab(text: 'Followers'),
              Tab(text: 'Following'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // First tab: Followers
            Builder(
              builder: (context) {
                final followersList = renters.where((r) => widget.followersIds.contains(r.id)).toList();
                
                if (followersList.isEmpty) {
                  return Center(
                    child: Text(
                      'No Current Followers',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: followersList.length,
                  itemBuilder: (context, index) {
                    final user = followersList[index];
                    final isFollowing = Provider.of<ItemStoreProvider>(context, listen: false).renter.following.contains(user.id);

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      leading: ProfileAvatar(
                        imageUrl: user.profilePicUrl,
                        userName: user.name,
                        radius: 20,
                      ),
                      title: StyledHeading(user.name, weight: FontWeight.bold),
                      trailing: !(isFollowing || user.id == Provider.of<ItemStoreProvider>(context, listen: false).renter.id)
                          ? ElevatedButton(
                              onPressed: () async {
                                final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                                setState(() {
                                  itemStore.renter.following!.add(user.id);
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              child: const Text('FOLLOW'),
                            )
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Profile(userN: user.name, canGoBack: true,),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
            // Second tab: Following
            Builder(
              builder: (context) {
                final followingList = renters.where((r) => widget.followingIds.contains(r.id)).toList();
                if (followingList.isEmpty) {
                  return Center(
                    child: Text(
                      'Not Following Anyone',
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: followingList.length,
                  itemBuilder: (context, index) {
                    final user = followingList[index];
                    final isFollowing = Provider.of<ItemStoreProvider>(context, listen: false).renter.following.contains(user.id);
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      leading: ProfileAvatar(
                        imageUrl: user.profilePicUrl,
                        userName: user.name,
                        radius: 20,
                      ),
                      title: StyledHeading(user.name, weight: FontWeight.bold),
                      trailing: !(isFollowing || user.id == Provider.of<ItemStoreProvider>(context, listen: false).renter.id)
                          ? ElevatedButton(
                              onPressed: () async {
                                final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                                final currentUser = itemStore.renter;
                                if (!currentUser.following.contains(user.id)) {
                                  currentUser.following.add(user.id);
                                  itemStore.renter.following.add(currentUser.id); // Fixed: should add user ID, not user object
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                textStyle: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              child: const Text('FOLLOW'),
                            )
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => Profile(userN: user.name, canGoBack: true,),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}