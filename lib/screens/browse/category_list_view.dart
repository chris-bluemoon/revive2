import 'package:flutter/material.dart';
import 'package:revivals/shared/item_results.dart';
import 'package:revivals/shared/styled_text.dart';


class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final leftRightPadding = screenWidth * 0.15;
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
       GestureDetector(
         child: Container(
           margin: EdgeInsets.all(screenWidth*0.02),
           padding: const EdgeInsets.all(0),
           decoration: BoxDecoration(
             border: Border.all(color: Colors.white),
             borderRadius: BorderRadius.circular(5.0), 
             color: Colors.grey,
             gradient: const LinearGradient(
               colors: [Colors.grey, Colors.white],
               stops: [0.2, 1.0],
               // stops: [0.0, 0.5, 1.0],
             ),
           ),
           child: Row(
             children: [
               Padding(
          padding: EdgeInsets.only(left: leftRightPadding),
          child: Image.asset('assets/img/items2/transparent_dress.webp', height: screenWidth*0.2),
               ),
               const Expanded(child: SizedBox(width: 0),),
               const Padding(
                 padding: EdgeInsets.fromLTRB(0,0,50,0),
                 child: StyledHeading('DRESSES', weight: FontWeight.normal),
               ),
             ],
           )
         ),
         onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const ItemResults('type','dress'))));
         },
       ),
       GestureDetector(
  child: Container(
    margin: EdgeInsets.all(screenWidth*0.02),
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(5.0), 
      color: Colors.grey,
      gradient: const LinearGradient(
        // begin: Alignment.topCenter,
        // end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.grey],
        stops: [0.1, 1.0],
        // stops: [0.0, 0.5, 1.0],
      ),
    ),
    child: Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: leftRightPadding),
          child: const StyledHeading('BAGS', weight: FontWeight.normal)
        ),
               const Expanded(child: SizedBox(width: 0),),
        // const SizedBox(width: 0),
        Padding(
          padding: EdgeInsets.only(right: leftRightPadding),
          child: Image.asset('assets/img/items2/bag_transparent.png', height: screenWidth*0.2),
        ),
      ],
    )
  ),
  onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const ItemResults('type', 'bag'))));

  }
),
              GestureDetector(
         child: Container(
           margin: EdgeInsets.all(screenWidth*0.02),
           padding: const EdgeInsets.all(0),
           decoration: BoxDecoration(
             border: Border.all(color: Colors.white),
             borderRadius: BorderRadius.circular(5.0), 
             color: Colors.grey,
             gradient: const LinearGradient(
               colors: [Colors.grey, Colors.white],
               stops: [0.2, 1.0],
               // stops: [0.0, 0.5, 1.0],
             ),
           ),
           child: Row(
             children: [
               Padding(
          padding: EdgeInsets.only(left: leftRightPadding),
          child: Image.asset('assets/img/items2/jacket_transparent2.webp', height: screenWidth*0.2),
               ),
               const Expanded(child: SizedBox(width: 0),),
               Padding(
                 padding: EdgeInsets.only(right: leftRightPadding),
                 child: const StyledHeading('JACKETS', weight: FontWeight.normal)
               ),
             ],
           )
         ),
         onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const ItemResults('type','jacket'))));
         },
       ),
              GestureDetector(
  child: Container(
    margin: EdgeInsets.all(screenWidth*0.02),
    padding: const EdgeInsets.all(0),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.white),
      borderRadius: BorderRadius.circular(5.0), 
      color: Colors.grey,
      gradient: const LinearGradient(
        // begin: Alignment.topCenter,
        // end: Alignment.bottomCenter,
        colors: [Colors.white, Colors.grey],
        stops: [0.1, 1.0],
        // stops: [0.0, 0.5, 1.0],
      ),
    ),
    child: Row(
      children: [
        Padding(
          padding: EdgeInsets.only(left: leftRightPadding),
          child: const StyledHeading('PANTSUITS', weight: FontWeight.normal),
        ),
        const Expanded(child: SizedBox()),
        Padding(
          padding: EdgeInsets.only(right: leftRightPadding),
          child: Image.asset('assets/img/items2/pantsuit_transparent.png', height: screenWidth*0.2),
        ),
      ],
    )
  ),
  onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const ItemResults('type','pantsuit'))));

  }
),


      ],
    );
  }
}