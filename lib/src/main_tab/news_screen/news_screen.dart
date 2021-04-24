import 'dart:async';

import 'package:academia_do_rock_app/src/main_tab/news_screen/news_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NewsScreen extends StatefulWidget {
  @override
  _NewsScreenState createState() => _NewsScreenState();
}

class _NewsScreenState extends State<NewsScreen> {
  ScrollController _scrollController;
  final _searchFieldController = TextEditingController();
  bool _isLoading = false;
  String _searchString = "";
  FirebaseUser _user;

  DocumentSnapshot _userData;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getUser() async {
    _user = await _auth.currentUser();
    _userData =
        await Firestore.instance.collection("users").document(_user.uid).get();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            automaticallyImplyLeading: false,
            centerTitle: false,
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              "Novidades",
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.white60,
              ),
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
            //       child: searchFlield(),
            //     )),
          )
        ];
      },
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        backgroundColor: Theme.of(context).backgroundColor,
        onRefresh: () async {
          Completer<Null> completer = new Completer<Null>();
          await Future.delayed(Duration(seconds: 1)).then((onvalue) {
            completer.complete();
            setState(() {});
          });
          return completer.future;
        },
        child: newsFeed(),
      ),
      // body: _isLoading
      //     ? Container(
      //         color: Colors.white,
      //         width: double.infinity,
      //         height: double.infinity,
      //         child: Center(
      //             child: CircularProgressIndicator(
      //           valueColor: AlwaysStoppedAnimation<Color>(
      //               Theme.of(context).primaryColor),
      //         )),
      //       )
      //     : newsFeed(),
    );
  }

  Widget newsFeed() {
    return FutureBuilder<QuerySnapshot>(
      future: Firestore.instance
          .collection("news")
          .orderBy("date", descending: true)
          .getDocuments(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) return Text("Error: ${snapshot.error}");
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
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
                ),
              ),
            );
          default:
            return MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: NewsItem(
                      documentID: snapshot.data.documents[index].documentID,
                      title: snapshot.data.documents[index]["title"],
                      text: snapshot.data.documents[index]["text"],
                      imageUrl: snapshot.data.documents[index]["image_url"],
                      videoUrl:
                          snapshot.data.documents[index]["video_url"] ?? "",
                      likes: snapshot.data.documents[index]["likes"].toInt(),
                      date: snapshot.data.documents[index]["date"],
                      comments:
                          snapshot.data.documents[index]["comments"].toInt(),
                      user: _user,
                      userData: _userData,
                    ),
                  );
                },
              ),
            );
        }
      },
    );
  }

  Widget searchFlield() {
    return TextField(
      controller: _searchFieldController,
      autocorrect: false,
      autofocus: true,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      //textInputAction: TextInputAction.next,
      onChanged: (v) {
        setState(() {
          _searchString = v;
        });
      },
      onSubmitted: (v) {
        //FocusScope.of(context).requestFocus(_lastNameFocus);
      },
      decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(top: 15.0, left: 15.0),
          border: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(20)),
            borderSide: BorderSide(color: Colors.grey),
          ),
          hintText: "Buscar...",
          filled: true,
          fillColor: Colors.grey[100],
          suffixIcon: Icon(Icons.search)),
      cursorColor: Colors.black,
      showCursor: true,
    );
  }
}
