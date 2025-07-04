import 'dart:developer';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/models/review.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/screens/favourites/favourites.dart';
import 'package:revivals/screens/messages/message_conversation_page.dart';
import 'package:revivals/screens/profile/account/account_page.dart';
import 'package:revivals/screens/profile/admin/admin_page.dart';
import 'package:revivals/screens/profile/follow_list_screen.dart';
import 'package:revivals/screens/profile/lender_dashboard/lender_dashboard.dart';
import 'package:revivals/screens/profile/notifications/notifications_page.dart';
import 'package:revivals/screens/profile/renter_dashboard/renter_dashboard.dart';
import 'package:revivals/screens/to_rent/to_rent.dart';
import 'package:revivals/services/notification_service.dart';
import 'package:revivals/shared/item_card.dart';
import 'package:revivals/shared/item_results.dart';
import 'package:revivals/shared/line.dart';
import 'package:revivals/shared/profile_avatar.dart';
import 'package:revivals/shared/smooth_page_route.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:share_plus/share_plus.dart'; // Add this import at the top

import 'edit_profile_page.dart';
import 'report_page.dart';

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
  
  // Cache computed values to avoid recalculating on every build
  Renter? _cachedProfileOwner;
  bool? _cachedIsOwnProfile;
  String? _lastComputedForUserId; // Track when we last computed the cache

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

  // Method to efficiently compute profile owner and ownership status
  void _computeProfileOwner(ItemStoreProvider itemStore) {
    final currentUserId = itemStore.renter.id;
    
    if (widget.userN == null || widget.userN!.isEmpty) {
      // This is the current logged-in user's profile - always use fresh data
      final currentUser = itemStore.renter;
      _cachedProfileOwner = currentUser;
      _cachedIsOwnProfile = itemStore.loggedIn;
      userName = currentUser.name;
    } else {
      // For other users' profiles, use caching
      if (_lastComputedForUserId == currentUserId && 
          _cachedProfileOwner != null && 
          _cachedIsOwnProfile != null) {
        return; // Use cached values
      }
      
      // This is another user's profile, find by name efficiently
      _cachedProfileOwner = null;
      for (final renter in itemStore.renters) {
        if (renter.name == userName) {
          _cachedProfileOwner = renter;
          break;
        }
      }
      _cachedIsOwnProfile = itemStore.loggedIn && itemStore.renter.name == userName;
    }
    
    _lastComputedForUserId = currentUserId;
    log('Profile computed - Owner: ${_cachedProfileOwner?.name}, IsOwn: $_cachedIsOwnProfile');
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final itemStore = Provider.of<ItemStoreProvider>(context);
    
    // Efficiently compute profile owner using cached values
    _computeProfileOwner(itemStore);
    
    final profileOwner = _cachedProfileOwner;
    final isOwnProfile = _cachedIsOwnProfile ?? false;
    
    // Get current user info for other parts of the widget
    final currentRenter = itemStore.renter;
    final isLoggedIn = itemStore.loggedIn;

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
    final myItemsCount = items.where((item) => item.owner == profileOwner.id && item.status == 'accepted').length;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
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
        actions: isLoggedIn ? [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              if (isOwnProfile) {
                // Actions menu logic for own profile
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
                                    SmoothTransitions.luxury(const AccountPage()),
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
                                    SmoothTransitions.luxury(const NotificationsPage()),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.list),
                                title: const Text('My Listings'),
                                onTap: () {
                                  Navigator.push(context,
                                    SmoothTransitions.luxury(ItemResults('myItems', profileOwnerId)),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.dashboard),
                                title: const Text('Renter Dashboard'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SmoothTransitions.luxury(const RenterDashboard()),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.dashboard),
                                title: const Text('Lender Dashboard'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SmoothTransitions.luxury(const LenderDashboard()),
                                  );
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.favorite),
                                title: const Text('Favourites'),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    SmoothTransitions.luxury(const Favourites()),
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
                                        SmoothTransitions.luxury(const AdminPage()),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              } else {
                // Actions menu logic for other users' profiles
                showModalBottomSheet(
                  backgroundColor: Colors.white,
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) => Wrap(
                    children: <Widget>[
                      ListTile(
                        leading: const Icon(Icons.report),
                        title: const Text('Report User'),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.of(context).push(
                            SmoothTransitions.luxury(ReportPage(
                              reportedUserId: profileOwner.id,
                              reportedUserName: profileOwner.name,
                            )),
                          );
                        },
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ] : [],
      ),
      backgroundColor: Colors.grey[50],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // Profile Info Card with border
              Container(
            margin: EdgeInsets.symmetric(horizontal: width * 0.04),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.2),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile picture and stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ProfileAvatar(
                          imageUrl: profileOwner.profilePicUrl,
                          userName: profileOwner.name,
                          radius: width * 0.09,
                        ),
                        if (profileOwner.badges.any((b) => b.title == 'Verified Identity'))
                          Positioned(
                            top: -width * 0.025,
                            right: -width * 0.025,
                            child: TooltipTheme(
                              data: TooltipThemeData(
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.92),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                textStyle: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                waitDuration: Duration(milliseconds: 300),
                                showDuration: Duration(seconds: 3),
                              ),
                              child: Tooltip(
                                message: 'Verified Identity: User has verified ID or phone/email.',
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.12),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.all(width * 0.012),
                                  child: Icon(
                                    Icons.verified, // Use the new green certificate icon
                                    color: Colors.green[600], // Green color for certificate
                                    size: width * 0.055,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: width * 0.03),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.only(right: width * 0.03),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Items count
                            Flexible(
                              child: GestureDetector(
                                onTap: null,
                                child: Column(
                                  children: [
                                    StyledHeading(myItemsCount.toString(), weight: FontWeight.bold),
                                    const SizedBox(height: 2),
                                    const StyledBody("Items", color: Colors.black, weight: FontWeight.normal),
                                  ],
                                ),
                              ),
                            ),
                            // Following count
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    SmoothTransitions.luxury(FollowListScreen(
                                        followersIds: profileOwner.followers,
                                        followingIds: profileOwner.following,
                                      )),
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
                                    const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: StyledBody("Following", color: Colors.black, weight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Followers count
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    SmoothTransitions.luxury(FollowListScreen(
                                        followersIds: profileOwner.followers,
                                        followingIds: profileOwner.following,
                                      )),
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
                                    const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: StyledBody("Followers", color: Colors.black, weight: FontWeight.normal),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                // Name, Location, and bio section  
                const SizedBox(height: 2),
                // Badges row (no user name)
                if (profileOwner.badges.where((b) => b.title != 'Verified Identity').isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).size.height * 0.012),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ...profileOwner.badges
                            .where((badge) => badge.title != 'Verified Identity')
                            .map((badge) => Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: TooltipTheme(
                                    data: TooltipThemeData(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.92),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      textStyle: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      waitDuration: Duration(milliseconds: 300),
                                      showDuration: Duration(seconds: 3),
                                    ),
                                    child: Tooltip(
                                      message: badge.title + ': ' + badge.description,
                                      child: Icon(
                                        badge.icon,
                                        color: Colors.amber[700],
                                        size: width * 0.07,
                                      ),
                                    ),
                                  ),
                                )),
                      ],
                    ),
                  ),
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
              const SizedBox(height: 6),
            // Last seen row
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
              // --- Add avgReview display here ---
              SizedBox(height: width * 0.03), // Changed from fixed 12 to responsive width-based
              Builder(
                builder: (context) {
                  final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                  final reviews = itemStore.reviews.where(
                    (review) => review.reviewedUserId == profileOwner.id,
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
                        (profileOwner.avgReview).toStringAsFixed(1),
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
              ], // Close Container Column children
            ),   // Close Container Column  
          ),     // Close Container
          const SizedBox(height: 16),
          // Buttons section outside the border
          Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Column(
              children: [
                // Show EDIT button if viewing own profile, otherwise show FOLLOW/UNFOLLOW and MESSAGE
                if (isOwnProfile)
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () async {
                            final updatedRenter = await Navigator.of(context).push(
                              SmoothTransitions.luxury(EditProfilePage(renter: profileOwner)),
                            );
                            if (updatedRenter != null) {
                              final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);

                              // Update in renters list
                              final index = itemStore.renters.indexWhere((r) => r.id == updatedRenter.id);
                              if (index != -1) {
                                itemStore.renters[index] = updatedRenter;
                              }

                            // Update current renter if it's the same user
                            if (itemStore.renter.id == updatedRenter.id) {
                              itemStore.renter.name = updatedRenter.name;
                              itemStore.renter.bio = updatedRenter.bio;
                              itemStore.renter.imagePath = updatedRenter.imagePath; // Use imagePath instead of profilePicUrl
                              itemStore.renter.location = updatedRenter.location;
                              itemStore.renter.followers = updatedRenter.followers;
                              itemStore.renter.following = updatedRenter.following;
                              // Add any other fields that need to be updated
                            }
                            
                            // Clear the profile cache to force refresh
                            _cachedProfileOwner = null;
                            _cachedIsOwnProfile = null;
                            _lastComputedForUserId = null;

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
                              // Check if user is logged in
                              final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
                              if (!itemStore.loggedIn) {
                                showAlertDialog(context);
                                return;
                              }
                              
                              Navigator.of(context).push(
                                SmoothTransitions.luxury(MessageConversationPage(
                                    currentUserId: currentRenter.id,
                                    otherUserId: profileOwner.id,
                                    otherUser: {
                                      'name': profileOwner.name,
                                      'profilePicUrl': profileOwner.profilePicUrl,
                                    },
                                  )),
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
                              final isFollowing = profileOwner.followers.contains(currentRenter.id);
                              final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);

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
              ], // Close buttons Column children
            ),   // Close buttons Column  
          ),     // Close buttons Padding
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
          // Tab content - shows different content based on selected tab
          AnimatedBuilder(
            animation: _tabController,
            builder: (context, child) {
              if (_tabController.index == 0) {
                // ITEMS tab content
                final myItems = items.where((item) {
                  // Only show items that belong to the profile owner and have "accepted" status
                  if (item.owner != profileOwner.id) return false;
                  if (item.status == 'accepted') return true;
                  return false;
                }).toList();
                
                if (myItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: StyledBody(
                        'No items yet',
                        color: Colors.grey,
                        weight: FontWeight.normal,
                      ),
                    ),
                  );
                }
                
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.5,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 12.0,
                    ),
                    itemCount: myItems.length,
                    itemBuilder: (context, index) {
                      final item = myItems[index];
                      final width = MediaQuery.of(context).size.width;
                      return KeyedSubtree(
                        key: ValueKey(item.id),
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.of(context).push(
                              SmoothTransitions.luxury(ToRent(item)),
                            );
                          },
                          child: SizedBox(
                            width: width * 0.5,
                            child: ItemCard(item),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else if (_tabController.index == 1) {
                // SAVED tab content
                final savedItems = items.where((item) {
                  // Show items that are in the current user's saved list and have "accepted" status
                  final currentUser = isOwnProfile ? profileOwner : itemStore.renter;
                  return currentUser.saved.contains(item.id) && item.status == 'accepted';
                }).toList();

                if (savedItems.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: StyledBody(
                        'No saved items yet',
                        color: Colors.grey,
                        weight: FontWeight.normal,
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 8.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.5,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 12.0,
                    ),
                    itemCount: savedItems.length,
                    itemBuilder: (context, index) {
                      final item = savedItems[index];
                      final width = MediaQuery.of(context).size.width;
                      return KeyedSubtree(
                        key: ValueKey(item.id),
                        child: GestureDetector(
                          onTap: () async {
                            await Navigator.of(context).push(
                              SmoothTransitions.luxury(ToRent(item)),
                            );
                          },
                          child: SizedBox(
                            width: width * 0.5,
                            child: ItemCard(item),
                          ),
                        ),
                      );
                    },
                  ),
                );
              } else {
                // REVIEWS tab content
                final itemStore = Provider.of<ItemStoreProvider>(context);
                final reviews = itemStore.reviews.where(
                  (review) => review.reviewedUserId == profileOwner.id,
                ).toList();

                if (reviews.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40.0),
                    child: Center(
                      child: StyledBody(
                        'No reviews yet',
                        color: Colors.grey,
                        weight: FontWeight.normal,
                      ),
                    ),
                  );
                }

                return Column(
                  children: reviews.map<Widget>((review) => ReviewCard(review)).toList(),
                );
              }
            },
          ),
          const SizedBox(height: 20), // Add some bottom padding
        ],
        ), // Close SingleChildScrollView child Column
        ), // Close Container child Column
      ), // Close Container
    ); // Close Scaffold
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

