import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:flutter/material.dart';
import 'package:revivals/shared/styled_text.dart';

class Item {
  Item({
    required this.content,
    required this.header,
    this.isExpanded = false,
  });

  Widget content;
  Widget header;
  bool isExpanded;
}

Color headerColor = Colors.black;
Color contentColor = Colors.black;

class FaqAccordion extends StatelessWidget //__
{
  FaqAccordion({super.key});

  final List<Item> general_faqs = [
    Item(
        header: StyledHeading("Does Unearthed have a studio?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Want to try something on? Click on the 'APPOINTMENTS' tab under Contact Us in our header menu to arrange a 45 minute fitting session in our boutique.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Do you deliver?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Yes, we can arrange delivery for a small fee, usually 100 within the Bangkok area, alternatively you can arrange your own collection, just contact us to arrange.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Do you ship internationally?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "We can ship to most SE Asian countries, please contact us to arrange international shipment.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How long can I keep my item?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "We rent items for 1, 3 and 5 days, for longer terms, please contact and we will check extended availability.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("I need a dress delivered today!",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "For last minute rentals, please contact us on LINE!",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Can I reserve in advance?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Yes, please use the app once registered or contact us on LINE to book your item.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Do you provide alterations?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Unfortunately we cannot provide alterations, but we offer a wide range of dresses to suit most content shapes and heights.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How do you clean your garments?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "A lot of care goes into ensuring our dresses fresh and clean. Our expert cleaning fairies use a variety of techniques to ensure that each style is dry cleaned, steamed and pressed, inspected for quality, and packaged with care so that it’s ready for another lucky lady to wear.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Can I cancel/exchange my order?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "You sure can girl. All cancelations bear an additional charge of x. After, you’ll receive a credit to your RENTADELLA account with the full dress rental with a year expiry.  Dress exchanges will incur an additional fee of x for keeping the dress booked. If the new dress is less than the previous, the remaining credits will go into your RENTADELLA account with a year expiry. If it's more, the surplus will be an additional charge (seperate to the x dress exchange fee).",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("I need a dress delivered today!",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "For last minute rentals, please contact us on LINE!",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Can I reserve in advance?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Yes, please use the app once registered or contact us on LINE to book your item.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Do you provide alterations?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Unfortunately we cannot provide alterations, but we offer a wide range of dresses to suit most content shapes and heights.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How do you clean your garments?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "A lot of care goes into ensuring our dresses fresh and clean. Our expert cleaning fairies use a variety of techniques to ensure that each style is dry cleaned, steamed and pressed, inspected for quality, and packaged with care so that it’s ready for another lucky lady to wear.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How do you clean your garments?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "A lot of care goes into ensuring our dresses fresh and clean. Our expert cleaning fairies use a variety of techniques to ensure that each style is dry cleaned, steamed and pressed, inspected for quality, and packaged with care so that it’s ready for another lucky lady to wear.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Can I cancel/exchange my order?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "You sure can girl. All cancelations bear an additional charge of x. After, you’ll receive a credit to your RENTADELLA account with the full dress rental with a year expiry.  Dress exchanges will incur an additional fee of x for keeping the dress booked. If the new dress is less than the previous, the remaining credits will go into your RENTADELLA account with a year expiry. If it's more, the surplus will be an additional charge (seperate to the x dress exchange fee).",
            color: contentColor,
            weight: FontWeight.normal)),
    // Item(header: const StyledHeader("", content: ""),
  ];

  final List<Item> renting_faqs = [
    Item(
        header: StyledHeading(
            "What if the dress I ordered doesn't fit/don't like it?",
            color: headerColor,
            weight: FontWeight.normal),
        content: const StyledHeading("")),
    Item(
        header: StyledHeading("What time can I collect my dress?",
            color: headerColor, weight: FontWeight.normal),
        content: const StyledHeading("")),
    Item(
        header: StyledHeading("Do I need to my wash my dress before returning?",
            color: headerColor, weight: FontWeight.normal),
        content: const StyledHeading("")),
    Item(
        header: StyledHeading("Can I buy the dress I rented?",
            color: headerColor, weight: FontWeight.normal),
        content: const StyledHeading("")),
    Item(
        header: StyledHeading("I've stained/damaged my dress!",
            color: headerColor, weight: FontWeight.normal),
        content: const StyledHeading("")),
    Item(
        header: StyledHeading("What is your late fee policy?",
            color: headerColor, weight: FontWeight.normal),
        content: const StyledHeading("")),
  ];

  final List<Item> covid_faqs = [
    Item(
        header: StyledHeading(
            "What if my event gets cancelled because of COVID?",
            color: headerColor,
            weight: FontWeight.normal),
        content: const StyledHeading("")),
  ];

  @override
  build(context) {
    final List<Item> dataGeneral = general_faqs;
    //  final List<Item> dataRenting = renting_faqs;
    double width = MediaQuery.of(context).size.width;

    return Expanded(
      child: Accordion(
        rightIcon: Icon(Icons.keyboard_arrow_down,
            color: Colors.black, size: width * 0.07),
        headerBorderRadius: 0,
        headerBorderColor: Colors.white,
        headerBorderColorOpened: Colors.transparent,
        // headerBorderWidth: 1,
        headerBackgroundColor: Colors.grey.shade200,
        headerBackgroundColorOpened: Colors.grey.shade200,
        contentBackgroundColor: Colors.white,
        contentBorderColor: Colors.transparent,
        // contentBorderColor: Colors.grey[300],
        contentBorderWidth: 3,
        contentHorizontalPadding: 20,
        scaleWhenAnimating: false,
        openAndCloseAnimation: true,
        headerPadding: const EdgeInsets.symmetric(vertical: 7, horizontal: 15),
        sectionOpeningHapticFeedback: SectionHapticFeedback.heavy,
        sectionClosingHapticFeedback: SectionHapticFeedback.light,
        children: dataGeneral.map<AccordionSection>((Item item) {
          return AccordionSection(
            header: item.header,
            content: item.content,
            contentVerticalPadding: 20,
          );
        }).toList(),
      ),
    );
  }
}
