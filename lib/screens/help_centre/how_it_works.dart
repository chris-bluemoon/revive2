import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revivals/shared/styled_text.dart';

class HowItWorks extends StatelessWidget {
  const HowItWorks({super.key});
 
 

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          title: const StyledTitle("How It Works"),
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
                'At Unearthed Collections, we make finding and renting the perfect dress easy and enjoyable. Here’s a step-by-step guide to help you navigate our rental process.',
                weight: FontWeight.normal),
            SizedBox(height: width * 0.03),
            // Divider(height: width * 0.03, indent: width * 0.25, endIndent: width * 0.25,),
            Center(child: Image.asset('assets/img/backgrounds/seperator_2.png')),
            SizedBox(height: width * 0.03),
            const StyledHeading('1. Browse Our Collection'),
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
                              TextSpan(text: 'Explore: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Visit our website or store to browse our extensive collection of dresses. Use our filters to narrow down options by style, size, color, or occasion.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'View Details: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Click on a dress to see detailed information, including size availability, fabric type, and care instructions. View high-quality images to get a closer look at the design.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
                            ]))
                    ),
                  ]),
              ]),
            ),
            SizedBox(height: width * 0.02),
            const StyledHeading('2. Select Your Dress'),
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
                              TextSpan(text: 'Choose Your Size: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Refer to our sizing guide to determine your perfect fit. If you’re unsure, feel free to contact our customer support for assistance.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Pick Your Rental Period: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Select the dates you need the dress for. Our rental periods are typically 1, 3 and 5 days, with options to extend if needed.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
                            ]))
                    ),
                  ]),
              ]),
            ),
                        SizedBox(height: width * 0.02),
            const StyledHeading('3. Checkout'),
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
                              TextSpan(text: 'Complete Your Personal Details: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Provide your shipping address and payment details. You can also create an account for easier future rentals.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Review and Confirm: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Double-check your rental dates, dress size, and shipping information. Review our rental terms and conditions before finalizing your order.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Payment: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Complete your payment securely through our website. We accept various payment methods including credit/debit cards and [any other payment methods].', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
                            ]))
                    ),
                  ]),
              ]),
            ), 
                        SizedBox(height: width * 0.02),
            const StyledHeading('4. Receive Your Dress'),
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
                              TextSpan(text: 'Shipping: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'We’ll ship your dress to your specified address within [X] business days. You’ll receive a tracking number to monitor your shipment.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Unbox & Inspect: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'When your dress arrives, carefully unpack it and inspect it for any issues. If you have any concerns, contact us immediately.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
                            ]))
                    ),
                  ]),
              ]),
            ),
            SizedBox(height: width * 0.02),
            const StyledHeading('5. Enjoy Your Dress'),
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
                              TextSpan(text: 'Wear With Confidence: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Enjoy your event in style! Follow any care instructions included to keep your dress looking fabulous throughout your rental period.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Accessorize: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Add your personal touch with accessories to complete your look.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
                            ]))
                    ),
                  ]),
              ]),
            ),
                                    SizedBox(height: width * 0.02),
            const StyledHeading('6. Return Your Dress'),
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
                              TextSpan(text: 'Prepare For Return: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'After your event, carefully repackage the dress using the provided return packaging. Make sure the dress is clean and in the same condition as when you received it.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Return Shipping: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Attach the pre-paid return label included with your shipment. Drop off the package at the nearest [shipping carrier] location or schedule a pickup.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Confirmation: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'We’ll notify you once your dress has been received and inspected. If there are any issues, we’ll contact you to discuss them.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
                            ]))
                    ),
                  ]),
              ]),
            ),
            SizedBox(height: width * 0.02),
            const StyledHeading('4. Feedback & Return'),
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
                              TextSpan(text: 'Share Your Experience: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'We’d love to hear about your experience! Leave a review on our website or social media to help others find their perfect dress.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Re-Rent: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Loved your dress? Keep an eye out for similar styles or return to our collection for your next event. Our rotating inventory ensures you’ll always find something new and exciting.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
