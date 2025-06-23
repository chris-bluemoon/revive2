import 'package:flutter/material.dart';
import 'package:revivals/shared/item_results.dart';
import 'package:revivals/shared/styled_text.dart';

class DesignerListView extends StatelessWidget {
  DesignerListView({super.key});

  final List<String> brands = ['BARDOT', 'HOUSE OF CB', 'LEXI', 'AJE', 'ALC', 'BRONX AND BANCO', 'ELIYA',
    'NADINE MERABI', 'REFORMATION', 'SELKIE', 'ZIMMERMANN', 'ROCOCO SAND', 'BAOBAB'];

  @override
  Widget build(BuildContext context) {
    brands.sort();
    return Column(
      children: [
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
              itemCount: brands.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => (ItemResults('brand', brands[index])))); 
                      },
                      child: ListTile(
                        dense: true,
                        visualDensity: const VisualDensity(vertical: -2),
                        title: StyledBody(brands[index], weight: FontWeight.normal),
                      ),
                    ),
                    const Divider(color: Colors.grey, indent: 20, endIndent: 20,),
                  ],
                );
              },
            ),
        ),
      ],
    );
  }
}