import 'package:flutter/material.dart';
import 'package:revivals/screens/authenticate/register_password.dart';
import 'package:revivals/shared/styled_text.dart';

// Example list of locations; replace with your actual list or import from your constants
const List<String> locations = [
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

class RegisterLocation extends StatefulWidget {
  final String email;
  final String name;

  const RegisterLocation({
    super.key,
    required this.email,
    required this.name,
  });

  @override
  State<RegisterLocation> createState() => _RegisterLocationState();
}

class _RegisterLocationState extends State<RegisterLocation> {
  late String _selectedLocation;
  
  bool ready = true;

  @override
  void initState() {
    super.initState();
    _selectedLocation = locations.first; // Default to the first location
  }

  void _submit() {
    if (_selectedLocation.isNotEmpty) {
      // Handle location submission logic here, you have widget.email, widget.name, and _selectedLocation
      Navigator.of(context).pop(_selectedLocation);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select your location')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: width * 0.2,
        // centerTitle: true,
        title: const StyledTitle('LOCATION'),
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          children: [
            const Text(
              'Select your location to help us personalize your experience.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 32),
            DropdownButtonFormField<String>(
              dropdownColor: Colors.white,
              value: _selectedLocation,
              decoration: const InputDecoration(
                labelText: 'Location',
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.black, width: 2),
                ),
              ),
              items: locations.map((location) {
                return DropdownMenuItem<String>(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedLocation = value;
                  });
                }
              },
            ),
            const Spacer(flex: 3),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.black.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 3,
            )
          ],
        ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                if (!ready) Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                    },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(1.0),
                      ),
                      side: const BorderSide(width: 1.0, color: Colors.black),
                      ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StyledHeading('CONTINUE', weight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                if (ready) Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => (RegisterPassword(email: widget.email, name: widget.name, location: _selectedLocation,))));
                        
                    },
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                      side: const BorderSide(width: 1.0, color: Colors.black),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: StyledHeading('CONTINUE', color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),   
    );
  }
}