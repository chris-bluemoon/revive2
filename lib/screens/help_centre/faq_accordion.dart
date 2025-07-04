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
        header: StyledHeading("How does the clothing rental marketplace work?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Our platform connects clothing owners with renters. Browse items from verified lenders, select your size and rental period, make payment, and arrange pickup or delivery. After your event, return the item to the owner. It's fashion sharing made simple!",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What types of clothing can I rent?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "You can rent dresses, suits, jackets, designer bags, shoes, formal wear, party outfits, and more! Our lenders offer everything from everyday wear to luxury designer pieces for special occasions.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How do I become a clothing lender?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Sign up as a lender, upload photos of your clothing items, set rental prices and availability, and start earning! We handle payments and provide guidelines for successful rentals. It's a great way to monetize your wardrobe.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What rental periods are available?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Rental periods vary by lender and typically range from 3 to 14 days. Each item listing shows available rental durations. Choose what works best for your event or occasion.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How are pickup and delivery arranged?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Lenders set their own pickup/delivery preferences. Some offer delivery within Bangkok for a fee (usually around 100฿), others prefer pickup. Check each listing for specific arrangements and contact the lender directly to coordinate.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What if an item doesn't fit or I don't like it?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Always check size guides and communicate with lenders before booking. If there's an issue upon pickup, discuss it immediately with the lender. Our platform encourages fair resolution between renters and lenders.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How do I know if an item is available?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Our app shows real-time availability based on each lender's calendar. If you can select your dates and complete booking, the item is available. Lenders manage their own availability schedules.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What happens if I damage a rented item?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Normal wear is expected, but renters are responsible for any damage beyond typical use. Contact the lender immediately if damage occurs. We facilitate fair resolution and may charge for cleaning or repairs based on the situation.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How are items cleaned between rentals?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Lenders are responsible for cleaning their items between rentals. Many use professional cleaning services to ensure quality. As a renter, you don't need to clean items before returning unless specified by the lender.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("Can I purchase an item I've rented?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Many lenders are open to selling their items! Contact the lender directly during or after your rental to discuss purchase options. We can facilitate the transaction through our platform.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What payment methods are accepted?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "We accept all major credit cards, debit cards, and mobile payments through our secure payment system. Payment is processed when you confirm your booking, and funds are released to lenders after successful rentals.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How do lenders set their prices?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Lenders set their own rental prices based on item value, brand, condition, and market demand. Our platform provides pricing guidance, but lenders have full control over their rates and any additional fees.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What's the cancellation policy?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Cancellation policies vary by lender. Most allow cancellations 24-48 hours before pickup for a full refund. Check each listing for specific terms. Emergency cancellations are handled case-by-case.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("How do I contact lenders directly?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "Once you book an item, you can message the lender directly through our in-app chat system. For urgent matters, contact us on LINE and we'll help facilitate communication.",
            color: contentColor,
            weight: FontWeight.normal)),
    Item(
        header: StyledHeading("What safety measures are in place?",
            color: headerColor, weight: FontWeight.normal),
        content: StyledBody(
            "All lenders are verified through our registration process. We facilitate secure payments, provide user ratings and reviews, and offer customer support for any issues. Always meet in safe, public locations for exchanges.",
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