class ReviewCard extends StatelessWidget {
  final Review review;
  const ReviewCard(this.review, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final itemStore = Provider.of<ItemStoreProvider>(context, listen: false);
    final reviewer = itemStore.renters.firstWhere(
      (r) => r.id == review.reviewerId,
      orElse: () => Renter(
        id: '',
        name: 'Unknown',
        bio: '',
        imagePath: '',
        location: '',
        lastLogin: DateTime.now(),
        followers: [],
        following: [],
        favourites: [],
        type: '',
        email: '',
        size: 0,
        address: '',
        countryCode: '',
        phoneNum: '',
        verified: 'not started',
        creationDate: DateTime.now().toIso8601String(),
        avgReview: 0.0,
        vacations: const [],
        status: '',
        saved: [],
        fcmToken: '',
        badgeTitles: [],  
      ),
    );
    final dateStr = DateFormat('d MMM yyyy').format(review.date);
    final width = MediaQuery.of(context).size.width;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.withOpacity(0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatar(
            imageUrl: reviewer.profilePicUrl,
            userName: reviewer.name,
            radius: width * 0.06,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StyledHeading(
                      reviewer.name,
                      weight: FontWeight.bold,
                    ),
                    const SizedBox(width: 8),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: i < review.rating ? Colors.amber.shade700 : Colors.grey.shade300,
                        size: width * 0.045,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                StyledBody(
                  review.text.isNotEmpty ? review.text : '(No comment)',
                  color: Colors.black87,
                  weight: FontWeight.normal,
                ),
                const SizedBox(height: 8),
                StyledBody(
                  dateStr,
                  color: Colors.grey[600] ?? Colors.grey,
                ) 
              ],
            ),
          ),
        ],
      ),
    );
  }
}



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

showAlertDialog(BuildContext context) {
  // Create button
  double width = MediaQuery.of(context).size.width;

  Widget okButton = ElevatedButton(
    style: OutlinedButton.styleFrom(
      textStyle: const TextStyle(color: Colors.white),
      foregroundColor: Colors.white, //change background color of button
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      side: const BorderSide(width: 1.0, color: Colors.black),
    ),
    onPressed: () {
      Navigator.of(context).pop(); // Just close the dialog
    },
    child: const Center(child: Text("OK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
  );
  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    backgroundColor: Colors.white,
    title: const Center(child: Text("NOT LOGGED IN", style: TextStyle(fontWeight: FontWeight.bold))),
    content: SizedBox(
      height: width * 0.2,
      child: const Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Please log in", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("or register to continue", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("to send messages", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    ),
    actions: [
      okButton,
    ],
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

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
