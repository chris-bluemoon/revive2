import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/profile/profile.dart';
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

    List<Widget> buildUserList(List<String> ids) {
      final users = renters.where((r) => ids.contains(r.id)).toList();
      if (users.isEmpty) {
        return <Widget>[
          const Center(
            child: StyledBody('No users found', color: Colors.grey, weight: FontWeight.normal),
          ),
        ];
      }
      return users.map<Widget>((user) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Increased padding
          leading: CircleAvatar(
            backgroundColor: Colors.grey[300],
            backgroundImage: (user.profilePicUrl.isNotEmpty)
                ? NetworkImage(user.profilePicUrl)
                : null,
            child: (user.profilePicUrl.isEmpty)
                ? const Icon(Icons.person, color: Colors.white)
                : null,
          ),
          title: StyledHeading(user.name, weight: FontWeight.bold),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => Profile(userN: user.name, canGoBack: true,),
              ),
            );
          },
        );
      }).toList();
    }

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
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
                    log('Following user: ${user.name}, isFollowing: $isFollowing');

                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Increased padding
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        backgroundImage: (user.profilePicUrl.isNotEmpty)
                            ? NetworkImage(user.profilePicUrl)
                            : null,
                        child: (user.profilePicUrl.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
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
                    log('Following user: ${user.name}, isFollowing: $isFollowing');
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Increased padding
                      leading: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        backgroundImage: (user.profilePicUrl.isNotEmpty)
                            ? NetworkImage(user.profilePicUrl)
                            : null,
                        child: (user.profilePicUrl.isEmpty)
                            ? const Icon(Icons.person, color: Colors.white)
                            : null,
                      ),
                      title: StyledHeading(user.name, weight: FontWeight.bold),
                      trailing: !(isFollowing || user.id == Provider.of<ItemStoreProvider>(context, listen: false).renter.id)
                          ? ElevatedButton(
                              onPressed: () async {
                                final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                                final currentUser = itemStore.renter;
                                if (!currentUser.following.contains(user.id)) {
                                  currentUser.following.add(user.id);
                                  itemStore.renter.following.add(currentUser); // Update the renter in the store
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