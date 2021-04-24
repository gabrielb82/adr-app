import 'package:academia_do_rock_app/src/login/login_screen.dart';
import 'package:academia_do_rock_app/src/main_tab/main_tab_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AcademiaDoRockApp extends StatefulWidget {
  const AcademiaDoRockApp({Key key}) : super(key: key);

  @override
  _AcademiaDoRockAppState createState() => _AcademiaDoRockAppState();
}

class _AcademiaDoRockAppState extends State<AcademiaDoRockApp> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      title: "Academia do Rock",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        //primaryColor: Colors.amber[700],
        accentColor: Color(0xFF757575),
        primaryColor: Color(0xFFE46453),
        // accentColor: Color(0xFF757575),
        backgroundColor: Color(0xFF1A1C20),
        // backgroundColor: Color(0xFF222D32),
      ),
      home: FutureBuilder(
        future: _auth.currentUser(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.hasData) {
            FirebaseUser user = snapshot.data;
            if (user.isAnonymous) {
              return LoginScreen();
            } else {
              return MainTabScreen();
            }
          } else {
            return LoginScreen();
          }
        },
      ),
    );
  }
}
