import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:revivals/shared/animated_logo_spinner.dart';

class ProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final double radius;
  final double? fontSize;
  
  const ProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.userName,
    required this.radius,
    this.fontSize,
  });

  String get firstLetter {
    if (userName.isEmpty) return '?';
    return userName.trim().substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final double actualFontSize = fontSize ?? radius * 0.6;
    
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.black,
      child: imageUrl.isEmpty
          ? Text(
              firstLetter,
              style: TextStyle(
                color: Colors.white,
                fontSize: actualFontSize,
                fontWeight: FontWeight.bold,
              ),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: radius * 2,
                height: radius * 2,
                placeholder: (context, url) => Center(
                  child: SizedBox(
                    width: radius * 0.8,
                    height: radius * 0.8,
                    child: FastLogoSpinner(size: radius * 0.8),
                  ),
                ),
                errorWidget: (context, url, error) => Text(
                  firstLetter,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: actualFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
    );
  }
}

// AppBar-specific avatar that handles positioning better
class AppBarProfileAvatar extends StatelessWidget {
  final String imageUrl;
  final String userName;
  final double radius;
  
  const AppBarProfileAvatar({
    super.key,
    required this.imageUrl,
    required this.userName,
    required this.radius,
  });

  String get firstLetter {
    if (userName.isEmpty) return '?';
    return userName.trim().substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: radius * 2,
        height: radius * 2,
        decoration: const BoxDecoration(
          color: Colors.black,
          shape: BoxShape.circle,
        ),
        child: imageUrl.isEmpty
            ? Center(
                child: Text(
                  firstLetter,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: radius * 0.6,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: radius * 2,
                  height: radius * 2,
                  placeholder: (context, url) => Center(
                    child: SizedBox(
                      width: radius * 0.8,
                      height: radius * 0.8,
                      child: FastLogoSpinner(size: radius * 0.8),
                    ),
                  ),
                  errorWidget: (context, url, error) => Center(
                    child: Text(
                      firstLetter,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: radius * 0.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
