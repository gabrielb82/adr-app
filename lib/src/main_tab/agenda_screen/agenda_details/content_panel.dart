import 'package:academia_do_rock_app/src/services/firebase_cloud_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ContentPanel extends StatefulWidget {
  final DocumentSnapshot classData;
  final DocumentSnapshot user;

  ContentPanel({
    Key key,
    @required this.classData,
    @required this.user,
  }) : super(key: key);

  @override
  _ContentPanelState createState() => _ContentPanelState();
}

class _ContentPanelState extends State<ContentPanel> {
  final _contentFieldController = TextEditingController();

  @override
  void initState() {
    //Apagar notificações
    Firestore.instance
        .collection("users")
        .document(widget.user.documentID)
        .collection("notifications")
        .where("type", isEqualTo: "content")
        .where("reference", isEqualTo: widget.classData.documentID)
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
          _contentListPanel(),
          //_contentFieldPanel(),
        ],
      ),
    );
  }

  Widget _contentListPanel() {
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
                  "Conteúdo",
                  style: TextStyle(
                    color: Colors.white60,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
                  child: _listContent(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _listContent() {
    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance
          .collection("agenda")
          .document(widget.classData.documentID)
          .collection("contents")
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
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            snapshot.data.documents[index]["text"],
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
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
                  "Nenhum conteúdo",
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

  Widget _contentFieldPanel() {
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
                        child: contentField(),
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

  Widget contentField() {
    return TextField(
      controller: _contentFieldController,
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
        hintText: "Conteúdo",
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
        .collection("contents")
        .add({
      "user_id": widget.user.documentID,
      "name": widget.user.data["display_name"],
      "text": _contentFieldController.text,
      "content_date": DateTime.now()
    }).then((value) {
      widget.classData.data["students_id"].forEach((studentID) {
        Firestore.instance
            .collection("users")
            .document(studentID)
            .collection("notifications")
            .add({
          "date": DateTime.now(),
          "title": "Novo conteúdo",
          "message": _contentFieldController.text,
          "reference": widget.classData.documentID,
          "type": "content"
        }).then((notification) {
          Firestore.instance
              .collection("users")
              .document(studentID)
              .collection("notification_tokens")
              .getDocuments()
              .then((notificationTokens) {
            List<String> tokens = [];
            notificationTokens.documents.forEach((doc) {
              tokens.add(doc.data["token"].toString());
            });
            FirebaseCloudMessage.send(
              "Novo conteúdo",
              _contentFieldController.text,
              tokens,
            );
          });
        });
      });

      setState(() {});
    }).whenComplete(() {
      _contentFieldController.text = "";
    });
  }
}
