import 'package:academia_do_rock_app/src/common_widgets/avatar_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentsPanel extends StatefulWidget {
  final DocumentSnapshot classData;
  final DocumentSnapshot user;

  CommentsPanel({
    Key key,
    @required this.classData,
    @required this.user,
  }) : super(key: key);

  @override
  _CommentsPanelState createState() => _CommentsPanelState();
}

class _CommentsPanelState extends State<CommentsPanel> {
  final _commentFieldController = TextEditingController();

  @override
  void initState() {
    //Apagar notificações
    Firestore.instance
        .collection("users")
        .document(widget.user.documentID)
        .collection("notifications")
        .where("type", isEqualTo: "comment")
        .getDocuments()
        .then((notifications) {
      notifications.documents.forEach((notification) {
        Firestore.instance
            .collection("users")
            .document(widget.user.documentID)
            .collection("notifications")
            .document(notification.documentID)
            .delete();
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      //height: 100,
      child: Column(
        children: <Widget>[
          _commentsListPanel(),
          //_commentFieldPanel(),
        ],
      ),
    );
  }

  Widget _commentsListPanel() {
    return Expanded(
      child: Card(
        color: Colors.transparent,
        margin: const EdgeInsets.all(12.0),
        elevation: 0,
        child: Container(
          alignment: Alignment.topLeft,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[800], Colors.grey[850]]),
            // colors: [
            //   Theme.of(context).backgroundColor,
            //   Color(0xFF191919)
            // ]),
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Comentários",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                  ),
                  textAlign: TextAlign.left,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Container(
                    height: 2,
                    width: MediaQuery.of(context).size.width * 0.99,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                Expanded(
                  child: _listComments(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listComments() {
    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance
          .collection("agenda")
          .document(widget.classData.documentID)
          .collection("comments")
          .orderBy("date")
          .getDocuments(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text("Erro ao buscar comentários");
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
              )),
            );
          default:
            if (snapshot.hasData && snapshot.data.documents.length > 0) {
              return MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(0.0),
                      child: Card(
                        color: Colors.grey[600],
                        elevation: 1,
                        child: _commentItem(
                            snapshot.data.documents[index]["user_id"],
                            snapshot.data.documents[index]["name"],
                            snapshot.data.documents[index]["text"],
                            snapshot.data.documents[index]["comment_date"]),
                      ),
                    );
                  },
                ),
              );
            } else {
              return Container(
                padding: const EdgeInsets.all(18.0),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Nenhum comentário",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            }
        }
      },
    );
  }

  Widget _commentItem(
      String userID, String userName, String comment, Timestamp commentDate) {
    DateTime now = DateTime.now();

    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Container(
              color: Colors.transparent,
              child: AvatarWidget(
                userID: userID,
                userName: userName,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                child: AutoSizeText(
                  userName,
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.normal,
                      color: Colors.white),
                  maxLines: 1,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                timeago
                    .format(
                      DateTime.now().subtract(
                        now.difference(commentDate.toDate()),
                      ),
                      locale: 'pt_BR_short',
                    )
                    .replaceAll("~", ""),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(18.0),
          child: Container(
            width: double.infinity,
            child: Text(
              comment,
              textAlign: TextAlign.justify,
              style: TextStyle(color: Colors.white60),
            ),
          ),
        ),
        // Container(
        //   width: double.infinity,
        //   height: 1,
        //   color: Colors.grey,
        // ),
      ],
    );
  }

  Widget _commentFieldPanel() {
    return Card(
      margin: const EdgeInsets.all(0.0),
      elevation: 0,
      child: Container(
        alignment: Alignment.topLeft,
        color: Colors.white,
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
          borderSide: BorderSide(color: Colors.grey),
        ),
        hintText: "Comentário",
        filled: true,
        fillColor: Colors.white,
      ),
      cursorColor: Colors.black,
      showCursor: true,
    );
  }

  void sendComment() {
    Firestore.instance
        .collection("agenda")
        .document(widget.classData.documentID)
        .collection("comments")
        .add({
      "user_id": widget.user.documentID,
      "name": widget.user.data["display_name"],
      "text": _commentFieldController.text,
      "comment_date": DateTime.now()
    }).then((value) {
      Firestore.instance
          .collection("agenda")
          .document(widget.classData.documentID)
          .setData(
        {
          "comments_count": widget.classData["comments_count"] + 1,
        },
        merge: true,
      ).then((value) {
        _commentFieldController.text = "";
        setState(() {});
      });
    });
  }
}
