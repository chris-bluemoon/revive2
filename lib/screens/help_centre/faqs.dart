import 'package:flutter/material.dart';
import 'package:revivals/screens/help_centre/faq_accordion.dart';
import 'package:revivals/screens/profile/profile.dart';
import 'package:revivals/shared/styled_text.dart';

class FAQs extends StatelessWidget {
  const FAQs({super.key});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          title: const StyledTitle("FAQs"),
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
        body: Column(
          children: [
            // SizedBox(height: width * 0.05),
            // const FaqExpansionList()
            FaqAccordion(),
            SizedBox(height: width * 0.03),
            const StyledHeading('Still have questions?'),
            SizedBox(height: width * 0.02),
            GestureDetector(
              onTap: () async {
                await chatWithUsLine(context);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const StyledHeading('Contact us on LINE'),
                  const SizedBox(width: 10),
                  Image.asset('assets/logos/LINE_logo.png', height: 40),
                ],
              ),
            ),
            SizedBox(height: width * 0.05),
            // const FaqExpansionList()
            // const ScrollTest(),
            // const SizedBox(
            //   height: 900,
            //   child: AccordionPage()
            // )
          ],
        ));
  }
}
