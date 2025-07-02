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
        header: StyledHeading("How does dress rental work?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Browse our collection, select your size and rental period, make payment, and we'll deliver your dress. After your event, simply return it using our prepaid return bag. No dry cleaning needed!",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What rental periods do you offer?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "We offer flexible rental periods from 3 to 14 days. Choose the duration that best fits your needs when booking your dress.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How much does delivery cost?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Delivery within Bangkok is 100฿. We offer same-day delivery for orders placed before 2 PM, or next-day delivery for later orders.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What if my dress doesn't fit?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "We offer a backup size service for 200฿ extra. If your dress doesn't fit, contact us immediately and we'll arrange an exchange if available. Check our size guide before ordering!",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Can I cancel or change my order?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "You can cancel up to 24 hours before your delivery date for a full refund. Changes to size or style depend on availability. Contact us on LINE for assistance.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How do I know if a dress is available?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Our app shows real-time availability. If you can add it to your cart and complete checkout, it's available for your selected dates.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What happens if I damage the dress?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Minor wear and tear is expected. For significant damage or stains, we may charge a cleaning or replacement fee. We'll assess each case individually and contact you before any charges.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How are the dresses cleaned?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "All dresses are professionally dry cleaned, steamed, and quality checked between rentals. We use specialized cleaning techniques for different fabrics to ensure freshness and quality.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Can I purchase a dress I've rented?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Yes! Many of our dresses are available for purchase. Contact us during your rental period and we'll provide purchase pricing and arrange the sale.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What payment methods do you accept?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "We accept all major credit cards, debit cards, and mobile payments through our secure Stripe payment system. Payment is required at the time of booking.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Do you offer alterations?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "We don't provide alterations as our dresses need to fit multiple customers. However, we carry a wide range of sizes and styles to suit different body types.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What's your late return policy?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Late returns incur a daily fee equal to one day's rental rate. Please contact us if you need to extend your rental period - we're often flexible if notified in advance.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How do I become a dress owner/lender?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Join our community of dress owners! Upload photos of your designer dresses, set your rental prices, and earn money from your wardrobe. We handle payments, cleaning, and delivery.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Need help with last-minute rentals?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "For same-day or urgent rentals, contact us directly on LINE! We'll check availability and arrange express delivery if possible.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What occasions are your dresses suitable for?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledHeading(
            "Our collection includes dresses for weddings, cocktail parties, galas, business events, date nights, photoshoots, and any special occasion where you want to look amazing!",
            color: contentColor,
            weight: FontWeight.normal)),
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
