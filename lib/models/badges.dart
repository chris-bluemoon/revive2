import 'package:flutter/material.dart';

/// BadgeType enum for grouping badges
enum BadgeType {
  trust,
  experience,
  style,
}

/// Badge model
class Badge {
  final String title;
  final String description;
  final IconData icon;
  final BadgeType type;

  const Badge({
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
  });
}

/// List of all available badges
const List<Badge> allBadges = [
  // Trust and Responsibility
  Badge(
    title: 'Verified Identity',
    description: 'User has verified ID or phone/email.',
    icon: Icons.verified_user,
    type: BadgeType.trust,
  ),
  Badge(
    title: 'Top Rated Lender',
    description: 'Consistently receives 5-star reviews.',
    icon: Icons.star,
    type: BadgeType.trust,
  ),
  Badge(
    title: 'Top Rated Renter',
    description: 'Returns items on time and in great condition.',
    icon: Icons.thumb_up,
    type: BadgeType.trust,
  ),
  Badge(
    title: 'Damage-Free Streak',
    description: 'X rentals with no damage reported.',
    icon: Icons.shield,
    type: BadgeType.trust,
  ),
  Badge(
    title: 'Always On Time',
    description: '100% punctual pickup/returns.',
    icon: Icons.access_time,
    type: BadgeType.trust,
  ),

  // Experience & Activity
  Badge(
    title: 'Super Lender',
    description: 'Over X items listed or rented out.',
    icon: Icons.local_shipping,
    type: BadgeType.experience,
  ),
  Badge(
    title: 'Super Renter',
    description: 'Has rented X dresses.',
    icon: Icons.shopping_bag,
    type: BadgeType.experience,
  ),
  Badge(
    title: 'Seasoned User',
    description: 'Member for over X months/years.',
    icon: Icons.cake,
    type: BadgeType.experience,
  ),
  Badge(
    title: 'First Rental Complete',
    description: 'Completed first transaction.',
    icon: Icons.emoji_events,
    type: BadgeType.experience,
  ),
  Badge(
    title: '10 Rentals',
    description: 'Milestone for 10 completed rentals.',
    icon: Icons.looks_one,
    type: BadgeType.experience,
  ),
  Badge(
    title: '50 Rentals',
    description: 'Milestone for 50 completed rentals.',
    icon: Icons.looks_5,
    type: BadgeType.experience,
  ),
  Badge(
    title: '100 Rentals',
    description: 'Milestone for 100 completed rentals.',
    icon: Icons.looks_6,
    type: BadgeType.experience,
  ),

  // Community & Engagement
  Badge(
    title: 'Fast Responder',
    description: 'Replies to messages within X minutes/hours.',
    icon: Icons.flash_on,
    type: BadgeType.experience, // Or create a new BadgeType.community if you want
  ),
  Badge(
    title: 'Helpful Rater',
    description: 'Leaves reviews consistently.',
    icon: Icons.rate_review,
    type: BadgeType.experience,
  ),
  Badge(
    title: 'Photogenic Closet',
    description: 'Listings with high-quality images.',
    icon: Icons.photo_camera,
    type: BadgeType.experience,
  ),
  Badge(
    title: 'Profile Complete',
    description: 'Finished bio, photo, and preferences.',
    icon: Icons.account_circle,
    type: BadgeType.experience,
  ),

  // Style & Category
  Badge(
    title: 'Luxury Collector',
    description: 'Owns or rents out luxury/designer items.',
    icon: Icons.diamond,
    type: BadgeType.style,
  ),
  Badge(
    title: 'Event Pro',
    description: 'Dresses rented frequently for special occasions.',
    icon: Icons.celebration,
    type: BadgeType.style,
  ),
  Badge(
    title: 'Style Icon',
    description: 'Consistently receives compliments or style tags.',
    icon: Icons.style,
    type: BadgeType.style,
  ),

  // Exclusive/Seasonal
  Badge(
    title: 'Early Adopter',
    description: "Joined during the app's launch phase.",
    icon: Icons.rocket_launch,
    type: BadgeType.experience,
  ),
  Badge(
    title: 'Holiday Hero',
    description: 'Rented or lent during festive seasons.',
    icon: Icons.card_giftcard,
    type: BadgeType.experience,
  ),
  Badge(
    title: 'Sustainability Star',
    description: 'Participates in eco-friendly initiatives (e.g. recycles packaging).',
    icon: Icons.eco,
    type: BadgeType.experience,
  ),
];
