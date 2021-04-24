// import 'dart:ffi';

// import 'package:academia_do_rock_app/src/main_tab/agenda_screen/agenda_item.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart'
//     show CalendarCarousel;
// import 'package:flutter_calendar_carousel/classes/event.dart';
// import 'package:flutter_calendar_carousel/classes/event_list.dart';
// import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

// class AgendaScreen extends StatefulWidget {
//   @override
//   _AgendaScreenState createState() => _AgendaScreenState();
// }

// List<DateTime> presentDates = [
//   // DateTime(2019, 11, 1),
//   // DateTime(2019, 11, 3),
//   // DateTime(2019, 11, 4),
//   // DateTime(2019, 11, 5),
//   // DateTime(2019, 11, 6),
//   // DateTime(2019, 11, 9),
//   // DateTime(2019, 11, 10),
//   // DateTime(2019, 11, 11),
//   // DateTime(2019, 11, 15),
//   // DateTime(2019, 11, 11),
//   // DateTime(2019, 11, 15),
// ];
// List<DateTime> absentDates = [
//   // DateTime(2019, 11, 2),
//   // DateTime(2019, 11, 7),
//   // DateTime(2019, 11, 8),
//   // DateTime(2019, 11, 12),
//   // DateTime(2019, 11, 13),
//   // DateTime(2019, 11, 14),
//   // DateTime(2019, 11, 16),
//   // DateTime(2019, 11, 17),
//   // DateTime(2019, 11, 18),
//   // DateTime(2019, 11, 17),
//   // DateTime(2019, 11, 18),
// ];

// class _AgendaScreenState extends State<AgendaScreen> {
//   ScrollController _scrollController;
//   FirebaseUser _user;
//   bool _isCalendarOpened = false;
//   num _calendarSize = 0;

//   Widget _widgetAgendaList;

//   final FirebaseAuth _auth = FirebaseAuth.instance;

//   DateTime _currentDate2 = DateTime.now();
//   static Widget _presentIcon(String day) => Container(
//         decoration: BoxDecoration(
//           color: Colors.green[200],
//           borderRadius: BorderRadius.all(
//             Radius.circular(1000),
//           ),
//         ),
//         child: Center(
//           child: Text(
//             day,
//             style: TextStyle(
//               color: Colors.black,
//             ),
//           ),
//         ),
//       );
//   static Widget _absentIcon(String day) => Container(
//         decoration: BoxDecoration(
//           color: Colors.red,
//           borderRadius: BorderRadius.all(
//             Radius.circular(1000),
//           ),
//         ),
//         child: Center(
//           child: Text(
//             day,
//             style: TextStyle(
//               color: Colors.black,
//             ),
//           ),
//         ),
//       );

//   EventList<Event> _markedDateMap = new EventList<Event>(
//     events: {},
//   );

//   CalendarCarousel _calendarCarouselNoHeader;

//   var len = 9;
//   double cHeight;

//   @override
//   void initState() {
//     _calendarSize = 0.0;
//     super.initState();
//     getUser();
//   }

//   @override
//   void dispose() {
//     super.dispose();
//   }

//   void getUser() async {
//     _user = await _auth.currentUser();
//   }

//   Widget build(BuildContext context) {
//     cHeight = MediaQuery.of(context).size.height;

//     // for (int i = 0; i < 2; i++) {
//     //   _markedDateMap.add(
//     //     presentDates[i],
//     //     new Event(
//     //       date: presentDates[i],
//     //       title: 'Event 5',
//     //       icon: _presentIcon(
//     //         presentDates[i].day.toString(),
//     //       ),
//     //     ),
//     //   );
//     // }

//     // for (int i = 0; i < len; i++) {
//     //   _markedDateMap.add(
//     //     absentDates[i],
//     //     new Event(
//     //       date: absentDates[i],
//     //       title: 'Event 5',
//     //       icon: _absentIcon(
//     //         absentDates[i].day.toString(),
//     //       ),
//     //     ),
//     //   );
//     // }

//     _calendarCarouselNoHeader = calendarCarousel();

