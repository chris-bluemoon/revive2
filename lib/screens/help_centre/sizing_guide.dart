import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:revivals/shared/styled_text.dart';

class SizingGuide extends StatelessWidget {
  const SizingGuide({super.key});
 
 

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          title: const StyledTitle("Sizing Guide"),
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
                'Welcome to Unearthed Collections! To ensure you have the perfect fit for your special occasion, please refer to our detailed sizing guide below. If you need any assistance, don’t hesitate to contact our customer service team.',
                weight: FontWeight.normal),
            SizedBox(height: width * 0.03),
            // Divider(height: width * 0.03, indent: width * 0.25, endIndent: width * 0.25,),
                        Center(child: Image.asset('assets/img/backgrounds/seperator_2.png')),

            SizedBox(height: width * 0.03),
            const StyledHeading('1. How to Measure Yourself'),
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
                              TextSpan(text: 'Bust: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Measure around the fullest part of your bust, keeping the tape measure level and snug but not tight.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Hips: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Measure around the fullest part of your hips, keeping the tape measure level.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Waist: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Measure around the narrowest part of your waist, usually just above your belly button. Ensure the tape measure is parallel to the floor.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Length: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'For full-length dresses, measure from the top of your shoulder to where you want the hem to fall. For knee-length or shorter dresses, measure from the top of your shoulder to your desired hem length.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Shoulder to Shoulder: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'Measure across the back from one shoulder to the other, keeping the tape measure straight and level.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Inseam: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                            ]))
                    ),
                  ]),
                ],
              ),
            ),
            SizedBox(height: width * 0.02),
            const StyledHeading('2. Compare with Our Size Chart'),
            SizedBox(height: width * 0.01),
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: Table(
                border: const TableBorder(
                  top: BorderSide(color: Colors.grey),
                  bottom: BorderSide(color: Colors.grey),
                  right: BorderSide(color: Colors.grey),
                  left: BorderSide(color: Colors.grey),
                  verticalInside: BorderSide(color: Colors.grey)
                ),
                children: [
                  TableRow(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      color: Colors.grey[100],
                    ),
                    children: const [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('Size'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('Bust'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('Waist'),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('Hips'),
                      )
                    ]
                  ),
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('XS', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('31-32', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('24-25', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('33-34', weight: FontWeight.normal),
                      )
                    ]
                  ),
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('S', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('33-34', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('26-27', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('35-36', weight: FontWeight.normal),
                      )
                    ]
                  ),
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('M', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('35-36', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('28-29', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('37-38', weight: FontWeight.normal),
                      )
                    ]
                  ),
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('L', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('37-28', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('30-31', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('39-40', weight: FontWeight.normal),
                      )
                    ]
                  ),
                  const TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('XL', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('39-40', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('32-33', weight: FontWeight.normal),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.0),
                        child: StyledBody('41-42', weight: FontWeight.normal),
                      )
                    ]
                  ),
                ],
              ),
            ),
            SizedBox(height: width * 0.02),
            const StyledHeading('3. Consider the Fit'),
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
                              TextSpan(text: 'A-Line Dresses: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'These are generally flattering on most body types and can accommodate a range of sizes.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
                                // style: TextStyle(color: Colors.black))
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
                              TextSpan(text: 'Bodycon Dresses: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'For a more fitted look, consider sizing up if you’re between sizes.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
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
                              TextSpan(text: 'Empire Waist Dresses: ', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.bold,),),
                              TextSpan(text: 'These are great for accentuating the bust and are usually more forgiving in the waist area.', style: GoogleFonts.openSans(textStyle: Theme.of(context).textTheme.bodyMedium, fontSize: width*0.03, color: Colors.black, fontWeight: FontWeight.normal,),),
                              // TextSpan(text: '(for pants or jumpsuits): Measure from the crotch seam to the bottom of the leg.',
                            ]))
                    ),
                  ]),
                ],
              ),
            ),
            SizedBox(height: width * 0.02),
            const StyledHeading('4. Check the Fabric'),
            SizedBox(height: width * 0.01),
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: const StyledBody('Different fabrics have different amounts of stretch. Refer to the dress description for information on the material and its stretch level. Stretchy fabrics may allow for a more forgiving fit.', weight: FontWeight.normal),
            ),
            SizedBox(height: width * 0.02),
            const StyledHeading('5. Account for Alterations'),
            SizedBox(height: width * 0.01),
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: const StyledBody('While we strive to provide accurate sizes, slight alterations might be needed for the perfect fit. Check with your local tailor if necessary.', weight: FontWeight.normal),
            ),
            SizedBox(height: width * 0.02),
            const StyledHeading('6. Customer Support'),
            SizedBox(height: width * 0.01),
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: const StyledBody('Still unsure? Our customer support team is here to help! Contact us on LINE for personalized assistance.', weight: FontWeight.normal),
            ),
            SizedBox(height: width * 0.01),
            Padding(
              padding: EdgeInsets.all(width * 0.02),
              child: const StyledBody('Thank you for choosing Unearthed Collections! We’re excited to help you find the perfect dress for your special occasion.', weight: FontWeight.normal),
            )
          ]),
        )));
  }
}
