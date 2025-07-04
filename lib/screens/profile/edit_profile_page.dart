import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:revivals/models/renter.dart';
import 'package:revivals/providers/class_store.dart';
import 'package:revivals/shared/styled_text.dart';
import 'package:uuid/uuid.dart';

class EditProfilePage extends StatefulWidget {
  final Renter renter;
  const EditProfilePage({super.key, required this.renter});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController bioController;
  late TextEditingController nameController;
  String? imagePath;
  bool _isUploading = false; // <-- Add this line
  bool _isSaving = false; // <-- Add this line for save loading state
  bool _hasChanges = false; // <-- Add this line to track changes

  // Add this list at the top of your _EditProfilePageState class:
  final List<String> thailandCities = [
    'Bangkok',
    'Chiang Mai',
    'Phuket',
    'Pattaya',
    'Khon Kaen',
    'Hat Yai',
    'Nakhon Ratchasima',
    'Udon Thani',
    'Surat Thani',
    'Rayong',
  ];

  // Add a variable to hold the selected city:
  String? selectedCity;

  @override
  void initState() {
    super.initState();
    bioController = TextEditingController(text: widget.renter.bio);
    nameController = TextEditingController(text: widget.renter.name);
    // Use renter.location directly, default to 'Bangkok' if empty or not in list
    String initialCity = (widget.renter.location.isNotEmpty)
        ? widget.renter.location
        : 'Bangkok';
    selectedCity = thailandCities.contains(initialCity) ? initialCity : 'Bangkok';
    imagePath = widget.renter.imagePath; // Use imagePath directly instead of profilePicUrl

    // Add listeners to track changes
    nameController.addListener(_checkForChanges);
    bioController.addListener(_checkForChanges);
  }

  void _checkForChanges() {
    final bool hasChanged = nameController.text != widget.renter.name ||
        bioController.text != widget.renter.bio ||
        selectedCity != widget.renter.location ||
        imagePath != widget.renter.imagePath;

    if (hasChanged != _hasChanges) {
      setState(() {
        _hasChanges = hasChanged;
      });
    }
  }

  @override
  void dispose() {
    nameController.removeListener(_checkForChanges);
    bioController.removeListener(_checkForChanges);
    bioController.dispose();
    nameController.dispose();
    super.dispose();
  }

  Future<String?> uploadProfileImage(File file) async {
    try {
      final renterId = widget.renter.id; // Make sure your Renter model has an 'id' field
      final ext = path.extension(file.path);
      final filename = '${const Uuid().v4()}$ext';
      final ref = FirebaseStorage.instance.ref().child('profile_pics/$renterId/$filename');
      final uploadTask = await ref.putFile(file);
      final url = await uploadTask.ref.getDownloadURL();
      return url;
    } catch (e) {
      // Handle error, e.g. show a snackbar
      return null;
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _isUploading = true; // Show spinner
      });
      final url = await uploadProfileImage(File(picked.path));
      setState(() {
        _isUploading = false; // Hide spinner
      });
      if (url != null) {
        setState(() {
          imagePath = url;
          _checkForChanges(); // Check for changes after image is updated
        });
      }
    }
  }

  Future<void> saveProfile() async {
    setState(() {
      _isSaving = true; // Show spinner
    });
    
    try {
      // Save bio, location, name, and imagePath to your backend or state management
      final provider = Provider.of<ItemStoreProvider>(context, listen: false);
      
      // Update the local renter object immediately for responsive UI
      provider.renter.bio = bioController.text;
      provider.renter.location = selectedCity ?? 'Bangkok';
      provider.renter.name = nameController.text;
      if (imagePath != null) {
        provider.renter.imagePath = imagePath!;
      }
      
      // Call the optimized update method
      await provider.updateRenterProfile(
        bio: bioController.text,
        location: selectedCity,
        imagePath: imagePath,
        name: nameController.text,
      );
      
      if (mounted) {
        // Return the updated renter object so the profile page can refresh
        Navigator.pop(context, provider.renter);
      }
    } catch (e) {
      // Handle error if needed
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false; // Hide spinner
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        title: const StyledTitle('EDIT PROFILE'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08, color: Colors.black), // Consistent with other pages
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ListView(
          children: [
            Center(
              child: GestureDetector(
                onTap: pickImage,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircleAvatar(
                      radius: width * 0.14,
                      backgroundColor: Colors.black,
                      backgroundImage: imagePath != null && imagePath!.isNotEmpty
                          ? (imagePath!.startsWith('http')
                              ? CachedNetworkImageProvider(imagePath!)
                              : FileImage(File(imagePath!)) as ImageProvider
                            )
                          : null,
                      child: imagePath == null || imagePath!.isEmpty
                          ? Text(
                              widget.renter.name.isNotEmpty 
                                ? widget.renter.name.substring(0, 1).toUpperCase() 
                                : '?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: width * 0.08,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    if (_isUploading)
                      Container(
                        width: width * 0.28,
                        height: width * 0.28,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // User Name label and text field
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: StyledBody('User Name', color: Colors.black, weight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: nameController,
              maxLength: 20,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                hintText: "Enter your name",
                contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                counterText: "", // Hide the character counter
              ),
            ),
            const SizedBox(height: 24),
            // Location label above the dropdown
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: StyledBody('Location', color: Colors.black, weight: FontWeight.bold),
              ),
            ),
            DropdownButtonFormField<String>(
              value: selectedCity,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.normal,
                fontSize: MediaQuery.of(context).size.width * 0.04,
              ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // <-- Black border
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black), // <-- Black border
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2), // <-- Black border
                ),
              ),
              dropdownColor: Colors.white,
              items: thailandCities
                  .map((city) => DropdownMenuItem(
                        value: city,
                        child: Text(
                          city,
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.normal,
                            fontSize: MediaQuery.of(context).size.width * 0.04,
                          ),
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCity = value;
                  _checkForChanges(); // Check for changes when city is updated
                });
              },
            ),
            const SizedBox(height: 24),
            // Bio label above the text box
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4, bottom: 6),
                child: StyledBody('Describe yourself', color: Colors.black, weight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: bioController,
              maxLines: 3,
              maxLength: 200,
              onChanged: (text) {
                // No setState needed, just update controller
                setState(() {});
              },
              decoration: InputDecoration(
                border: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
                counterText: "${bioController.text.length}/200", // Show used/total
                hintText: "Share a bit about yourself...",
                hintStyle: TextStyle(
                  color: Colors.grey[800],
                  fontSize: MediaQuery.of(context).size.width * 0.03,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12), // Add this line
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving || !_hasChanges ? null : saveProfile, // Disable if saving or no changes
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isSaving || !_hasChanges ? Colors.grey : Colors.black, // Grey out if disabled
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12), // Consistent corner radius
                  ),
                ),
                child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const StyledHeading('Save', weight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}