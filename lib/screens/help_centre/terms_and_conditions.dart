import 'package:flutter/material.dart';
import 'package:revivals/shared/styled_text.dart';

class TermsAndConditionsPage extends StatelessWidget {
  const TermsAndConditionsPage({super.key});

  // Example section widget for reuse
  Widget section(String title, String body) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 4),
          Text(body,
              style: const TextStyle(
                  fontSize: 15, color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    final sections = [
      'Elegibility',
      'Account Registration',
      'How It Works',
      'Rental Period and Return',
      'Payments and Fees',
      'Cancellations and Refunds',
      'User Conduct',
      'Insurance and Liability',
      'Platform Content',
      'Third-Party Services',
      'Disclaimers',
      'Limitation of Liability',
      'Indemnification',
      'Termination',
      'Changes to Terms', // <-- Added here
      'Governing Law and Jurisdiction',
      'Contact Us',
    ];

    final sectionBodies = [
      'To use the Platform, you must be at least 18 years old and legally capable of entering into binding contracts. By registering, you represent and warrant that you meet these requirements.',
      'You must create an account to use certain features of the Platform. You agree to provide accurate and complete information and to update it as necessary. You are responsible for all activities under your account and must maintain the confidentiality of your login credentials.',
      '''a. Listing Items
Users (“Lenders”) may list clothing and accessories (“Items”) for rent. Listings must include accurate descriptions, photos, sizes, condition, and pricing. We reserve the right to remove or modify listings that violate our policies or are deemed inappropriate.

b. Renting Items
Users (“Renters”) can rent available Items for a specified period. Renters agree to return Items in the same condition and by the agreed return date.''',
      '''The rental period begins on the delivery date and ends on the return date selected by the Renter.

Items must be returned using the pre-paid label (if applicable) or as otherwise agreed between parties.

Late returns may incur fees of £[amount] per day, up to the full retail value of the Item.

If an Item is lost, stolen, or returned in a damaged condition, the Renter may be liable for repair or replacement costs.''',
      '''Payments are processed via our third-party payment provider, [e.g., Stripe].

Lenders receive a portion of the rental fee after the rental is completed, minus service and payment processing fees.

Renters must pay the full rental fee upfront, along with any applicable delivery charges, taxes, or deposits.''',
      '''Renters may cancel a rental up to [e.g., 48 hours] before the rental start date for a full refund.

Cancellations after that period may be non-refundable.

Lenders may cancel a rental in case of damage, unavailability, or other valid reasons. In such cases, a full refund will be issued to the Renter.''',
      '''You agree to:

• Use the Platform in compliance with all laws and regulations.

• Not damage, misuse, or fraudulently list/rent any Items.

• Not engage in harassment, abuse, or discrimination against other users.

• Not upload or distribute viruses, malware, or any harmful content.

We reserve the right to suspend or terminate your account for any violation of these Terms.''',
      '''We do not offer insurance for Items unless explicitly stated. Lenders and Renters are responsible for handling disputes or damages.

We are not liable for any loss, damage, or dispute arising from rentals, except where required by law.''',
      'All content on the Platform, including logos, text, images, and software, is owned by or licensed to us and may not be copied or used without our prior written consent.',
      'The Platform may integrate with third-party services (e.g., payment processors). We are not responsible for the actions or terms of these services.',
      'The Platform is provided “as is” without warranties of any kind. We do not guarantee uninterrupted access, the condition of rented Items, or the conduct of users.',
      'To the maximum extent permitted by law, we shall not be liable for any indirect, incidental, or consequential damages, or for loss of profits, data, or goodwill.',
      'You agree to indemnify and hold harmless [App Name], its officers, employees, and affiliates from any claims or liabilities arising from your use of the Platform, your listings or rentals, or your violation of these Terms.',
      'We may suspend or terminate your access to the Platform at any time without notice, for any reason, including violation of these Terms.',
      '''We may modify these Terms at any time. Changes will be posted on the Platform and are effective immediately upon posting. Continued use of the Platform constitutes acceptance of the revised Terms.''', // Changes to Terms
      '''These Terms are governed by the laws of [Insert Country or State], without regard to conflict of law principles. Any disputes will be subject to the exclusive jurisdiction of the courts in [Insert Location].''',
      '''If you have questions about these Terms, contact us at:

Velaa
Email: [support@velaa.app]
Address: ''',
    ];

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(140), // Increased height for full title visibility
        child: AppBar(
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: width * 0.08),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const StyledTitle(
            'Terms and\nConditions',
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          elevation: Theme.of(context).appBarTheme.elevation ?? 4,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Introductory text under the AppBar
            const Text(
              'Last Updated: 24 June 2025\n\n'
              'Welcome to Velaa! These Terms and Conditions ("Terms") govern your access to and use of the [App Name] mobile application and website (collectively, the “Platform”), operated by [Company Name], referred to as "we", "us", or "our".\n\n'
              'By using or accessing the Platform, you agree...',
            ),
            ...List.generate(
              sections.length,
              (i) => section('${i + 1}. ${sections[i]}', sectionBodies[i]),
            ),
          ],
        ),
      ),
    );
  }
}