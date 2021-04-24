import 'package:academia_do_rock_app/src/common_widgets/avatar_widget.dart';
import 'package:academia_do_rock_app/src/models/classess.dart';
import 'package:academia_do_rock_app/src/models/user.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

class UserListScreen extends StatefulWidget {
  final DocumentSnapshot userData;

  UserListScreen({
    Key key,
    @required this.userData,
  }) : super(key: key);
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  bool _isLoading = true;
  final Firestore _db = Firestore.instance;
  List<User> _users = [];
  List<User> _filteredUsers = [];

  final _searchBarFieldController = TextEditingController();
  bool _searching = false;
  Color _tileColor = Colors.white;

  @override
  void dispose() {
    _searchBarFieldController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _searchBarFieldController.addListener(() {
      setState(() {
        _searching = _searchBarFieldController.text.length > 0 ? true : false;
        if (_searching) {
          _filteredUsers = _users
              .where((u) => u.displayName
                  .toLowerCase()
                  .contains(_searchBarFieldController.text.toLowerCase()))
              .toList();
        }
      });
    });
    getUsers();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: NestedScrollView(
        // controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).backgroundColor,
              title: AutoSizeText(
                "Selecione um aluno",
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 24,
                ),
              ),
              pinned: true,
              floating: true,
              forceElevated: innerBoxIsScrolled,
            )
          ];
        },
        body: _isLoading
            ? Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        //colors: [Colors.grey[850], Colors.grey[900]]),
                        colors: [
                          Theme.of(context).backgroundColor,
                          Color(0xFF191919)
                        ]),
                  ),
                  padding: EdgeInsets.only(top: 40),
                  child: CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              )
            : _listScreen(),
      ),
    );
  }

  Widget _listScreen() {
    return Column(
      children: <Widget>[
        Container(
          height: 20,
        ),
        searchBar(),
        Expanded(
          child: _filteredStudentsList(),
        ),
      ],
    );
  }

  void getUsers() async {
    bool stillLoading = await _db
        .collection('users')
        .where("units",
            arrayContainsAny: widget.userData.data["units"].toList())
        .where("type", isEqualTo: "s")
        .where("is_active", isEqualTo: true)
        .getDocuments()
        .then((snap) {
      snap.documents.forEach((doc) {
        var user = User.fromFirestore(doc);
        user.classess = [];
        // if (doc.data["classes"] != null) {
        //   List tempClassess = doc.data["classes"].toList();
        //   tempClassess.forEach((c) {
        //     user.classess.add(Classess.fromArray(c));
        //   });
        // }
        _users.add(user);
      });
      _users.sort((a, b) => a.displayName.compareTo(b.displayName));
      return false;
    }).catchError((onError) {
      return true;
    }).whenComplete(() {
      return false;
    });

    _filteredUsers = _users;

    setState(() {
      _isLoading = stillLoading;
    });
  }

  Widget searchBar() {
    return Container(
      height: 60,
      width: double.infinity,
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding:
              const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[800], Colors.grey[800]]),
            ),
            // decoration: BoxDecoration(
            //   borderRadius: BorderRadius.circular(8),
            //   color: Colors.white,
            //   boxShadow: [
            //     BoxShadow(
            //       spreadRadius: 10,
            //       color: Colors.grey[200],
            //       blurRadius: 15,
            //     )
            //   ],
            // ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 12, right: 12),
                  child: Icon(
                    Icons.search,
                    color: Colors.grey[500],
                  ),
                ),
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    controller: _searchBarFieldController,
                    autocorrect: true,
                    autofocus: false,
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (v) {
                      //FocusScope.of(context).requestFocus(_searchFieldFocusNode);
                    },
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.white60),
                      hintText: "buscar...",
                      border: InputBorder.none,
                      suffixIcon: IconButton(
                        onPressed: () => _searchBarFieldController.clear(),
                        icon: Icon(
                          Icons.clear,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                    cursorColor: Colors.white60,
                    showCursor: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _filteredStudentsList() {
    return MediaQuery.removePadding(
      context: context,
      removeTop: true,
      child: ListView.builder(
        itemCount: _filteredUsers.length,
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            onTap: () {
              Navigator.pop(context, _filteredUsers[index]);
            },
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[800], Colors.grey[850]],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 0.0),
                child: Column(
                  children: <Widget>[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: 10,
                        ),
                        Container(
                          child: AvatarWidget(
                              userID: _filteredUsers[index].uid,
                              userName: _filteredUsers[index].displayName),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: AutoSizeText(
                              _filteredUsers[index].displayName,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 8.0, left: 8.0, right: 8.0),
                          child: _filteredUsers[index].unitName == ""
                              ? Container()
                              : RaisedButton(
                                  child: AutoSizeText(
                                    '${_filteredUsers[index].unitName}',
                                    style: TextStyle(
                                      color: Colors.white60,
                                      fontSize: 16,
                                      fontWeight: FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                  ),
                                  onPressed: () {},
                                  color: Colors.grey[800],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: new BorderRadius.circular(
                                        (MediaQuery.of(context).size.width *
                                                0.3) /
                                            4),
                                    side: BorderSide(
                                      color: Colors.grey[850],
                                    ),
                                  ),
                                ),
                        )
                      ],
                    ),
                    Container(
                      width: double.infinity,
                      height: 20,
                    ),
                    Container(
                      width: double.infinity,
                      height: 1,
                      color: Colors.grey[900],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _listStudents() {
    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance.collection("users").getDocuments(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.done) {
            //_panel = MyData(userData: _userData);
            _isLoading = false;
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: Column(
                      children: <Widget>[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            Container(
                              width: 10,
                            ),
                            Container(
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    blurRadius: 0.0,
                                    color: Colors.black.withOpacity(.1),
                                    offset: Offset(0, 0),
                                  ),
                                ],
                                //shape: BoxShape.rectangle,
                                //border: Border.all(),
                                color: Colors.white,
                              ),
                              child: AvatarWidget(
                                  userID:
                                      snapshot.data.documents[index].documentID,
                                  userName: snapshot.data.documents[index]
                                      ["display_name"]),
                            ),
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.only(top: 8.0, left: 8.0),
                                child: AutoSizeText(
                                  snapshot.data.documents[index]
                                      ["display_name"],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.normal,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: 8.0, left: 8.0, right: 8.0),
                              child: snapshot.data.documents[index]
                                          ["unit_name"] ==
                                      null
                                  ? Container()
                                  : RaisedButton(
                                      child: AutoSizeText(
                                        '${snapshot.data.documents[index]["unit_name"]}',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.normal,
                                        ),
                                        maxLines: 1,
                                      ),
                                      onPressed: () {},
                                      color: Colors.grey[200],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: new BorderRadius.circular(
                                            (MediaQuery.of(context).size.width *
                                                    0.3) /
                                                4),
                                        side: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                            )
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          height: 20,
                        ),
                        Container(
                          width: double.infinity,
                          height: 1,
                          color: Colors.grey[200],
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          }
        }
        return Container(
          color: Colors.white,
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
