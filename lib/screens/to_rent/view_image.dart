import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:revivals/shared/loading.dart';
import 'package:revivals/shared/styled_text.dart';

class ViewImage extends StatefulWidget {
  const ViewImage(this.thisImages, this.page,
      {super.key, this.isNetworkImage = true});
  final bool isNetworkImage;
  final int page;
  final List<String> thisImages;

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  late int currPage;
  late List<String> localImages;

  @override
  void initState() {
    super.initState();
    currPage = widget.page; // Initialize with the starting page
    localImages = List<String>.from(widget.thisImages); // Make a copy
  }

  bool _isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    PageController pageController =
        PageController(initialPage: widget.page - 1);
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        appBar: AppBar(
          toolbarHeight: width * 0.2,
          centerTitle: true,
          title: StyledTitle(
              '${currPage.toString()} / ${widget.thisImages.length}'),
          leading: IconButton(
            icon: Icon(Icons.chevron_left, size: width * 0.08),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: PhotoViewGallery.builder(
          itemCount: widget.thisImages.length,
          loadingBuilder: (context, event) => const Center(
            child: SizedBox(
              width: 20.0,
              height: 20.0,
              child: Loading(),
            ),
          ),
          backgroundDecoration: const BoxDecoration(
            color: Colors.white,
          ),
          onPageChanged: (page) {
            setState(() {
              currPage = page + 1; // Update state so AppBar title rebuilds
            });
          },
          pageController: pageController,
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return _isNetworkImage(widget.thisImages[index])
                ? PhotoViewGalleryPageOptions.customChild(
                    initialScale: PhotoViewComputedScale.contained * 1,
                    minScale: PhotoViewComputedScale.contained * 1, // Prevent zooming out smaller than original
                    maxScale: PhotoViewComputedScale.covered * 2.0, // Allow zoom in
                    child: SizedBox(
                      height: 180, // or use MediaQuery for dynamic sizing
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: widget.thisImages[index].isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: widget.thisImages[index],
                                placeholder: (context, url) => const Loading(),
                                errorWidget: (context, url, error) =>
                                    Image.asset(
                                        'assets/img/items/No_Image_Available.jpg'),
                                fit: BoxFit.cover,
                              )
                            : Image.asset(
                                'assets/img/items/No_Image_Available.jpg',
                                fit: BoxFit.cover,
                              ),
                      ),
                    ))
                : PhotoViewGalleryPageOptions(
                    imageProvider: FileImage(File(widget.thisImages[index])),
                    initialScale: PhotoViewComputedScale.contained * 1,
                    minScale: PhotoViewComputedScale.contained * 1, // Prevent zooming out smaller than original
                    maxScale: PhotoViewComputedScale.covered * 2.0, // Allow zoom in
                  );
          },
        ));
  }
}
