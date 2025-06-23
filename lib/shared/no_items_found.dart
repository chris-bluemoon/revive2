import 'package:flutter/material.dart';
import 'package:revivals/shared/styled_text.dart';

class NoItemsFound extends StatelessWidget {
  const NoItemsFound({super.key});
 

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Column(
      children: [
        SizedBox(height: width * 0.5),
        Center(child: Image.asset('assets/img/icons/no_search_result_icon.webp', height: width * 0.1)),
        SizedBox(height: width * 0.03),
        const Center(child: StyledHeading('No Results Found')),
        SizedBox(height: width * 0.03),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: width * 0.08),
          child: const Center(
            child: Text(
              'Sorry, no items matched your criteria. Please try adjusting your search or filters.',
              style: TextStyle(
                fontWeight: FontWeight.normal,
                fontSize: 18, // or match StyledHeading's size
              ),
              softWrap: true,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        // ElevatedButton(
        //   onPressed: () {
        //                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => (FiltersPage(setFilter: setFilter, setValues: setValues))));

        //   }  , 
        //   child: const Text('RESET')
        // )
      ],
    );
  }
}