import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revivals/shared/styled_text.dart';

class WhoAreWe extends StatelessWidget {
  const WhoAreWe({super.key});
 
 

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          title: const StyledTitle("Who Are We?"),
          centerTitle: true,
          backgroundColor: Colors.white,
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: width * 0.08),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // actions: [
          //   IconButton(
          //       onPressed: () =>
          //           {Navigator.of(context).popUntil((route) => route.isFirst)},
          //       icon: Icon(Icons.close, size: width*0.06)),
          // ],
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.fromLTRB(width * 0.05, width * 0.03, width * 0.05, 0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const StyledBody(
                'Welcome to Unearthed Collections, where style meets convenience! We’re more than just a dress rental service, we’re your go-to destination for unforgettable fashion experiences.',
                weight: FontWeight.normal),
            SizedBox(height: width * 0.03),
            // Divider(height: width * 0.03, indent: width * 0.25, endIndent: width * 0.25,),
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
                              // TextSpan(text: 'Explore: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'At Unearthed Collections our mission is to make high-quality, stylish dresses accessible to everyone. We believe that every occasion deserves a touch of elegance, whether it’s a wedding, a gala, or a night out. Our goal is to help you look and feel fabulous without the hassle of buying and storing a dress you might only wear once.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
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
                              // TextSpan(text: 'Choose Your Size: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Founded in 2018, Unearthed Collections was born out of a passion for fashion and a desire to offer a more sustainable, economical way to enjoy designer dresses. What started as a small boutique with a handful of dresses has grown into a premier destination for dress rentals, thanks to our commitment to exceptional service and a curated collection of stunning gowns and outfits.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
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
                              // TextSpan(text: 'Complete Your Personal Details: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'We pride ourselves on offering a diverse selection of dresses that cater to all tastes and occasions. From classic elegance to modern chic, our collection features designs from renowned designers and emerging talent. Whether you’re looking for a floor-length gown, a cocktail dress, or something in between, you’ll find it in our inventory.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
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
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
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
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
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
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
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
                              // TextSpan(text: 'Wear With Confidence: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Our team of fashion enthusiasts and experts is here to make your rental experience as enjoyable and effortless as possible. We’re always ready to offer personalized advice, answer your questions, and ensure that you find the perfect dress for your occasion.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
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
                              // TextSpan(text: 'Prepare For Return: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'We invite you to explore our collection and experience the joy of dressing up without the commitment of a permanent wardrobe addition. Join the Unearthed Collections community and let us help you create memorable moments with style and grace.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
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
                              // TextSpan(text: 'Return Shipping: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Thank you for choosing Unearthed Collections. We can’t wait to be part of your next special occasion!', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
                            ]))
                    ),
                  ]),
              ]),
            ),
          ]),
        )));
  }
}