//     return NestedScrollView(
//       controller: _scrollController,
//       headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
//         return <Widget>[
//           SliverAppBar(
//             centerTitle: false,
//             backgroundColor: Colors.white,
//             actions: <Widget>[
//               Padding(
//                 padding: const EdgeInsets.all(18.0),
//                 child: GestureDetector(
//                   onTap: () {
//                     setState(() {
//                       _isCalendarOpened = !_isCalendarOpened;
//                       _calendarSize = _isCalendarOpened ? 0.45 : 0;
//                       if (_isCalendarOpened) {
//                         //getCalendar();
//                         _calendarCarouselNoHeader = calendarCarousel();
//                         _widgetAgendaList = agendaCalendarList(DateTime.now());
//                       } else {
//                         _widgetAgendaList = agendaList();
//                       }
//                     });
//                   },
//                   child: Row(
//                     children: <Widget>[
//                       // Icon(
//                       //   MdiIcons.calendarMonth,
//                       // ),
//                       Icon(_isCalendarOpened
//                           ? MdiIcons.viewList
//                           : MdiIcons.calendarMonth),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//             title: Text("Agenda"),
//             pinned: true,
//             floating: true,
//             forceElevated: innerBoxIsScrolled,
//             // bottom: AppBar(
//             //     centerTitle: false,
//             //     elevation: 0,
//             //     backgroundColor: Colors.white,
//             //     title: Container(
//             //       width: double.infinity,
//             //       height: 35,
//             //       child: searchFlield(),
//             //     )),
//           )
//         ];
//       },
//       body: Scaffold(
//         body: Container(
//           width: double.infinity,
//           height: double.infinity,
//           child: futureUser(),
//         ),
//       ),
//       // body: _isLoading
//       //     ? Container(
//       //         color: Colors.white,
//       //         width: double.infinity,
//       //         height: double.infinity,
//       //         child: Center(
//       //             child: CircularProgressIndicator(
//       //           valueColor: AlwaysStoppedAnimation<Color>(
//       //               Theme.of(context).primaryColor),
//       //         )),
//       //       )
//       //     : newsFeed(),
//     );
//   }

//   CalendarCarousel calendarCarousel() {
//     return CalendarCarousel<Event>(
//       height: cHeight * (_calendarSize == null ? 0 : _calendarSize),
//       weekendTextStyle: TextStyle(
//         color: Colors.red,
//       ),
//       headerTextStyle: TextStyle(
//         color: Colors.black,
//         fontSize: 26,
//         fontWeight: FontWeight.bold,
//       ),
//       leftButtonIcon: Icon(
//         Icons.chevron_left,
//         size: 40,
//         color: Theme.of(context).primaryColor,
//       ),
//       rightButtonIcon: Icon(
//         Icons.chevron_right,
//         size: 40,
//         color: Theme.of(context).primaryColor,
//       ),
//       onDayPressed: (DateTime date, List<Event> events) {
//         agendaCalendarList(date);
//         setState(() {
//           _widgetAgendaList = agendaCalendarList(date);
//         });
//       },
//       todayButtonColor: Theme.of(context).primaryColor,
//       markedDatesMap: _markedDateMap,
//       markedDateShowIcon: true,
//       markedDateIconMaxShown: 1,
//       markedDateMoreShowTotal:
//           null, // null for not showing hidden events indicator
//       markedDateIconBuilder: (event) {
//         return event.icon;
//       },
//     );
//   }

//   Widget agenda() {
//     return Column(
//       children: <Widget>[
//         Container(
//           width: double.infinity,
//           //height: 50,
//           color: Colors.white,
//           child: _calendarCarouselNoHeader,
//           // child: calendarTop(),
//         ),
//         Container(
//           width: double.infinity,
//           height: 1,
//           color: Colors.grey,
//         ),
//         Expanded(
//           child: _widgetAgendaList == null ? agendaList() : _widgetAgendaList,
//         ),
//         //agendaList()
//       ],
//     );
//   }

//   Widget futureUser() {
//     return FutureBuilder(
//       future: _auth.currentUser(),
//       builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
//         if (snapshot.hasData) {
//           if (snapshot.connectionState == ConnectionState.done) {
//             _user = snapshot.data;
//             //_panel = MyData(userData: _userData);
//             getCalendar();
//             return agenda();
//           }
//         }
//         return Container(
//           color: Colors.white,
//           width: double.infinity,
//           height: double.infinity,
//           child: Center(
//               child: CircularProgressIndicator(
//             valueColor:
//                 AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
//           )),
//         );
//       },
//     );
//   }

