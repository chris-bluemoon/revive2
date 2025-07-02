import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:revivals/screens/authenticate/register_password.dart';
import 'package:revivals/shared/smooth_page_route.dart';

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

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        toolbarHeight: width * 0.2,
        leading: IconButton(
          icon: Icon(Icons.chevron_left, color: Colors.black, size: width * 0.08),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
              Center(
                child: Container(
                  width: width * 0.2,
                  height: width * 0.3,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/logos/new_velaa_logo_transparent.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40.0),
              
              // Title
              const Text(
                'Where are you located?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              const Text(
                'Select your location to help us personalize your experience',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40.0),
              
              // Form Card
              Card(
                color: Colors.white,
                elevation: 8,
                shadowColor: Colors.black.withOpacity(0.1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: _selectedLocation,
                        decoration: InputDecoration(
                          hintText: 'Select Location',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.black, width: 2),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
                      const SizedBox(height: 30.0),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ready ? Colors.black : Colors.grey[300],
                            foregroundColor: ready ? Colors.white : Colors.grey[500],
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: ready ? () async {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                              context,
                              SmoothPageRoute(
                                child: RegisterPassword(
                                  email: widget.email, 
                                  name: widget.name, 
                                  location: _selectedLocation,
                                ),
                              ),
                            );
                          } : null,
                          child: const Text(
                            'Continue',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}