import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/messages/message_conversation_page.dart';
import 'package:revivals/screens/profile/account/account_page.dart';
import 'package:revivals/screens/profile/admin/admin_page.dart';
import 'package:revivals/screens/profile/follow_list_screen.dart';
import 'package:revivals/screens/profile/lender_dashboard/lender_dashboard.dart';
import 'package:revivals/screens/profile/notifications/notifications_page.dart';
import 'package:revivals/screens/profile/renter_dashboard/renter_dashboard.dart';
import 'package:revivals/screens/to_rent/to_rent.dart';
import 'package:revivals/services/notification_service.dart';
import 'package:revivals/settings.dart';
import 'package:revivals/shared/item_results.dart';
import 'package:revivals/shared/line.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:share_plus/share_plus.dart'; // Add this import at the top

import 'edit_profile_page.dart';

class Profile extends StatefulWidget {
  final String? userN;
  final bool canGoBack;
  const Profile({this.userN, required this.canGoBack, super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Map<String, Future<String?>> _imageUrlFutures = {}; // <-- Add this

  String userName = '';

  // 1. Add a state variable at the top of _ProfileState:
  bool notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Don't set userName here - it will be determined dynamically in build()
    if (widget.userN != null && widget.userN!.isNotEmpty) {
      userName = widget.userN!;
      log('Showing profile for specific user: $userName');
    }
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String? getFirstImageUrl(dynamic imageId) {
    log('getFirstImageUrl called with imageId: $imageId');
    if (imageId == null) return null;
    if (imageId is String && (imageId.startsWith('http://') || imageId.startsWith('https://'))) {
      return imageId;
    }
    if (imageId is Map && imageId['url'] != null && (imageId['url'] as String).startsWith('http')) {
      return imageId['url'];
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final itemStore = Provider.of<ItemStoreProvider>(context);
    final List<Renter> myRenters = itemStore.renters;
    
    // Determine profile owner - if no userN specified, it's the current user's profile
    Renter? profileOwner;
    bool isOwnProfile = false;
    
    if (widget.userN == null || widget.userN!.isEmpty) {
      // This is the current logged-in user's profile
      final currentUser = itemStore.renter;
      profileOwner = currentUser;
      isOwnProfile = itemStore.loggedIn;
      userName = currentUser.name; // Always update userName to current user's name
      log('Showing own profile: ${currentUser.name}, ID: ${currentUser.id}, email: ${currentUser.email}');
    } else {
      // This is another user's profile, find by name
      final List<Renter> ownerList = myRenters.where((r) => r.name == userName).toList();
      profileOwner = ownerList.isNotEmpty ? ownerList.first : null;
      final currentRenter = itemStore.renter;
      final isLoggedIn = itemStore.loggedIn;
      isOwnProfile = isLoggedIn && currentRenter.name == userName;
      log('Showing other user profile: $userName');
    }

    // Redirect to authenticate if userName is still 'no_user' after determining profile owner
    log('Current userName: $userName');
    if (userName == 'no_user') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/sign_in');
      });
      return const SizedBox.shrink();
    }
    
    final String profileOwnerId = profileOwner?.id ?? itemStore.renter.id;
    log('Profile Owner ID: ${profileOwner?.bio}');

    // currentRenter is already available from the logic above
    final currentRenter = itemStore.renter;
    final isLoggedIn = itemStore.loggedIn;
    if (profileOwner == null) {
      return const Center(
        child: StyledBody(
          'User not found',
          color: Colors.red,
          weight: FontWeight.bold,
        ),
      );
    }

    final items = itemStore.items;
    final myItemsCount = items.where((item) => item.owner == profileOwner?.id && item.status != 'deleted').length;

    return Scaffold(
      appBar: AppBar(
        leading: widget.canGoBack
            ? IconButton(
                icon: Icon(Icons.chevron_left, size: width * 0.08),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,
        title: StyledTitle(profileOwner.name),
        actions: isOwnProfile
            ? [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // Actions menu logic
                    showModalBottomSheet(
                      backgroundColor: Colors.white,
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      builder: (context) => DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.85,
                        minChildSize: 0.5,
                        maxChildSize: 0.95,
                        builder: (context, scrollController) => Column(
                          children: [
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              width: 40,
                              height: 4,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Expanded(
                              child: ListView(
                                controller: scrollController,
                                children: [
                                  // ListTile(
                                  //   leading: const Icon(Icons.settings),
                                  //   title: const Text('Settings'),
                                  //   onTap: () {
                                  //     Navigator.pop(context);
                                  //     Navigator.push(
                                  //       context,
                                  //       MaterialPageRoute(builder: (context) => const SettingsPage()),
                                  //     );
                                  //   },
                                  // ),
                                  ListTile(
                                    leading: const Icon(Icons.group_add),
                                    title: const Text('Invite Friends'),
                                    onTap: () async {
                                      const shareText = 'Check out Revive! Download the app here: https://your-app-link.com';
                                      await Share.share(shareText);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.account_circle),
                                    title: const Text('Account'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const AccountPage()),
                                      );
                                    },
                                  ),
                                  // 2. In your ListView of the modal bottom sheet, replace the Notifications ListTile with a SwitchListTile:
                                  ListTile(
                                    leading: const Icon(Icons.account_circle),
                                    title: const Text('Notifications'),
                                    onTap: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const NotificationsPage()),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.list),
                                    title: const Text('My Listings'),
                                    onTap: () {
                                      Navigator.push(context,
                                        MaterialPageRoute(builder: (context) => ItemResults('myItems', profileOwnerId)),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.dashboard),
                                    title: const Text('Renter Dashboard'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const RenterDashboard()),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.dashboard),
                                    title: const Text('Lender Dashboard'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const LenderDashboard()),
                                      );
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.favorite),
                                    title: const Text('Favourites'),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => const SettingsPage()),
                                      );
                                    }
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.chat),
                                    title: const Text('Chat With Us'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await chatWithUsLine(context);
                                    },
                                  ),
                                  ListTile(
                                    leading: const Icon(Icons.logout),
                                    title: const Text('Log Out'),
                                    onTap: () async {
                                      Navigator.pop(context);
                                      await logOut(context);
                                    },
                                  ),
                                  // --- Admin menu item ---
                                  if (Provider.of<ItemStoreProvider>(context, listen: false).renter.type == "ADMIN")
                                    ListTile(
                                      leading: const Icon(Icons.admin_panel_settings),
                                      title: const Text('Admin'),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                            MaterialPageRoute(builder: (context) => const AdminPage()),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ));
                  },
                ),
              ]
            : [],
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          const SizedBox(height: 24),
          // Profile picture and stats
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: width * 0.06),
                CircleAvatar(
                  radius: width * 0.09,
                  backgroundColor: Colors.grey[300],
                  child: profileOwner.profilePicUrl.isEmpty
                      ? Icon(Icons.person, size: width * 0.09, color: Colors.white)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(width * 0.09),
                          child: Image.network(
                            profileOwner.profilePicUrl,
                            fit: BoxFit.cover,
                            width: width * 0.18,
                            height: width * 0.18,
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
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.person, size: width * 0.09, color: Colors.white),
                          ),
                        ),
                ),
                SizedBox(width: width * 0.04),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Items count
                      GestureDetector(
                        onTap: null,
                        child: Column(
                          children: [
                            StyledHeading(myItemsCount.toString(), weight: FontWeight.bold),
                            const SizedBox(height: 2),
                            const StyledBody("Items", color: Colors.black, weight: FontWeight.normal),
                          ],
                        ),
                      ),
                      // Following count
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FollowListScreen(
                                followersIds: profileOwner?.following ?? [],
                                followingIds: profileOwner?.followers ?? [],
                              ),
                            ),
                          );
                          setState(() {});
                        },
                        child: Column(
                          children: [
                            StyledHeading(
                              profileOwner.following.length.toString(),
                              weight: FontWeight.bold,
                            ),
                            const SizedBox(height: 2),
                            const StyledBody("Following", color: Colors.black, weight: FontWeight.normal),
                          ],
                        ),
                      ),
                      // Followers count
                      GestureDetector(
                        onTap: () {Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => FollowListScreen(
                                followersIds: profileOwner?.following ?? [],
                                followingIds: profileOwner?.followers ?? [],
                              ),
                            ),
                          );
                          setState(() {});
                        },
                        child: Column(
                          children: [
                            StyledHeading(
                              profileOwner.followers.length.toString(),
                              weight: FontWeight.bold,
                            ),
                            const SizedBox(height: 2),
                            const StyledBody("Followers", color: Colors.black, weight: FontWeight.normal),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          // Name, Location, and bio
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.08),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 2),
                if (profileOwner.location.isNotEmpty)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.location_on, color: Colors.grey[700] ?? Colors.grey, size: width * 0.05),
                      const SizedBox(width: 6),
                      Expanded(
                        child: StyledBody(
                          profileOwner.location,
                          color: Colors.grey[700] ?? Colors.grey,
                          weight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                if (profileOwner.location.isNotEmpty)
                  const SizedBox(height: 6), // <-- Add this gap
              // --- Add Last seen row here ---
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey[700] ?? Colors.grey, size: width * 0.05),
                  const SizedBox(width: 6),
                  StyledBody(
                    'Last seen: ${formatLastSeen(profileOwner.lastLogin)}',
                    color: Colors.grey[700] ?? Colors.grey,
                    weight: FontWeight.normal,
                  ),
                ],
              ),
              // --- End Last seen row ---
              // --- Add avgReview display here ---
              const SizedBox(height: 6),
              Builder(
                builder: (context) {
                  final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                  final reviews = itemStore.reviews.where(
                    (review) => review.reviewedUserId == profileOwner?.id,
                  ).toList();
                  if (reviews.isEmpty) {
                    return const StyledBody(
                      'No reviews yet',
                      color: Colors.grey,
                      weight: FontWeight.normal,
                    );
                  }
                  return Row(
                    children: [
                      Icon(Icons.star, color: Colors.amber, size: width * 0.05),
                      const SizedBox(width: 6),
                      StyledBody(
                        (profileOwner?.avgReview ?? 0.0).toStringAsFixed(1),
                        color: Colors.black,
                        weight: FontWeight.bold,
                      ),
                      const SizedBox(width: 4),
                      StyledBody(
                        '/ 5.0',
                        color: Colors.grey[700] ?? Colors.grey,
                        weight: FontWeight.normal,
                      ),
                    ],
                  );
                },
              ),
              // --- End avgReview display ---
                const SizedBox(height: 4),
                Center(
                  child: StyledBody(
                    profileOwner.bio,
                    color: Colors.black,
                    weight: FontWeight.normal,
                  ),
                ),
                // Show EDIT button if viewing own profile, otherwise show FOLLOW/UNFOLLOW and MESSAGE
                if (isOwnProfile)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                          if (profileOwner != null) {
                            final updatedRenter = await Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => EditProfilePage(renter: profileOwner!),
                              ),
                            );
                            if (updatedRenter != null) {
                              final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);

                              // Update in renters list
                              final index = itemStore.renters.indexWhere((r) => r.id == updatedRenter.id);
                              if (index != -1) {
                                itemStore.renters[index] = updatedRenter;
                              }
                            }

                            // Update current renter if it's the same user
                            if (itemStore.renter.id == updatedRenter.id) {
                              itemStore.renter.name = updatedRenter.name;
                              itemStore.renter.bio = updatedRenter.bio;
                              itemStore.renter.profilePicUrl = updatedRenter.profilePicUrl;
                              itemStore.renter.location = updatedRenter.location;
                              itemStore.renter.followers = updatedRenter.followers;
                              itemStore.renter.following = updatedRenter.following;
                              // Add any other fields that need to be updated
                            }

                            setState(() {}); // Refresh UI
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: const BorderSide(width: 1.0, color: Colors.black),
                        ),
                        child: const StyledHeading('EDIT PROFILE', weight: FontWeight.bold),
                      ),
                    ),
                  )
                else if (isLoggedIn)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => MessageConversationPage(
                                    currentUserId: currentRenter.id,
                                    otherUserId: profileOwner?.id ?? '',
                                    otherUser: {
                                      'name': profileOwner?.name ?? '',
                                      'profilePicUrl': profileOwner?.profilePicUrl ?? '',
                                    },
                                  ),
                                ),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(width: 1.0, color: Colors.black),
                            ),
                            child: const StyledHeading('MESSAGE', weight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () async {
                              // Implement follow/unfollow logic
                              final isFollowing = profileOwner?.followers.contains(currentRenter.id) ?? false;
                              final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);

                              if (profileOwner != null) {
                                if (isFollowing) {
                                  // UNFOLLOW: Remove profileOwner.id from current user's following
                                  itemStore.renter.following?.remove(profileOwner.id);
                                  profileOwner.followers.remove(currentRenter.id);
                                } else {
                                  // FOLLOW: Add profileOwner.id to current user's following
                                  itemStore.renter.following ??= [];
                                  itemStore.renter.following!.add(profileOwner.id);
                                  profileOwner.followers.add(currentRenter.id);
                                }

                                // Optionally, persist changes to backend here
                                itemStore.saveRenter(itemStore.renter);
                                itemStore.saveRenter(profileOwner);
                              }

                              setState(() {});
                            },
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              side: const BorderSide(width: 1.0, color: Colors.black),
                            ),
                            child: StyledHeading(
                              profileOwner.followers.contains(currentRenter.id) ? 'UNFOLLOW' : 'FOLLOW',
                              weight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Divider(thickness: 1, color: Colors.grey[300]),
          // --- Tabs Section ---
          SizedBox(
            height: 48,
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.black,
              tabs: const [
                Tab(text: 'ITEMS'),
                Tab(text: 'SAVED'),
                Tab(text: 'REVIEWS'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // ITEMS tab
                Builder(
                  builder: (context) {
                    final myItems = items.where((item) {
                      final isOwner = isOwnProfile;
                      if (item.owner != profileOwner?.id) return false;
                      if (item.status == 'accepted') return true;
                      if (item.status == 'submitted' && isOwner) return true;
                      return false;
                    }).toList();
                    if (myItems.isEmpty) {
                      return const Center(
                        child: StyledBody(
                          'No items yet',
                          color: Colors.grey,
                          weight: FontWeight.normal,
                        ),
                      );
                    }
                    return ListView.separated(
                      itemCount: myItems.length,
                      separatorBuilder: (context, i) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final item = myItems[i];
                        final dynamic imageId = (item.imageId != null && item.imageId.isNotEmpty) ? item.imageId[0] : null;

                        bool isDirectUrl(dynamic id) =>
                            id is String && (id.startsWith('http://') || id.startsWith('https://'));
                        bool isMapWithUrl(dynamic id) =>
                            id is Map && id['url'] != null && (id['url'] as String).startsWith('http');

                        Widget imageWidget;

                        if (isDirectUrl(imageId)) {
                          imageWidget = ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              imageId,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                          );
                        } else if (isMapWithUrl(imageId)) {
                          final url = imageId['url'];
                          imageWidget = ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              url,
                              width: 56,
                              height: 56,
                              fit: BoxFit.cover,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              },
                            ),
                          );
                        } else if (imageId is String && imageId.isNotEmpty) {
                          _imageUrlFutures[imageId] ??= getDownloadUrlFromPath(imageId);
                          imageWidget = FutureBuilder<String?>(
                            future: _imageUrlFutures[imageId],
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                );
                              }
                              final url = snapshot.data;
                              if (url != null) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    url,
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return const Center(
                                        child: SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                              return Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image, color: Colors.white),
                              );
                            },
                          );
                        } else {
                          imageWidget = Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.image, color: Colors.white),
                          );
                        }

                        return GestureDetector(
                          onTap: () async {
                            // Check if current profile is the owner of the item
                            if (item.owner == profileOwnerId) {
                              log("Item owner is the current profile, navigating to edit page");
                              log(item.owner.toString());
                              log((profileOwner?.id ?? '').toString());
                              final result = await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ToRent(item),
                                ),
                              );
                              if (result == true) {
                                setState(() {});
                              }
                            } else {
                              await Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ToRent(item), // Make sure ToRent accepts the item
                                ),
                              );
                            }
                          },
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            leading: SizedBox(
                              width: 56,
                              height: 56,
                              child: imageWidget,
                            ),
                            title: StyledHeading(item.name, weight: FontWeight.bold),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StyledBody('฿${item.rentPriceDaily} per day', color: Colors.black, weight: FontWeight.normal),
                                StyledBody('${item.type}', color: Colors.grey[700] ?? Colors.grey, weight: FontWeight.normal),
                                // StyledBody('Status: ${item.status}', color: Colors.blueGrey, weight: FontWeight.normal), // <-- Added line
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
                // SAVED tab
                const Center(
                  child: StyledBody(
                    'No saved items yet',
                    color: Colors.grey,
                    weight: FontWeight.normal,
                  ),
                ),
                // REVIEWS tab
                Builder(
                  builder: (context) {
                    final itemStore = Provider.of<ItemStoreProvider>(context);

                    // Filter reviews where reviewedUserId matches the profile owner's id
                    final reviews = itemStore.reviews.where(
                      (review) => review.reviewedUserId == profileOwner?.id,
                    ).toList();

                    if (reviews.isEmpty) {
                      return const Center(
                        child: StyledBody(
                          'No reviews yet',
                          color: Colors.grey,
                          weight: FontWeight.normal,
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: reviews.length,
                      separatorBuilder: (context, i) => const Divider(height: 1),
                      itemBuilder: (context, i) {
                        final review = reviews[i];
                        final reviewer = itemStore.renters.firstWhere(
                          (r) => r.id == review.reviewerId,
                          orElse: () => Renter(
                            id: '',
                            name: 'Unknown',
                            imagePath: '',
                            bio: '',
                            location: '',
                            followers: [],
                            following: [],
                            avgReview: 0.0,
                            email: '',
                            type: '',
                            size: 0,
                            address: '',
                            countryCode: '',
                            phoneNum: '',
                            favourites: [],
                            verified: 'false',
                            creationDate: DateTime.now().toString(),
                            status:'not active', 
                            lastLogin: DateTime.now(), 
                            vacations: [], // <-- Added status field
                          ),
                        );
                        final reviewerPic = reviewer?.profilePicUrl ?? '';
                        final reviewerName = reviewer?.name ?? 'Unknown';

                        return GestureDetector(
                          onTap: () {
                            if (reviewer.id.isNotEmpty) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) => Profile(userN: reviewer.name, canGoBack: true,),
                                ),
                              );
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 22,
                                  backgroundColor: Colors.grey[300],
                                  backgroundImage: (reviewerPic.isNotEmpty)
                                      ? NetworkImage(reviewerPic)
                                      : null,
                                  child: (reviewerPic.isEmpty)
                                      ? const Icon(Icons.person, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: StyledHeading(
                                              reviewerName,
                                              weight: FontWeight.bold,
                                            ),
                                          ),
                                          StyledBody(
                                            review.date.toString().split(' ').first,
                                            color: Colors.grey,
                                            weight: FontWeight.normal,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: List.generate(
                                          5,
                                          (star) => Icon(
                                            Icons.star,
                                            color: star < review.rating ? Colors.amber : Colors.grey[300],
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      if (review.text.isNotEmpty)
                                        StyledBody(
                                          review.text,
                                          color: Colors.black,
                                          weight: FontWeight.normal,
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<String> uploadAndGetDownloadUrl(File file, String storagePath) async {
    final ref = FirebaseStorage.instance.ref().child(storagePath);
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    return url;
  }

  Future<String?> getDownloadUrlFromPath(String storagePath) async {
    try {
      final ref = FirebaseStorage.instance.ref().child(storagePath);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  String formatLastSeen(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final lastSeenDay = DateTime(date.year, date.month, date.day);
  final difference = today.difference(lastSeenDay).inDays;

  if (difference == 0) {
    return 'Today';
  } else if (difference == 1) {
    return 'Yesterday';
  } else if (difference < 7) {
    // Day of week, e.g. "Monday"
    return ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'][date.weekday - 1];
  } else {
    // Format as "12 Jun 2024"
    return '${date.day.toString().padLeft(2, '0')} '
        '${['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][date.month - 1]} '
        '${date.year}';
  }
}}

Future<void> chatWithUsLine(BuildContext context) async {
  try {
    await openLineApp(context
        // phone: '+6591682725',
        // text: 'Hello Unearthed Support...',
        );
  } on Exception catch (e) {
    if (context.mounted) {
      showDialog(
          context: context,
          builder: (context) => CupertinoAlertDialog(
                title: const Text("Attention"),
                content: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(e.toString()),
                ),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Close'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ));
    }
  }
}

// Add this function to your file if not already present:
Future<void> logOut(BuildContext context) async {
  if (!context.mounted) return;

  final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
  final renter = itemStore.renter;

  try {
    log('Logging out user - status: ${renter.type}');

    itemStore.setLoggedIn(false);

    NotificationService.deleteFCMToken(
      userId: renter.id,
    );

    await FirebaseAuth.instance.signOut();

    if (!context.mounted) return;
    Navigator.of(context).pushReplacementNamed('/sign_in');
  } catch (e) {
    log(' Logout failed: $e');
  }
}