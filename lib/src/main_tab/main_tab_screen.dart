import 'dart:convert';
import 'dart:io';

import 'package:academia_do_rock_app/src/main_tab/agenda_screen/agenda_detail.dart';
import 'package:academia_do_rock_app/src/main_tab/agenda_screen/agenda_screen.dart';
import 'package:academia_do_rock_app/src/main_tab/calendar_screen/calendar_screen.dart';
import 'package:academia_do_rock_app/src/main_tab/home_screen/home_screen.dart';
import 'package:academia_do_rock_app/src/main_tab/metronome_screen/metronome_screen.dart';
import 'package:academia_do_rock_app/src/main_tab/news_screen/news_screen.dart';
import 'package:academia_do_rock_app/src/main_tab/notifications/notification_screen.dart';
import 'package:academia_do_rock_app/src/main_tab/profile_screen/profile_screen.dart';
import 'package:academia_do_rock_app/src/models/agenda.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MainTabScreen extends StatefulWidget {
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  double _loadingScreenOpacity = 1;
  bool _shouldShowLoadingScreen = true;
  int _currentTabIndex = 0;

  FirebaseUser _user;

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    iOSPermission();
    firebaseCloudMessagingListeners();
    super.initState();

    Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _loadingScreenOpacity = 0;
      });
    });
    Timer(const Duration(milliseconds: 1000), () {
      setState(() {
        _shouldShowLoadingScreen = false;
      });
    });
  }

  Future<void> firebaseCloudMessagingListeners() async {
    if (Platform.isIOS) iOSPermission();

    _user = await _auth.currentUser();

    _firebaseMessaging.getToken().then((token) {
      print(token);
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .setData({"device_token": token}, merge: true);
    });

    //syncAgenda();

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
  }

  void iOSPermission() {
    if (Platform.isIOS) {
      _firebaseMessaging.requestNotificationPermissions(
          IosNotificationSettings(sound: true, badge: true, alert: true));
      _firebaseMessaging.onIosSettingsRegistered
          .listen((IosNotificationSettings settings) {
        print("Settings registered: $settings");
      });
    }
  }

  void syncAgenda() async {
    await Firestore.instance
        .collection("users")
        .document(_user.uid)
        .get()
        .then((u) {
      if (u.data["type"] == "s") {
        u.data["units"].forEach((unit) async {
          String userAPIKey = u.data["unity_key_${getUnitID(unit)}"][0];
          final response = await http.get(
              'https://extranet.academiadorock.com.br/app/lista_agenda_aluno.php?uni=${getUnitID(unit)}&chave=$userAPIKey');
          if (response.statusCode == 200) {
            // If the server did return a 200 OK response,
            // then parse the JSON.
            dynamic result = json.decode(response.body);
            List<dynamic> listAgenda = result["aulas"];
            if (listAgenda[0] == "") {
              // Primeiro item do array vem sempre em branco
              listAgenda.removeAt(0);
            }
            listAgenda.forEach((aula) async {
              Agenda agendaObject = Agenda.fromJson(aula);
              DateTime dateTime = DateTime.parse(
                  "${agendaObject.dtAula} ${agendaObject.horaIni}");

              if (dateTime
                  .isBefore(new DateTime.now().subtract(Duration(days: 30)))) {
                //print("antes");
              } else {
                await Firestore.instance
                    .collection("agenda")
                    .where("class_id", isEqualTo: agendaObject.classID)
                    .getDocuments()
                    .then((firebaseAgenda) async {
                  await Firestore.instance
                      .collection("agenda")
                      .document(firebaseAgenda.documents[0].documentID)
                      .setData(
                    {
                      "class_id": agendaObject.classID,
                      "class": agendaObject.className,
                      //"duration": minutes,
                      "room": agendaObject.room,
                      "status": agendaObject.status,
                      "student_finish": false,
                      "teacher_finish": false,
                      "students_id": FieldValue.arrayUnion([_user.uid]),
                      //"teacher_id": teacherID,
                      "teacher_name": agendaObject.teacherName,
                      "name": agendaObject.className,
                      "unit_name": unit,
                      "date": DateTime.parse(
                          "${agendaObject.dtAula} ${agendaObject.horaIni}"),
                    },
                    merge: true,
                  ).then((a) {});
                }).catchError((error) async {
                  QuerySnapshot teacher = await Firestore.instance
                      .collection("users")
                      .where("unity_key_${getUnitID(unit)}",
                          arrayContains: agendaObject.teacherID)
                      .getDocuments();
                  String teacherID = teacher.documents.length > 0
                      ? teacher.documents[0].documentID
                      : "";
                  await Firestore.instance.collection("agenda").add({
                    "class_id": agendaObject.classID,
                    "class": agendaObject.className,
                    "duration": 60,
                    "room": agendaObject.room,
                    "status": agendaObject.status,
                    "student_finish": false,
                    "teacher_finish": false,
                    "students_id": FieldValue.arrayUnion([_user.uid]),
                    "teacher_id": teacherID,
                    "teacher_name": agendaObject.teacherName,
                    "name": agendaObject.className,
                    "unit_name": unit,
                    "date": DateTime.parse(
                        "${agendaObject.dtAula} ${agendaObject.horaIni}")
                  });
                });
              }
            });
            print("fim");
          } else {
            // If the server did not return a 200 OK response,
            // then throw an exception.
            throw Exception('Failed to load data');
          }
        });
      } else if (u.data["type"] == "t") {
        syncTeacherAgenda(u);
      } else {
        print("another user");
      }
    });
  }

  void syncTeacherAgenda(DocumentSnapshot u) async {
    u.data["units"].forEach((unit) async {
      String userAPIKey = u.data["unity_key_${getUnitID(unit)}"][0];
      final response = await http.get(
          'https://extranet.academiadorock.com.br/app/lista_agenda_profe.php?uni=${getUnitID(unit)}&chave=$userAPIKey');
      if (response.statusCode == 200) {
        // If the server did return a 200 OK response,
        // then parse the JSON.
        dynamic result = json.decode(response.body);
        List<dynamic> listAgenda = result["aulas"];
        if (listAgenda[0] == "") {
          // Primeiro item do array vem sempre em branco
          listAgenda.removeAt(0);
        }
        listAgenda.forEach((aula) async {
          Agenda agendaObject = Agenda.fromJson(aula);
          DateTime dateTime =
              DateTime.parse("${agendaObject.dtAula} ${agendaObject.horaIni}");

          if (dateTime
              .isBefore(new DateTime.now().subtract(Duration(days: 30)))) {
            //print("antes");
          } else {
            QuerySnapshot student = await Firestore.instance
                .collection("users")
                .where("unity_key_${getUnitID(unit)}",
                    arrayContains: aula["chave_aluno"])
                .getDocuments();
            String studentID = student.documents.length > 0
                ? student.documents[0].documentID
                : "";

            //Salvando aula que aluno faz
            dynamic addClass = {
              "api_id": instrumentID(agendaObject.className) ?? 0,
              "code": instrumentCode(agendaObject.className) ?? "MUSIC",
              "name": agendaObject.className ?? "Música"
            };

            await Firestore.instance
                .collection("users")
                .document(studentID)
                .setData({
              "classes": FieldValue.arrayUnion([addClass])
            }, merge: true);
            //Fim salvando aula que aluno faz

            await Firestore.instance
                .collection("agenda")
                .where("class_id", isEqualTo: agendaObject.classID)
                .getDocuments()
                .then((firebaseAgenda) async {
              await Firestore.instance
                  .collection("agenda")
                  .document(firebaseAgenda.documents[0].documentID)
                  .setData(
                {
                  "class_id": agendaObject.classID,
                  "class": agendaObject.className,
                  //"duration": minutes,
                  "room": agendaObject.room,
                  "status": agendaObject.status,
                  "student_finish": false,
                  "teacher_finish": false,
                  "students_id": FieldValue.arrayUnion([studentID]),
                  "teacher_id": _user.uid,
                  "teacher_name": agendaObject.teacherName,
                  "name": agendaObject.className,
                  "unit_name": unit,
                  "date": DateTime.parse(
                      "${agendaObject.dtAula} ${agendaObject.horaIni}"),
                },
                merge: true,
              ).then((newAgenda) async {
                await Firestore.instance
                    .collection("agenda")
                    .document(firebaseAgenda.documents[0].documentID)
                    .collection("students")
                    .document(studentID)
                    .setData({
                  "instrument": agendaObject.className,
                  "name": student.documents[0].data["display_name"].toString()
                }, merge: true);
              });
            }).catchError((error) async {
              QuerySnapshot student = await Firestore.instance
                  .collection("users")
                  .where("unity_key_${getUnitID(unit)}",
                      arrayContains: aula["chave_aluno"])
                  .getDocuments();
              String studentID = student.documents.length > 0
                  ? student.documents[0].documentID
                  : "";
              await Firestore.instance.collection("agenda").add({
                "class_id": agendaObject.classID,
                "class": agendaObject.className,
                "duration": 60,
                "room": agendaObject.room,
                "status": agendaObject.status,
                "student_finish": false,
                "teacher_finish": false,
                "students_id": FieldValue.arrayUnion([studentID]),
                "teacher_id": _user.uid,
                "teacher_name": agendaObject.teacherName,
                "name": agendaObject.className,
                "unit_name": unit,
                "date": DateTime.parse(
                    "${agendaObject.dtAula} ${agendaObject.horaIni}")
              }).then((newAgenda) async {
                await Firestore.instance
                    .collection("agenda")
                    .document(newAgenda.documentID)
                    .collection("students")
                    .document(studentID)
                    .setData({
                  "instrument": agendaObject.className,
                  "name": student.documents[0].data["display_name"].toString()
                }, merge: true);
              });
            });
          }
        });
        print("fim");
      } else {
        // If the server did not return a 200 OK response,
        // then throw an exception.
        throw Exception('Failed to load data');
      }
    });
  }

  int getUnitID(String unitName) {
    switch (unitName) {
      case "Juvevê":
        return 1;
        break;
      case "Batel":
        return 2;
        break;
      case "Santo André":
        return 3;
        break;
      case "Campinas":
        return 4;
        break;
      case "Moema":
        return 5;
        break;
      case "São Caetano do Sul":
        return 6;
        break;
      default:
        return 1;
    }
  }

  int instrumentID(instrumentName) {
    switch (instrumentName) {
      case "Bateria":
        return 17;
        break;
      case "Guitarra":
        return 12;
        break;
      case "Baixo":
        return 13;
        break;
      case "Piano e Teclado":
        return 16;
        break;
      case "Piano - Externo":
        return 30;
        break;
      case "Pratica em Conjunto":
        return 20;
        break;
      case "Canto - Externo":
        return 31;
        break;
      case "Canto - Tecnica Vocal":
        return 15;
        break;
      case "Canto em Dupla":
        return 32;
        break;
      case "Harmonica":
        return 21;
        break;
      case "Violao":
        return 14;
        break;
      case "Violao - Externo":
        return 29;
        break;
      default:
        return 0;
    }
  }

  String instrumentCode(instrumentName) {
    switch (instrumentName) {
      case "Bateria":
        return "DRUM";
        break;
      case "Guitarra":
        return "GUIT";
        break;
      case "Baixo":
        return "BASS";
        break;
      case "Piano e Teclado":
        return "PET";
        break;
      case "Piano - Externo":
        return "PSC";
        break;
      case "Pratica em Conjunto":
        return "PCJ";
        break;
      case "Canto - Externo":
        return "VOCAL";
        break;
      case "Canto - Tecnica Vocal":
        return "VOCAL";
        break;
      case "Canto em Dupla":
        return "CTUR";
        break;
      case "Harmonica":
        return "HAR";
        break;
      case "Violao":
        return "VIOL";
        break;
      case "Violao - Externo":
        return "V-ISC";
        break;
      default:
        return "MUSIC";
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void onTabTapped(int index) {
    setState(() {
      _currentTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
          backgroundColor: Colors.white,
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).backgroundColor,
                    Color(0xFF151619)
                  ]),
            ),
            child: getCurrentTabScreen(),
          ),
          bottomNavigationBar: bottomTabBar(),
        ),
        loadingScreen(),
      ],
    );
  }

  Widget getCurrentTabScreen() {
    switch (_currentTabIndex) {
      case 0:
        return NewsScreen();
      case 1:
        //return AgendaScreen();
        return CalendarScreen();
      case 2:
        return MetronomeControl();
      case 3:
        return NotificationScreen();
      case 4:
        return ProfileScreen();
      default:
        return HomeScreen();
    }
  }

  Widget loadingScreen() {
    return _shouldShowLoadingScreen
        ? AnimatedOpacity(
            duration: Duration(milliseconds: 500),
            opacity: _loadingScreenOpacity,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
            ),
          )
        : Container();
  }

  Widget bottomTabBar() {
    return BottomNavigationBar(
      onTap: onTabTapped,
      elevation: 1,
      currentIndex: _currentTabIndex,
      backgroundColor: Colors.black,
      items: [
        bottomNavigationBar(
            MdiIcons.newspaperVariantMultipleOutline, 'Novidades'),
        bottomNavigationBar(MdiIcons.calendar, 'Aulas'),
        bottomNavigationBar(MdiIcons.metronome, 'Metrônomo'),
        bottomNavigationBar(Icons.notifications, 'Notificações'),
        bottomNavigationBar(Icons.person, 'Perfil'),
      ],
    );
  }

  BottomNavigationBarItem bottomNavigationBar(IconData icon, String label) {
    return BottomNavigationBarItem(
      backgroundColor: Theme.of(context).backgroundColor,
      icon: Icon(icon, color: Colors.white60),
      // icon: Icon(icon, color: Theme.of(context).unselectedWidgetColor),
      activeIcon: Icon(icon, color: Theme.of(context).primaryColor),
      title: Text(
        label,
        //style: TextStyle(color: Theme.of(context).unselectedWidgetColor),
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}