//   Widget calendarTop() {
//     return Row(
//       children: <Widget>[
//         Container(
//           padding: const EdgeInsets.only(left: 8),
//           width: 30,
//           height: double.infinity,
//           child: Icon(
//             Icons.chevron_left,
//             size: 30,
//           ),
//         ),
//         Expanded(
//           child: Center(
//             child: Text(
//               "Outubro",
//               style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//             ),
//           ),
//         ),
//         Container(
//           padding: const EdgeInsets.only(right: 8),
//           width: 30,
//           height: double.infinity,
//           child: Icon(
//             Icons.chevron_right,
//             size: 30,
//           ),
//         ),
//       ],
//     );
//   }

//   void getCalendar() async {
//     await Firestore.instance
//         .collection("agenda")
//         .where("students_id", arrayContains: _user.uid)
//         .where("date", isGreaterThan: DateTime.now())
//         .getDocuments()
//         .then((agenda) {
//       //setState(() {
//       //_markedDateMap.clear();
//       agenda.documents.forEach((doc) {
//         print(doc.data["date"].toDate().day.toInt());
//         _markedDateMap.add(
//           DateTime(
//               doc.data["date"].toDate().year.toInt(),
//               doc.data["date"].toDate().month.toInt(),
//               doc.data["date"].toDate().day.toInt()),
//           new Event(
//             date: DateTime(
//                 doc.data["date"].toDate().year.toInt(),
//                 doc.data["date"].toDate().month.toInt(),
//                 doc.data["date"].toDate().day.toInt()),
//             title: doc.data["class"],
//             icon: _presentIcon(
//               doc.data["date"].toDate().day.toString(),
//             ),
//           ),
//         );
//       });
//     });
//     //});
//   }

//   Widget agendaCalendarList(DateTime date) {
//     print(date);
//     return FutureBuilder<QuerySnapshot>(
//       future: Firestore.instance
//           .collection("agenda")
//           .where("students_id", arrayContains: _user.uid)
//           .where("date", isGreaterThanOrEqualTo: date)
//           .where("date", isLessThan: date.add(Duration(days: 1)))
//           .getDocuments(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) return Text("Error: ${snapshot.error}");
//         switch (snapshot.connectionState) {
//           case ConnectionState.waiting:
//             return Container(
//               color: Colors.white,
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                   child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                     Theme.of(context).primaryColor),
//               )),
//             );
//           default:
//             if (snapshot.data.documents.length > 0) {
//               return MediaQuery.removePadding(
//                 context: context,
//                 removeTop: true,
//                 child: ListView.builder(
//                   itemCount: snapshot.data.documents.length,
//                   itemBuilder: (BuildContext context, int index) {
//                     return Column(
//                       children: <Widget>[
//                         AgendaItem(
//                           typeClass: snapshot.data.documents[index]["class"],
//                           date: snapshot.data.documents[index]["date"],
//                           duration: snapshot.data.documents[index]["duration"],
//                           teacherName: snapshot.data.documents[index]
//                               ["teacher_name"],
//                           teacherAvatar: snapshot.data.documents[index]
//                               ["teacher_avatar"],
//                           status: snapshot.data.documents[index]["status"],
//                         ),
//                         // Divider(
//                         //   color: Colors.grey,
//                         // ),
//                       ],
//                     );
//                   },
//                 ),
//               );
//             } else {
//               return Container(
//                 width: double.infinity,
//                 child: Padding(
//                   padding: const EdgeInsets.all(15.0),
//                   child: Text(
//                     "Nenhuma aula marcada para esta data",
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.grey[700],
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               );
//             }
//         }
//       },
//     );
//   }

