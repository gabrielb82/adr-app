import 'package:academia_do_rock_app/src/common_widgets/avatar_widget.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';

class DetailsPanel extends StatefulWidget {
  final DocumentSnapshot classData;
  final DocumentSnapshot userData;

  DetailsPanel({
    Key key,
    @required this.classData,
    @required this.userData,
  }) : super(key: key);

  @override
  _DetailsPanelState createState() => _DetailsPanelState();
}

class _DetailsPanelState extends State<DetailsPanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Column(
        children: <Widget>[
          _classData(),
          _studentsPanel(),
        ],
      ),
    );
  }

  Widget _studentsPanel() {
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
            //colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
          ),
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "Aluno(s)",
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
                Container(
                  height: 100,
                  child: _listStudents(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _classData() {
    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
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
        height: 100,
        //width: 100,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Horário",
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
              Row(
                children: <Widget>[
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.event_note,
                          color: Colors.white60,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            formatDate(widget.classData["date"].toDate(),
                                [dd, '/', mm, '/', yyyy]),
                            style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                    MediaQuery.of(context).size.width < 350
                                        ? 8
                                        : 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.access_time,
                          color: Colors.white60,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            formatDate(widget.classData["date"].toDate(),
                                [HH, ':', nn]),
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.timer,
                          color: Colors.white60,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "${widget.classData["duration"]} min",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listStudents() {
    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance
          .collection("agenda")
          .document(widget.classData.documentID)
          .collection("students")
          .getDocuments(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.done) {
            //_panel = MyData(userData: _userData);
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        // decoration: BoxDecoration(
                        //   boxShadow: [
                        //     BoxShadow(
                        //       blurRadius: 0.0,
                        //       color: Colors.black.withOpacity(.1),
                        //       offset: Offset(0, 0),
                        //     ),
                        //   ],
                        //   //shape: BoxShape.rectangle,
                        //   //border: Border.all(),
                        //   color: Colors.transparent,
                        // ),
                        child: AvatarWidget(
                            userID: snapshot.data.documents[index].documentID,
                            userName: snapshot.data.documents[index]["name"]),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                          child: AutoSizeText(
                            snapshot.data.documents[index]["name"],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.normal,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          }
        }
        return Container(
          color: Colors.transparent,
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
            ),
          ),
        );
      },
    );
  }
}
