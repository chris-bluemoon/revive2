// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:image_picker/image_picker.dart';

// class AddItemsScreen extends StatefulWidget {
//   const AddItemsScreen({super.key});

//   @override
//   State<AddItemsScreen> createState() => _AddItemsScreenState();
// }

// class _AddItemsScreenState extends State<AddItemsScreen> {
//   final ImagePicker _picker = ImagePicker();
//   List<XFile>? _selectedImages = [];

//   Future<void> _pickImages() async {
//     try {
//       final List<XFile>? images = await _picker.pickMultiImage();
//       if (images != null) {
//         setState(() {
//           _selectedImages = images;
//         });
//       }
//     } catch (e) {
//       print('Error picking images: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // appBar: AppBar(
//       //   title: Text('Add Items'),
//       // ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Center(
//                 child: Text(
//                   'UPLOAD',
//                   style: TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Size',
//                   border: OutlineInputBorder(),
//                 ),
//               ),
//               const SizedBox(height: 10),
//               const TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Buy Price',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 10),
//               const TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Rent Price',
//                   border: OutlineInputBorder(),
//                 ),
//                 keyboardType: TextInputType.number,
//               ),
//               const SizedBox(height: 10),
//               const TextField(
//                 decoration: InputDecoration(
//                   labelText: 'Description',
//                   border: OutlineInputBorder(),
//                 ),
//                 maxLines: 3,
//               ),
//               const SizedBox(height: 10),
//               Row(
//                 children: [
//                   const Text(
//                     'Add Images',
//                     style: TextStyle(
//                       fontSize: 18,
//                     ),
//                   ),
//                   GestureDetector(
//                     onTap: _pickImages,
//                     child: const Icon(
//                       Icons.add_box_sharp,
//                       size: 30,
//                       color: Colors.black,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 4.0,
//                     mainAxisSpacing: 4.0,
//                   ),
//                   itemCount: _selectedImages?.length ?? 0,
//                   itemBuilder: (context, index) {
//                     return Image.file(
//                       File(_selectedImages![index].path),
//                       fit: BoxFit.cover,
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
