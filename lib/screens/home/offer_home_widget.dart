import 'package:flutter/material.dart';

class OfferWidget extends StatelessWidget {
  const OfferWidget({super.key});

  @override
  Widget build(BuildContext context) {
                      return Container(
                      // width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(horizontal: 5.0),
                      decoration: const BoxDecoration(color: Colors.white),
                      // child: StyledHeading('text $i'));
                      child: Image.asset('assets/img/backgrounds/carousel_banner_1.jpeg')
                      // child: Image.asset('assets/img/items2/LEXI_Dione_Item.webp'),
                      // child: Image.asset('assets/img/backgrounds/carousel_image_1.jpg'),
                      );

  }
}
