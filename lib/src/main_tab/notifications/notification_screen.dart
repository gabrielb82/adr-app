import 'package:academia_do_rock_app/src/main_tab/agenda_screen/agenda_detail.dart';
import 'package:academia_do_rock_app/src/models/notifications.dart';
import 'package:academia_do_rock_app/src/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NotificationScreen extends StatefulWidget {
  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  ScrollController _scrollController;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  DocumentSnapshot _userDocument;
  User _userData;
  List<Notifications> _notifications = [];
  List<Widget> _notificationTileList = [];

  bool _isLoading = true;

  @override
  void initState() {
    getNotifications();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: SafeArea(
        child: NestedScrollView(
          controller: _scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                centerTitle: false,
                backgroundColor: Theme.of(context).backgroundColor,
                title: Text(
                  "Notificações",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white60,
                  ),
                ),
                pinned: true,
                floating: true,
                forceElevated: innerBoxIsScrolled,
              )
            ];
          },
          body: MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.grey[800], Colors.grey[850]]),
                // colors: [
                //   Theme.of(context).backgroundColor,
                //   Color(0xFF191919)
                // ]),
              ),
              child: _isLoading
                  ? Center(
                      child: Container(
                        padding: EdgeInsets.only(top: 40),
                        child: CircularProgressIndicator(
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : (_notifications.length > 0
                      ? _listNotifications()
                      : _noNotifications()),
            ),
          ),
        ),
      ),
    );
  }

  void getNotifications() {
    _notifications.clear();
    _notificationTileList.clear();
    _auth.currentUser().then((currentUser) {
      _user = currentUser;
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .get()
          .then((user) {
        _userDocument = user;
        _userData = User.fromFirestore(user);
        Firestore.instance
            .collection("users")
            .document(_user.uid)
            .collection("notifications")
            .getDocuments()
            .then((docs) {
          docs.documents.forEach((n) {
            _notifications.add(Notifications.fromFirestore(n));
            _notificationTileList.add(_notificationTile(_notifications.last));
          });
          _isLoading = false;
          setState(() {});
        });
      }).catchError((e) {
        print("Algum problema no registro do usuário, ou faltando.");
      }).whenComplete(() {});
    });
  }

  Widget _noNotifications() {
    return Center(
      child: Text(
        "Nenhuma notificação",
        style: TextStyle(color: Colors.white60),
      ),
    );
  }

  Widget _listNotifications() {
    return ListView(
      children: _notificationTileList,
    );
  }

  Widget _notificationTile(Notifications n) {
    return GestureDetector(
      onTap: () {
        _isLoading = false;
        setState(() {});
        Firestore.instance
            .collection("agenda")
            .document(n.reference)
            .get()
            .then((agendaDoc) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgendaDetail(
                classData: agendaDoc,
                userData: _userDocument,
              ),
            ),
          ).then((onValue) {
            getNotifications();
          });
          //getNotifications();
          setState(() {});
        }).whenComplete(() {
          //getNotifications();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              //colors: [Colors.grey[800], Colors.grey[850]]),
              colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
        ),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Icon(
                      notificationIcon(n.type),
                      color: notificationColor(n.type),
                      size: 30,
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          n.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.white,
                          ),
                        ),
                        Container(
                          height: 10,
                        ),
                        Text(
                          n.message,
                          style: TextStyle(
                            color: Colors.white60,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Center(
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 1,
              color: Colors.grey[800],
            ),
          ],
        ),
      ),
    );
  }

  IconData notificationIcon(String type) {
    switch (type) {
      case "class":
        return Icons.star;
        break;
      case "class_confirm":
        return Icons.event_available;
        break;
      case "class_reject":
        return Icons.event_busy;
        break;
      case "content":
        return Icons.assignment;
        break;
      case "comment":
        return Icons.comment;
        break;
      default:
        return Icons.info;
    }
  }

  Color notificationColor(String type) {
    switch (type) {
      case "class":
        return Theme.of(context).primaryColor;
        break;
      case "class_confirm":
        return Colors.green[400];
        break;
      case "class_reject":
        return Colors.red[400];
        break;
      case "content":
        return Colors.blue[400];
        break;
      case "comment":
        return Colors.blue[400];
        break;
      default:
        return Theme.of(context).primaryColor;
    }
  }
}
