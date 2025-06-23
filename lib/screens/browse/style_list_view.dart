import 'package:flutter/material.dart';
import 'package:revivals/screens/browse/style_items.dart';
import 'package:revivals/shared/styled_text.dart';

class StyleListView extends StatelessWidget {
  const StyleListView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final leftRightPadding = screenWidth * 0.15;
   
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
                      GestureDetector(
  child: Container(
    margin: const EdgeInsets.all(15.0),
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
          child: const StyledHeading('CLASSIC', weight: FontWeight.normal),
        ),
        const Expanded(child: SizedBox()),
        Padding(
          padding: EdgeInsets.only(right: leftRightPadding),
          child: Image.asset('assets/img/items2/classic_transparent.png', height: screenWidth*0.2),
        ),
      ],
    )
  ),
  onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const StyleItems('classic'))));

  }
),
       GestureDetector(
         child: Container(
           margin: const EdgeInsets.all(15.0),
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
          child: Image.asset('assets/img/items2/vintage_transparent.png', height: screenWidth*0.2),
               ),
               const Expanded(child: SizedBox()),
               Padding(
                 padding: EdgeInsets.only(right: leftRightPadding),
                 child: const StyledHeading('VINTAGE', weight: FontWeight.normal),
               ),
             ],
           )
         ),
         onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const StyleItems('vintage'))));
         },
       ),
       GestureDetector(
  child: Container(
    margin: const EdgeInsets.all(15.0),
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
          child: const StyledHeading('ARTSY', weight: FontWeight.normal),
        ),
        const Expanded(child: SizedBox()),
        Padding(
          padding: EdgeInsets.only(right: leftRightPadding),
          child: Image.asset('assets/img/items2/artsy_transparent.png', height: screenWidth*0.2),
        ),
      ],
    )
  ),
  onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const StyleItems('artsy'))));

  }
),
              GestureDetector(
         child: Container(
           margin: const EdgeInsets.all(15.0),
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
          child: Image.asset('assets/img/items2/resort_transparent.png', height: screenWidth*0.2),
               ),
               const Expanded(child: SizedBox()),
               Padding(
                 padding: EdgeInsets.only(right: leftRightPadding),
                 child: const StyledHeading('RESORT', weight: FontWeight.normal),
               ),
             ],
           )
         ),
         onTap: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => (const StyleItems('resort'))));
         },
       ),



      ],
    );
  }
}