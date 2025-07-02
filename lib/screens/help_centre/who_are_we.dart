import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revivals/screens/help_centre/terms_and_conditions.dart';
import 'package:revivals/shared/styled_text.dart';

class WhoAreWe extends StatelessWidget {
  const WhoAreWe({super.key});
 
 

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.chevron_left, size: width * 0.08),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const StyledTitle('Who Are We?'), 
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: Theme.of(context).appBarTheme.elevation ?? 4,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  const StyledBody(
                      'Welcome to Unearthed Collections, where style meets convenience! We’re more than just a dress rental service, we’re your go-to destination for unforgettable fashion experiences.',
                      weight: FontWeight.normal),
                  SizedBox(height: width * 0.03),
                  Center(child: Image.asset('assets/img/backgrounds/seperator_2.png')),

                  SizedBox(height: width * 0.03),
                  const StyledHeading('Our Mission'),
                  SizedBox(height: width * 0.01),
                  Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(
                            child: 
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: width * 0.01),
                                  children: [
                                    TextSpan(text: 'At Unearthed Collections our mission is to make high-quality, stylish dresses accessible to everyone. We believe that every occasion deserves a touch of elegance, whether it’s a wedding, a gala, or a night out. Our goal is to help you look and feel fabulous without the hassle of buying and storing a dress you might only wear once.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                                  ]))
                          ),
                        ]),
                    ]),
                  ),
                  SizedBox(height: width * 0.02),
                  const StyledHeading('Our Story'),
                  SizedBox(height: width * 0.01),
                   Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(
                            child: 
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: width * 0.01),
                                  children: [
                                    TextSpan(text: 'Founded in 2018, Unearthed Collections was born out of a passion for fashion and a desire to offer a more sustainable, economical way to enjoy designer dresses. What started as a small boutique with a handful of dresses has grown into a premier destination for dress rentals, thanks to our commitment to exceptional service and a curated collection of stunning gowns and outfits.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                                  ]))
                          ),
                        ]),
                    ]),
                  ),
                              SizedBox(height: width * 0.02),
                  const StyledHeading('Our Collection'),
                  SizedBox(height: width * 0.01),
                   Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(
                            child: 
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: width * 0.01),
                                  children: [
                                    TextSpan(text: 'We pride ourselves on offering a diverse selection of dresses that cater to all tastes and occasions. From classic elegance to modern chic, our collection features designs from renowned designers and emerging talent. Whether you’re looking for a floor-length gown, a cocktail dress, or something in between, you’ll find it in our inventory.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                                  ]))
                          ),
                        ]),
                    ]),
                  ), 
                  SizedBox(height: width * 0.02),
                  const StyledHeading('Our Commitment'),
                  SizedBox(height: width * 0.01),
                   Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(
                            child: 
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: width * 0.01),
                                  children: [
                                    TextSpan(text: 'Quality: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                                    TextSpan(text: 'We meticulously maintain and clean each dress to ensure it’s in perfect condition for your special event.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                                  ]))
                          ),
                        ]),
                        SizedBox(height: width * 0.01),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(
                            child: 
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: width * 0.01),
                                  children: [
                                    TextSpan(text: 'Customer Service: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                                    TextSpan(text: 'Our dedicated team is here to assist you every step of the way, from choosing the right dress to ensuring a seamless rental experience.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                                  ]))
                          ),
                        ]),
                        SizedBox(height: width * 0.01),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(
                            child: 
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: width * 0.01),
                                  children: [
                                    TextSpan(text: 'Sustainability: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                                    TextSpan(text: 'We’re committed to reducing fashion waste by promoting a circular economy. Renting a dress is a stylish choice that helps the environment.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                                  ]))
                          ),
                        ]),
                    ]),
                  ),
                  SizedBox(height: width * 0.02),
                  const StyledHeading('Meet The Team'),
                  SizedBox(height: width * 0.01),
                   Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(
                            child: 
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: width * 0.01),
                                  children: [
                                    TextSpan(text: 'Our team of fashion enthusiasts and experts is here to make your rental experience as enjoyable and effortless as possible. We’re always ready to offer personalized advice, answer your questions, and ensure that you find the perfect dress for your occasion.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                                  ]))
                          ),
                        ]),
                    ]),
                  ),
                                      SizedBox(height: width * 0.02),
                  const StyledHeading('Join Us'),
                  SizedBox(height: width * 0.01),
                   Padding(
                    padding: EdgeInsets.all(width * 0.02),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(
                            child: 
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: width * 0.01),
                                  children: [
                                    TextSpan(text: 'We invite you to explore our collection and experience the joy of dressing up without the commitment of a permanent wardrobe addition. Join the Unearthed Collections community and let us help you create memorable moments with style and grace.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                                  ]))
                          ),
                        ]),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                          Expanded(
                            child: 
                              RichText(
                                text: TextSpan(
                                  style: TextStyle(fontSize: width * 0.01),
                                  children: [
                                    TextSpan(text: 'Thank you for choosing Unearthed Collections. We can’t wait to be part of your next special occasion!', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                                  ]))
                          ),
                        ]),
                    ]),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsAndConditionsPage(),
                      ),
                    );
                  },
                  child: const Text(
                    'Full Terms and Conditions',
                    style: TextStyle(
                      color: Colors.black,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
