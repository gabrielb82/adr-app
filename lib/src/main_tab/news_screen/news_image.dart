import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class NewsImage extends StatefulWidget {
  final String title;
  final String imageUrl;

  NewsImage({
    Key key,
    @required this.title,
    @required this.imageUrl,
  }) : super(key: key);

  @override
  _NewsImageState createState() => _NewsImageState();
}

class _NewsImageState extends State<NewsImage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white, //change your color here
        ),
      ),
      body: Container(
        color: Colors.black,
        width: double.infinity,
        height: double.infinity,
        child: Center(
          child: CachedNetworkImage(
            imageUrl: widget.imageUrl,
            imageBuilder: (context, imageProvider) {
              return Container(
                decoration: BoxDecoration(
                  //borderRadius: BorderRadius.circular(8),
                  image: DecorationImage(
                      image: imageProvider, fit: BoxFit.fitWidth),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