//   Widget agendaList() {
//     return FutureBuilder<QuerySnapshot>(
//       future: Firestore.instance
//           .collection("agenda")
//           .where("students_id", arrayContains: _user.uid)
//           .getDocuments(),
//       builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
//         if (snapshot.hasError) return Text("Error: ${snapshot.error}");
//         switch (snapshot.connectionState) {
//           case ConnectionState.waiting:
//             return Container(
//               color: Colors.white,
//               width: double.infinity,
//               height: double.infinity,
//               child: Center(
//                   child: CircularProgressIndicator(
//                 valueColor: AlwaysStoppedAnimation<Color>(
//                     Theme.of(context).primaryColor),
//               )),
//             );
//           default:
//             return MediaQuery.removePadding(
//               context: context,
//               removeTop: true,
//               child: ListView.builder(
//                 itemCount: snapshot.data.documents.length,
//                 itemBuilder: (BuildContext context, int index) {
//                   return Column(
//                     children: <Widget>[
//                       AgendaItem(
//                         typeClass: snapshot.data.documents[index]["class"],
//                         date: snapshot.data.documents[index]["date"],
//                         duration: snapshot.data.documents[index]["duration"],
//                         teacherName: snapshot.data.documents[index]
//                             ["teacher_name"],
//                         teacherAvatar: snapshot.data.documents[index]
//                             ["teacher_avatar"],
//                         status: snapshot.data.documents[index]["status"],
//                       ),
//                       // Divider(
//                       //   color: Colors.grey,
//                       // ),
//                     ],
//                   );
//                 },
//               ),
//             );
//         }
//       },
//     );
//   }
// }

import 'package:academia_do_rock_app/src/main_tab/agenda_screen/agenda_detail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:calendar_strip/calendar_strip.dart';
import 'package:auto_size_text/auto_size_text.dart';

class AgendaScreen extends StatefulWidget {
  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  List<DocumentSnapshot> _eventsList = [];
  List<DocumentSnapshot> _allEventsForUser = [];
  List<DateTime> _markedDates = [];
  int _selectedIndex = 0;
  bool _isTeacher = false;
  bool _shouldDisplayCalendarStrip = true;
  DocumentSnapshot _userData;

  bool _isLoadingEvents = true;

