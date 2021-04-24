import 'package:academia_do_rock_app/src/main_tab/news_screen/comment_item.dart';
import 'package:academia_do_rock_app/src/main_tab/news_screen/news_image.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class NewsDetails extends StatefulWidget {
  final String title;
  final String text;
  final String imageUrl;
  final String videoUrl;
  final Timestamp date;
  final int likes;
  final int comments;
  final String documentID;
  final DocumentSnapshot user;

  NewsDetails({
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
  }) : super(key: key);

  @override
  _NewsDetailsState createState() => _NewsDetailsState();
}

class _NewsDetailsState extends State<NewsDetails> {
  ScrollController _scrollController;
  IconData _likeIcon = Icons.favorite_border;
  Color _likeColor = Colors.grey;
  int _likeCount = 0;
  bool _isLiked = false;
  int _commentCount = 0;

  final _commentFieldController = TextEditingController();
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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    addViewCount();
    _commentCount = widget.comments;
    _likeCount = widget.likes;

    _videoPlayerController = VideoPlayerController.network(widget.videoUrl);
    _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        showControlsOnInitialize: false,
        autoPlay: false,
        autoInitialize: true,
        looping: false,
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
      } else {
        _videoPlayerController.pause();
        SystemChrome.setPreferredOrientations([
          DeviceOrientation.portraitUp,
          DeviceOrientation.portraitDown,
        ]);
      }
    });

    super.initState();
  }

  void addViewCount() {
    Firestore.instance
        .collection("news")
        .document(widget.documentID)
        .setData({"views": FieldValue.increment(1)}, merge: true);
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            centerTitle: false,
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              "Novidades",
              style: TextStyle(color: Colors.white60),
            ),
            pinned: true,
            floating: true,
            forceElevated: innerBoxIsScrolled,
            // bottom: AppBar(
            //     centerTitle: false,
            //     elevation: 0,
            //     backgroundColor: Colors.white,
            //     title: Container(
            //       width: double.infinity,
            //       height: 35,
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.start,
            //         crossAxisAlignment: CrossAxisAlignment.stretch,
            //         children: <Widget>[
            //           Container(),
            //         ],
            //       ),
            //     )),
          )
        ];
      },
      body: Scaffold(
        body: GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(new FocusNode());
          },
          child: Stack(
            children: <Widget>[
              newsData(),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _commentFieldPanel(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget videoPlayer() {
    final videoPlayerWidget = Chewie(
      controller: _chewieController,
    );

    return videoPlayerWidget;
  }

  Widget _commentFieldPanel() {
    return Card(
      margin: const EdgeInsets.all(0.0),
      elevation: 1,
      child: Container(
        alignment: Alignment.topLeft,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Colors.grey[800], Colors.grey[850]],
            //colors: [Theme.of(context).backgroundColor, Color(0xFF191919)],
          ),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Text(
              //   "Enviar comentário",
              //   style: TextStyle(
              //     fontSize: 20,
              //     fontWeight: FontWeight.bold,
              //   ),
              //   textAlign: TextAlign.left,
              // ),
              // Padding(
              //   padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
              //   child: Container(
              //     height: 2,
              //     width: MediaQuery.of(context).size.width * 0.99,
              //     color: Theme.of(context).primaryColor,
              //   ),
              // ),
              Container(
                padding: const EdgeInsets.all(1),
                width: double.infinity,
                child: Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: commentField(),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets.only(left: 8.0, right: 0, top: 3),
                        child: IconButton(
                          icon: Icon(
                            Icons.send,
                            color: Theme.of(context).primaryColor,
                            size: 30,
                          ),
                          onPressed: () {
                            sendComment();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget commentField() {
    return TextField(
      style: TextStyle(color: Colors.white),
      controller: _commentFieldController,
      autocorrect: false,
      autofocus: false,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      //textInputAction: TextInputAction.next,
      onSubmitted: (v) {
        //FocusScope.of(context).requestFocus(_lastNameFocus);
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(8.0),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey[900]),
        ),
        hintText: "Comentário",
        hintStyle: TextStyle(color: Colors.white60),
        filled: true,
        fillColor: Colors.grey[700],
      ),
      cursorColor: Colors.white60,
      showCursor: true,
    );
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
      child: CachedNetworkImage(
        imageUrl: widget.imageUrl,
        imageBuilder: (context, imageProvider) {
          return Container(
            decoration: BoxDecoration(
              //borderRadius: BorderRadius.circular(8),
              image: DecorationImage(image: imageProvider, fit: BoxFit.cover),
            ),
          );
        },
      ),
    );
  }

  Widget newsData() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Colors.grey[800], Colors.grey[850]],
          //colors: [Theme.of(context).backgroundColor, Color(0xFF191919)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            // decoration: BoxDecoration(
            //   gradient: LinearGradient(
            //       begin: Alignment.topLeft,
            //       end: Alignment.bottomRight,
            //       colors: [Colors.grey[800], Colors.grey[850]]),
            // ),
            color: Colors.black,
            width: double.infinity,
            height: 200,
            child: widget.videoUrl == "" ? imageWidget() : videoPlayer(),
          ),
          Container(
            width: double.infinity,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
                right: 8.0,
                bottom: 0,
              ),
              child: Text(
                widget.title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            color: Colors.transparent,
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
              style: TextStyle(fontSize: 12.0, color: Colors.white),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Html(
                data: widget.text,
                style: {
                  "div": Style(
                    color: Colors.white60,
                  ),
                  "body": Style(
                    color: Colors.white60,
                  ),
                },
              ),
              // child: Text(
              //   widget.text,
              //   style: TextStyle(fontSize: 14),
              //   textAlign: TextAlign.justify,
              // ),
            ),
          ),
          Container(
            height: 50,
            width: double.infinity,
            color: Colors.transparent,
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
                        .document(widget.user.documentID)
                        .snapshots(),
                    //.get(),
                    builder: (BuildContext context,
                        AsyncSnapshot<DocumentSnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.data.exists == true) {
                          _likeIcon = Icons.favorite;
                          _likeColor = Theme.of(context).primaryColor;
                          _isLiked = true;
                          return IconButton(
                            icon: Icon(_likeIcon),
                            color: _likeColor,
                            onPressed: () {
                              setLike();
                              setState(() {
                                _likeCount = _likeCount - 1;
                                _likeIcon = Icons.favorite_border;
                                _likeColor = Colors.white60;
                              });
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
                          setLike();
                          setState(() {
                            _likeCount = _likeCount + 1;
                            _likeIcon = Icons.favorite;
                            _likeColor = Theme.of(context).primaryColor;
                          });
                        },
                      );
                    },
                  ),
                ),
                Text(
                  "$_likeCount",
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Icon(
                    Icons.chat,
                    color: Colors.white60,
                  ),
                ),
                Text(
                  _commentCount.toString(),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
                Expanded(
                  child: Container(),
                ),
                // Icon(
                //   Icons.share,
                //   color: Colors.grey,
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
                //     style: TextStyle(color: Theme.of(context).primaryColor),
                //   ),
                // ),
              ],
            ),
          ),
          Container(
            height: 1,
            color: Colors.grey[900],
          ),
          listComments(),
          Container(
            height: 60,
          ),
        ],
      ),
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
          .document(widget.user.documentID)
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
          .document(widget.user.documentID)
          .setData({
        'name': widget.user.data["display_name"],
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
          .document(widget.user.documentID)
          .delete();
    }

    setState(() {});
  }

  Widget listComments() {
    return Expanded(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              //colors: [Colors.grey[800], Colors.grey[850]]),
              colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
        ),
        child: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection("news")
              .document(widget.documentID)
              .collection("comments")
              .orderBy("date")
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        //colors: [Colors.grey[800], Colors.grey[850]]),
                        colors: [
                          Theme.of(context).backgroundColor,
                          Color(0xFF191919)
                        ]),
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                      child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  )),
                );
              default:
                if (snapshot.data.documents.length == 0) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "Seja o primeiro a comentar!",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  );
                } else {
                  return MediaQuery.removePadding(
                    context: context,
                    removeTop: true,
                    child: ListView.builder(
                      itemCount: snapshot.data.documents.length,
                      itemBuilder: (BuildContext context, int index) {
                        return Column(
                          children: <Widget>[
                            CommentItem(
                              uid: snapshot.data.documents[index]["uid"],
                              name: snapshot.data.documents[index]["name"],
                              comment: snapshot.data.documents[index]
                                  ["comment"],
                              date: snapshot.data.documents[index]["date"],
                              avatar: snapshot.data.documents[index]["avatar"],
                            ),
                            // Divider(
                            //   color: Colors.grey,
                            // ),
                          ],
                        );
                      },
                    ),
                  );
                }
            }
          },
        ),
      ),
    );
  }

  void sendComment() {
    Firestore.instance
        .collection("news")
        .document(widget.documentID)
        .collection("comments")
        .add({
      "uid": widget.user.documentID,
      "name": widget.user.data["display_name"],
      "comment": _commentFieldController.text,
      "avatar": "",
      "date": DateTime.now()
    }).then((value) {
      Firestore.instance.collection("news").document(widget.documentID).setData(
        {
          "comments": _commentCount + 1,
        },
        merge: true,
      ).then((value) {
        Firestore.instance
            .collection("users")
            .document(widget.user.documentID)
            .collection("activities")
            .add({
          "activity": _commentFieldController.text,
          "title": "Comentou em '${widget.title}'.",
          "type": "comment",
          "date": DateTime.now()
        }).then((onValue) {
          _commentFieldController.text = "";
          setState(() {
            _commentCount = widget.comments + 1;
          });
        });
      });
    });
  }
}
