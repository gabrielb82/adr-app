import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentItem extends StatefulWidget {
  final String uid;
  final String name;
  final String comment;
  final Timestamp date;
  final String avatar;

  CommentItem({
    Key key,
    @required this.uid,
    @required this.name,
    @required this.comment,
    @required this.date,
    @required this.avatar,
  }) : super(key: key);
  @override
  _CommentItemState createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  String _imageUrl = "";

  @override
  void initState() {
    super.initState();
  }

  // final difference = new DateTime.now().difference(widget.date.toDate());
  DateTime now = DateTime.now();
  //Duration diff = now.difference(widget.date.toDate());
  final difference = new DateTime.now().subtract(new Duration(minutes: 15));
  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[800], Colors.grey[850]]),
            //colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                color: Colors.transparent,
                child: avatar(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          widget.comment,
                          style: TextStyle(color: Colors.white60),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, right: 12.0),
                child: Text(
                  timeago
                      .format(
                        DateTime.now().subtract(
                          now.difference(widget.date.toDate()),
                        ),
                        locale: 'pt_BR_short',
                      )
                      .replaceAll("~", ""),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: 1,
          color: Colors.grey[900],
        ),
      ],
    );
  }

  Widget avatar() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Center(
        child: Container(
          color: Colors.transparent,
          width: 40,
          height: 40,
          child: avatarImage("", widget.name[0]),
        ),
      ),
    );
  }

  Widget avatarImage(String url, String displayNameInitials) {
    return FutureBuilder<dynamic>(
        future: FirebaseStorage.instance
            .ref()
            .child("profile/${widget.uid}/avatar.jpg")
            .getDownloadURL(),
        builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasError) {
            print(snapshot.error);
          }
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  ),
                ),
              );
            default:
              return CircularProfileAvatar(
                snapshot.data.toString(),
                radius: 50,
                backgroundColor: Colors.transparent,
                borderWidth: 1,
                initialsText: Text(
                  displayNameInitials,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
                borderColor: Theme.of(context).primaryColor,
                elevation: 1,
                cacheImage: true,
              );
          }
          // return CircularProfileAvatar(
          //   "",
          //   radius: 50,
          //   backgroundColor: Colors.transparent,
          //   borderWidth: 1,
          //   initialsText: Text(
          //     displayNameInitials,
          //     style: TextStyle(fontSize: 20, color: Colors.white),
          //   ),
          //   borderColor: Theme.of(context).primaryColor,
          //   elevation: 1,
          //   cacheImage: true,
          // );
        });
  }

  //   var ref = FirebaseStorage.instance
  //       .ref()
  //       .child("profile/HCnZpcu0zhT9HRq5NW3zocxPCs93/avatar.jpg");
  //   ref.getDownloadURL().then((loc) {
  //     setState(() {
  //       _imageUrl = Uri.decodeFull(loc.toString());
  //     });
  //   });
  //   return CircularProfileAvatar(
  //     url,
  //     radius: 50,
  //     backgroundColor: Colors.transparent,
  //     borderWidth: 1,
  //     initialsText: Text(
  //       displayNameInitials,
  //       style: TextStyle(fontSize: 20, color: Colors.white),
  //     ),
  //     borderColor: Theme.of(context).primaryColor,
  //     elevation: 1,
  //     cacheImage: true,
  //   );
  // }
}
