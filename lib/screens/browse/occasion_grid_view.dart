import 'package:flutter/material.dart';
import 'package:revivals/screens/browse/occasion_grid_tile.dart';
import 'package:revivals/shared/item_results.dart';
import 'package:revivals/shared/styled_text.dart';

class OccasionGridView extends StatelessWidget {
  OccasionGridView({super.key});

  final List occasions = ['Wedding Guest', 'Party', 'Elevated Daytime', 'Date Night', 'Work'];

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return GridView.builder(
          padding: const EdgeInsets.all(4.0),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, childAspectRatio: 1.5),
          itemCount: occasions.length, // <-- required
          itemBuilder: (_, i) => 
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => (ItemResults('occasion', occasions[i].toLowerCase()))));
                },
                child: Container(
                  // decoration: BoxDecoration(
                    // border: Border.all(color: Colors.blueAccent)
                  // ),
                  margin: EdgeInsets.all(width*0.03),
                  // color: Colors.white,
                  // child: Text('TEST')
                  child: Column(
                    children: [
                      OccasionGridTile(occasions[i].toLowerCase()),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          SizedBox(width: width*0.065),
                          StyledBody(occasions[i], weight: FontWeight.normal),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}