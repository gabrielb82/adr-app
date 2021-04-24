import 'package:academia_do_rock_app/src/main_tab/news_screen/news_details.dart';
import 'package:academia_do_rock_app/src/main_tab/news_screen/news_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class NewsItem extends StatefulWidget {
  final String title;
  final String text;
  final String imageUrl;
  final String videoUrl;
  final int likes;
  final int comments;
  final Timestamp date;
  final String documentID;
  final FirebaseUser user;
  final DocumentSnapshot userData;

  NewsItem({
    Key key,
    @required this.documentID,
    @required this.title,
    @required this.text,
    @required this.imageUrl,
    @required this.date,
    this.videoUrl = "",
    this.likes = 0,
    this.comments = 0,
    @required this.user,
    @required this.userData,
  }) : super(key: key);

  @override
  _NewsItemState createState() => _NewsItemState();
}

class _NewsItemState extends State<NewsItem> {
  IconData _likeIcon = Icons.favorite_border;
  Color _likeColor = Colors.white60;
  int _likeCount = 0;
  bool _isLiked = false;

  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    //if (_videoPlayerController != null) _videoPlayerController.dispose();
  }

  @override
  void initState() {
    super.initState();

    // _userData = await Firestore.instance
    //     .collection("users")
    //     .document(widget.user.uid)
    //     .get();

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        showControlsOnInitialize: false,
        //aspectRatio: 3 / 2,
        autoPlay: false,
        autoInitialize: true,
        looping: false,
        // systemOverlaysAfterFullScreen: ,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
    _chewieController.addListener(() async {
      _videoPlayerController.pause();
      if (_chewieController.isFullScreen) {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ]);
        // setState(() {});
      } else {
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
        // setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.transparent,
      //color: Colors.white,
      //shadowColor: Colors.transparent,
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[800], Colors.grey[850]]),
          //colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
        ),
        width: double.infinity,
        //height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: double.infinity,
              height: 200,
              color: Colors.black,
              child:
                  widget.videoUrl == "" ? imageWidget() : _videoPlayerWidget(),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
                right: 8.0,
                bottom: 0,
              ),
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 8.0, bottom: 10.0),
              width: double.infinity,
              child: Text(
                timeago
                    .format(
                      DateTime.now().subtract(
                        DateTime.now().difference(widget.date.toDate()),
                      ),
                      locale: 'pt_BR_short',
                    )
                    .replaceAll("~", ""),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 12.0,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 0.0,
                right: 0.0,
                bottom: 20.0,
              ),
              child: GestureDetector(
                onTap: () {
                  _videoPlayerController.pause();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NewsDetails(
                              documentID: widget.documentID,
                              title: widget.title,
                              text: widget.text,
                              imageUrl: widget.imageUrl,
                              videoUrl: widget.videoUrl,
                              date: widget.date,
                              likes: widget.likes,
                              comments: widget.comments,
                              user: widget.userData,
                            )),
                  );
                },
                child: Html(
                  data: widget.text,
                  style: {
                    "div": Style(
                      color: Colors.white60,
                    ),
                    "body": Style(
                      color: Colors.white60,
                      fontSize: FontSize(18),
                    ),
                  },
                ),
              ),
              // child: Text(widget.text,
              //     textAlign: TextAlign.justify,
              //     softWrap: true,
              //     style: TextStyle(fontSize: 16.0)
              //     //maxLines: 4,
              //     ),
            ),
            Container(
              height: 50,
              width: double.infinity,

              //color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(right: 0.0, left: 0.0),
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: Firestore.instance
                          .collection("news")
                          .document(widget.documentID)
                          .collection("likes")
                          .document(widget.user.uid)
                          .snapshots(),
                      builder: (BuildContext context,
                          AsyncSnapshot<DocumentSnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.active) {
                          if (snapshot.data.exists == true) {
                            _likeIcon = Icons.favorite;
                            _likeColor = Theme.of(context).primaryColor;
                            _isLiked = true;
                            return IconButton(
                              icon: Icon(_likeIcon),
                              color: _likeColor,
                              onPressed: () {
                                setState(() {
                                  _likeIcon = Icons.favorite_border;
                                  _likeColor = Colors.white60;
                                });
                                setLike();
                              },
                            );
                          }
                        }
                        _likeIcon = Icons.favorite_border;
                        _likeColor = Colors.white60;
                        _isLiked = false;
                        return IconButton(
                          icon: Icon(_likeIcon),
                          color: _likeColor,
                          onPressed: () {
                            setState(() {
                              _likeIcon = Icons.favorite;
                              _likeColor = Theme.of(context).primaryColor;
                            });
                            setLike();
                          },
                        );
                      },
                    ),
                  ),
                  likeCount(),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 0.0, bottom: 0.0, right: 0.0, left: 0.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.chat,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        _videoPlayerController.pause();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => NewsDetails(
                                    documentID: widget.documentID,
                                    title: widget.title,
                                    text: widget.text,
                                    imageUrl: widget.imageUrl,
                                    videoUrl: widget.videoUrl,
                                    date: widget.date,
                                    likes: widget.likes,
                                    comments: widget.comments,
                                    user: widget.userData,
                                  )),
                        );
                      },
                    ),
                  ),
                  Text(
                    "${widget.comments}",
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(0.0),
                  //   child: Container(
                  //     child: Icon(
                  //       Icons.share,
                  //       color: Colors.grey,
                  //     ),
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(
                  //     top: 8.0,
                  //     right: 8.0,
                  //     bottom: 8.0,
                  //     left: 4.0,
                  //   ),
                  //   child: Text(
                  //     "compartilhar",
                  //     textDirection: TextDirection.rtl,
                  //     style: TextStyle(
                  //       color: Theme.of(context).primaryColor,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _videoPlayerWidget() {
    final videoPlayerWidget = Chewie(
      controller: _chewieController,
    );
    return videoPlayerWidget;
  }

  Widget imageWidget() {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute<Null>(
              builder: (BuildContext context) {
                return NewsImage(
                  title: widget.title,
                  imageUrl: widget.imageUrl,
                );
              },
              fullscreenDialog: true,
            ));
      },
      child: Padding(
        padding: const EdgeInsets.all(0.0),
        child: CachedNetworkImage(
          imageUrl: widget.imageUrl,
          imageBuilder: (context, imageProvider) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget likeCount() {
    return StreamBuilder<DocumentSnapshot>(
      stream: Firestore.instance
          .collection("news")
          .document(widget.documentID)
          .snapshots(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.data.exists == true) {
            return Text(
              snapshot.data["likes"].toString(),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            );
          } else {
            return Text(
              "0",
              style: TextStyle(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
        }
        return Text(
          "0",
          style: TextStyle(
            color: Theme.of(context).primaryColor,
          ),
        );
      },
    );
  }

  void setLike() async {
    _isLiked = !_isLiked;

    if (_isLiked == true) {
      await Firestore.instance
          .collection("news")
          .document(widget.documentID)
          .setData({"likes": FieldValue.increment(1)}, merge: true);
      await Firestore.instance
          .collection("users")
          .document(widget.user.uid)
          .collection("activities")
          .add({
        "activity": "Like",
        "title": "Deu um like em '${widget.title}'.",
        "type": "comment",
        "date": DateTime.now()
      });
      await Firestore.instance
          .collection("news")
          .document(widget.documentID)
          .collection("likes")
          .document(widget.user.uid)
          .setData({
        'name': widget.userData.data["display_name"],
        'date': DateTime.now()
      }).catchError((onError) {
        print(onError);
      });
    } else {
      await Firestore.instance
          .collection("news")
          .document(widget.documentID)
          .setData({"likes": FieldValue.increment(-1)}, merge: true);
      await Firestore.instance
          .collection("news")
          .document(widget.documentID)
          .collection("likes")
          .document(widget.user.uid)
          .delete();
    }

    setState(() {});
  }
}
