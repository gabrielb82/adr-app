import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class AvatarWidget extends StatefulWidget {
  final String userID;
  final String userName;

  AvatarWidget({
    Key key,
    @required this.userID,
    @required this.userName,
  }) : super(key: key);

  @override
  _AvatarWidgetState createState() => _AvatarWidgetState();
}

class _AvatarWidgetState extends State<AvatarWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Center(
        child: Container(
          color: Colors.transparent,
          width: 40,
          height: 40,
          child: avatarImage(widget.userID, widget.userName[0]),
        ),
      ),
    );
  }

  Widget avatarImage(String userID, String displayNameInitials) {
    return FutureBuilder<dynamic>(
        future: FirebaseStorage.instance
            .ref()
            .child("profile/$userID/avatar.jpg")
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

  // Widget avatarImage(String url, String displayNameInitials) {
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