  @override
  void initState() {
    _auth.currentUser().then((currentUser) {
      _user = currentUser;
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .get()
          .then((user) {
        _userData = user;
        _isTeacher = user.data["is_teacher"];
      }).catchError((e) {
        print("Algum problema no registro do usuário, ou faltando.");
      }).whenComplete(() {
        getAllEvents();
        getEventsForSelectedPeriod(DateTime.now(), DateTime.now());
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
                onPressed: () {
                  // Add your onPressed code here!
                },
                child: Icon(Icons.add),
                backgroundColor: Theme.of(context).primaryColor),
            body: Container(
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 18),
                    height: 60,
                    width: double.infinity,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Agendas",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 18),
                    width: double.infinity,
                    height: 100,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        calendarFilterButton(
                            screenWidth: constraints.maxWidth,
                            icon: Icons.today,
                            label: "Hoje",
                            index: 0,
                            selected: _selectedIndex == 0 ? true : false,
                            showCalendarStrip: true,
                            startDate: DateTime.now(),
                            endDate: DateTime.now()),
                        calendarFilterButton(
                          screenWidth: constraints.maxWidth,
                          icon: Icons.list,
                          label: "Próximos",
                          index: 1,
                          selected: _selectedIndex == 1 ? true : false,
                          showCalendarStrip: false,
                          startDate: DateTime.now(),
                          endDate: DateTime.now().add(Duration(days: 90)),
                        ),
                        calendarFilterButton(
                          screenWidth: constraints.maxWidth,
                          icon: Icons.calendar_today,
                          label: "Calendário",
                          index: 2,
                          selected: _selectedIndex == 2 ? true : false,
                          showCalendarStrip: false,
                          startDate: DateTime.now(),
                          endDate: DateTime.now().add(Duration(days: 90)),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(top: 18),
                    child: _shouldDisplayCalendarStrip
                        ? myCalendarStrip()
                        : Container(
                            child: Container(
                              child: Text("Próximos eventos agendados",
                                  style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                      fontStyle: FontStyle.italic)),
                              padding: EdgeInsets.only(top: 8, bottom: 4),
                            ),
                          ),
                  ),
                  _isLoadingEvents
                      ? Container(
                          padding: EdgeInsets.only(top: 40),
                          child: CircularProgressIndicator(),
                        )
                      : Container(
                          padding: EdgeInsets.only(top: 18),
                          child: showListOfEvents(),
                        )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget calendarFilterButton(
      {double screenWidth,
      IconData icon,
      String label,
      int index,
      bool selected,
      bool showCalendarStrip,
      DateTime startDate,
      DateTime endDate}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedIndex = index;
          _shouldDisplayCalendarStrip = showCalendarStrip;
        });
        getEventsForSelectedPeriod(startDate, endDate);
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 100),
        width: screenWidth / 4,
        height: screenWidth / 4,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: selected ? Theme.of(context).primaryColor : Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Icon(icon),
            Text(label),
          ],
        ),
      ),
    );
  }

  Widget myCalendarStrip() {
    DateTime startDate = DateTime.now().subtract(Duration(days: 7));
    DateTime endDate = DateTime.now().add(Duration(days: 30));
    DateTime selectedDate = DateTime.now();

    onSelect(data) {
      print("Selected Date -> $data");
      getEventsForSelectedPeriod(data, data);
    }

    _monthNameWidget(monthName) {
      return Container(
        child: Text(monthName,
            style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontStyle: FontStyle.italic)),
        padding: EdgeInsets.only(top: 8, bottom: 4),
      );
    }

    getMarkedIndicatorWidget() {
      return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(
          margin: EdgeInsets.only(left: 1, right: 1),
          width: 7,
          height: 7,
          decoration: BoxDecoration(
              shape: BoxShape.circle, color: Theme.of(context).primaryColor),
        ),
      ]);
    }

    dateTileBuilder(
        date, selectedDate, rowIndex, dayName, isDateMarked, isDateOutOfRange) {
      bool isSelectedDate = date.compareTo(selectedDate) == 0;
      Color fontColor = isDateOutOfRange ? Colors.black26 : Colors.black87;
      TextStyle normalStyle = TextStyle(
          fontSize: MediaQuery.of(context).size.width < 350 ? 10 : 17,
          fontWeight: FontWeight.w800,
          color: fontColor);
      TextStyle selectedStyle = TextStyle(
          fontSize: MediaQuery.of(context).size.width < 350 ? 10 : 17,
          fontWeight: FontWeight.w800,
          color: Colors.black87);
      TextStyle dayNameStyle = TextStyle(
          fontSize: MediaQuery.of(context).size.width < 350 ? 8 : 14.5,
          color: fontColor);
      List<Widget> _children = [
        Text(dayName, style: dayNameStyle),
        Text(date.day.toString(),
            style: !isSelectedDate ? normalStyle : selectedStyle),
      ];

      if (isDateMarked == true) {
        _children.add(getMarkedIndicatorWidget());
      }

      return AnimatedContainer(
        duration: Duration(milliseconds: 150),
        alignment: Alignment.center,
        padding: EdgeInsets.only(top: 8, left: 5, right: 5, bottom: 5),
        decoration: BoxDecoration(
          color: !isSelectedDate
              ? Colors.transparent
              : Theme.of(context).primaryColor,
          borderRadius: BorderRadius.all(Radius.circular(60)),
        ),
        child: Column(
          children: _children,
        ),
      );
    }

    return CalendarStrip(
      startDate: startDate,
      endDate: endDate,
      onDateSelected: onSelect,
      dateTileBuilder: dateTileBuilder,
      selectedDate: selectedDate,
      iconColor: Colors.black87,
      monthNameWidget: _monthNameWidget,
      markedDates: _markedDates,
      containerDecoration: BoxDecoration(color: Colors.white),
    );
  }

  Widget showListOfEvents() {
    return _eventsList.length == 0
        ? Text("nenhum evento")
        : ListView.builder(
            shrinkWrap: true,
            physics: ClampingScrollPhysics(),
            padding: EdgeInsets.only(left: 12, right: 12),
            itemCount: _eventsList.length,
            itemBuilder: (BuildContext context, int index) {
              return eventTile(_eventsList[index]);
            },
          );
  }

  Widget eventTile(DocumentSnapshot document) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AgendaDetail(
              classData: document,
              userData: _userData,
            ),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        height: 100,
        child: Row(
          children: <Widget>[
            Column(
              children: <Widget>[
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[400],
                    image: DecorationImage(
                      image: AssetImage(
                        eventTypeIcon(document['class']),
                      ),
                    ),
                  ),
                ),
                Text("Batel"),
              ],
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(left: 10),
                width: double.infinity,
                height: 80,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    AutoSizeText(
                      document["name"],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                    ),
                    Row(
                      children: <Widget>[
                        statusLabel(document["status"]),
                        eventTimeLabel(
                          document["date"].toDate(),
                          document["duration"],
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        Icon(
                          Icons.person,
                          color: Colors.grey,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text("Prof.: " + document["teacher_name"]),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 16),
                          child: Icon(
                            (document["students_id"].length == 1
                                ? Icons.person
                                : Icons.people),
                            color: Colors.grey,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Text(
                            document["students_id"].length.toString() +
                                (document["students_id"].length == 1
                                    ? " aluno"
                                    : " alunos"),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget eventTimeLabel(DateTime dateTime, int duration) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        "${dateTime.day}/${dateTime.month}/${dateTime.year} das ${dateTime.hour}:00-${dateTime.add(Duration(minutes: duration)).hour}:00",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width < 350 ? 9 : 14),
      ),
    );
  }

  Widget statusLabel(String label) {
    Color color = Colors.white;

    switch (label) {
      case "agendado":
        color = Colors.yellow[800];
        break;
      case "confirmado":
        color = Colors.green;
        break;
      case "cancelado":
        color = Colors.red;
        break;
      case "concluído":
        color = Colors.blue;
        break;
      default:
        color = Colors.transparent;
    }

    return Container(
      width: MediaQuery.of(context).size.width < 350 ? 60 : 80,
      height: 18,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(2), color: color),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.width < 350 ? 10 : 14),
        ),
      ),
    );
  }

  void getAllEvents() async {
    _isLoadingEvents = true;
    if (_isTeacher) {
      Firestore.instance
          .collection("agenda")
          .where("teacher_id", isEqualTo: _user.uid)
          .where(
            "date",
            isGreaterThanOrEqualTo: DateTime(DateTime.now().year - 1, 1, 1),
          )
          .where(
            "date",
            isLessThan: DateTime(DateTime.now().year + 1, 1, 1),
          )
          .getDocuments()
          .then((result) {
        setState(() {
          _allEventsForUser = result.documents;
          _allEventsForUser.forEach((event) {
            _markedDates.add(event.data["date"].toDate());
          });
          _isLoadingEvents = false;
        });
      });
    } else {
      Firestore.instance
          .collection("agenda")
          .where("students_id", arrayContains: _user.uid)
          .where(
            "date",
            isGreaterThanOrEqualTo: DateTime(DateTime.now().year - 1, 1, 1),
          )
          .where(
            "date",
            isLessThan: DateTime(DateTime.now().year + 1, 1, 1),
          )
          .getDocuments()
          .then((result) {
        setState(() {
          _allEventsForUser = result.documents;
          _allEventsForUser.forEach((event) {
            _markedDates.add(event.data["date"].toDate());
          });
          _isLoadingEvents = false;
        });
      });
    }
  }

  void getEventsForSelectedPeriod(DateTime startDate, DateTime endDate) async {
    _isLoadingEvents = true;

    if (startDate.day == endDate.day) {
      endDate = endDate.add(
        Duration(days: 1),
      );
    }

    if (_isTeacher) {
      Firestore.instance
          .collection("agenda")
          .where("teacher_id", isEqualTo: _user.uid)
          .where(
            "date",
            isGreaterThanOrEqualTo:
                DateTime(startDate.year, startDate.month, startDate.day),
          )
          .where(
            "date",
            isLessThan: DateTime(endDate.year, endDate.month, endDate.day),
          )
          .getDocuments()
          .then((result) {
        setState(() {
          _eventsList = result.documents;
          _isLoadingEvents = false;
        });
      });
    } else {
      Firestore.instance
          .collection("agenda")
          .where("students_id", arrayContains: _user.uid)
          .where(
            "date",
            isGreaterThanOrEqualTo:
                DateTime(startDate.year, startDate.month, startDate.day),
          )
          .where(
            "date",
            isLessThan: DateTime(endDate.year, endDate.month, endDate.day),
          )
          .getDocuments()
          .then((result) {
        setState(() {
          _eventsList = result.documents;
          _isLoadingEvents = false;
        });
      });
    }
  }

  String eventTypeIcon(String eventType) {
    switch (eventType) {
      case "drums":
        return "assets/icons/icon_drums_new.png";
        break;
      case "guitar":
        return "assets/icons/icon_guitar.png";
        break;
      case "bass":
        return "assets/icons/icon_bass.png";
        break;
      case "keyboard":
        return "assets/icons/icon_keyboard.png";
        break;
      case "band":
        return "assets/icons/icon_band.png";
        break;
      case "singing":
        return "assets/icons/icon_singing.png";
        break;
      default:
        return "assets/icons/icon_drums_new.png";
    }
  }
}
