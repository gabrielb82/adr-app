import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:academia_do_rock_app/src/main_tab/agenda_screen/agenda_detail.dart';
import 'package:academia_do_rock_app/src/main_tab/calendar_screen/add_class_screen.dart';
import 'package:academia_do_rock_app/src/models/agenda.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;

final Map<DateTime, List> _holidays = {
  DateTime(2019, 1, 1): ['New Year\'s Day'],
  DateTime(2019, 1, 6): ['Epiphany'],
  DateTime(2019, 2, 14): ['Valentine\'s Day'],
  DateTime(2019, 4, 21): ['Easter Sunday'],
  DateTime(2019, 4, 22): ['Easter Monday'],
};

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;
  List<DocumentSnapshot> _eventsList = [];
  List<DocumentSnapshot> _allEventsForUser = [];
  List<DateTime> _markedDates = [];
  int _selectedIndex = 0;
  bool _isTeacher = false;
  bool _shouldDisplayCalendarStrip = true;
  DocumentSnapshot _userData;

  AnimationController _animationController;
  CalendarController _calendarController;
  Map<DateTime, List> _events;
  List _selectedEvents;

  bool _isLoadingEvents = true;
  bool _isLoadingSelectedEvents = true;

  bool _isLoading = true;
  bool _isSynchingAgenda = true;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

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
        initializeDateFormatting().then((_) async {
          syncAgenda();
          // BackgroundFetch.scheduleTask(TaskConfig(
          //     taskId: "br.com.academiadorock.agenda",
          //     delay: 10 // <-- milliseconds
          //     ));
          await getAllEvents();
          getEventsForSelectedPeriod(DateTime.now(), DateTime.now());
          _isLoading = false;
        });
      });
    });

    final _selectedDay = DateTime.now();

    _events = {};

    // _events = {
    //   _selectedDay.subtract(Duration(days: 30)): [
    //     'Event A0',
    //     'Event B0',
    //     'Event C0'
    //   ],
    //   _selectedDay.subtract(Duration(days: 27)): ['Event A1'],
    //   _selectedDay.subtract(Duration(days: 20)): [
    //     'Event A2',
    //     'Event B2',
    //     'Event C2',
    //     'Event D2'
    //   ],
    //   _selectedDay.subtract(Duration(days: 16)): ['Event A3', 'Event B3'],
    //   _selectedDay.subtract(Duration(days: 10)): [
    //     'Event A4',
    //     'Event B4',
    //     'Event C4'
    //   ],
    //   _selectedDay.subtract(Duration(days: 4)): [
    //     'Event A5',
    //     'Event B5',
    //     'Event C5'
    //   ],
    //   _selectedDay.subtract(Duration(days: 2)): ['Event A6', 'Event B6'],
    //   _selectedDay: ['Event A7', 'Event B7', 'Event C7', 'Event D7'],
    //   _selectedDay.add(Duration(days: 1)): [
    //     'Event A8',
    //     'Event B8',
    //     'Event C8',
    //     'Event D8'
    //   ],
    //   _selectedDay.add(Duration(days: 3)):
    //       Set.from(['Event A9', 'Event A9', 'Event B9']).toList(),
    //   _selectedDay.add(Duration(days: 7)): [
    //     'Event A10',
    //     'Event B10',
    //     'Event C10'
    //   ],
    //   _selectedDay.add(Duration(days: 11)): ['Event A11', 'Event B11'],
    //   _selectedDay.add(Duration(days: 17)): [
    //     'Event A12',
    //     'Event B12',
    //     'Event C12',
    //     'Event D12'
    //   ],
    //   _selectedDay.add(Duration(days: 22)): ['Event A13', 'Event B13'],
    //   _selectedDay.add(Duration(days: 26)): [
    //     'Event A14',
    //     'Event B14',
    //     'Event C14'
    //   ],
    // };

    //_selectedEvents = _events[_selectedDay] ?? [];

    _calendarController = CalendarController();

    super.initState();

    // _animationController = AnimationController(
    //   duration: const Duration(milliseconds: 400),
    //   vsync: this,
    // );

    //_animationController.forward();
  }

  void _onDaySelected(DateTime day, List events) {
    print('CALLBACK: _onDaySelected');
    getEventsForSelectedPeriod(day, day);
    setState(() {
      _selectedEvents = events;
    });
  }

  void _onVisibleDaysChanged(
      DateTime first, DateTime last, CalendarFormat format) {
    print('CALLBACK: _onVisibleDaysChanged');
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          child: Scaffold(
            floatingActionButton: _isLoading
                ? null
                : (_userData.data["type"] == "t"
                    ? FloatingActionButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => AddClassScreen(
                                      userData: _userData,
                                    )),
                          );
                        },
                        child: Icon(Icons.create),
                        backgroundColor: Theme.of(context).primaryColor)
                    : null),
            body: Container(
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
                        "Agenda",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white60,
                        ),
                      ),
                    ),
                  ),
                  //Colocar containers aqui
                  !_isLoadingEvents
                      ? Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                //colors: [Colors.grey[800], Colors.grey[850]]),
                                colors: [
                                  Theme.of(context).backgroundColor,
                                  Color(0xFF191919)
                                ]),
                          ),
                          child: _buildTableCalendar(),
                        )
                      : Container(),
                  // _buildTableCalendarWithBuilders(),
                  const SizedBox(height: 8.0),
                  //_buildButtons(),
                  Container(
                    width: double.infinity,
                    height: 0,
                    color: Colors.grey[800],
                  ),
                  //const SizedBox(height: 8.0),
                  !_isLoadingSelectedEvents
                      ? Expanded(child: _buildEventList())
                      : Expanded(
                          child: Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                  _isSynchingAgenda
                      ? Container(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Theme.of(context).primaryColor),
                                ),
                              ),
                              Text(
                                "Sincronizando agenda...",
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : Container(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTableCalendar() {
    return TableCalendar(
      calendarController: _calendarController,
      locale: 'pt_BR',
      events: _events,
      holidays: _holidays,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Completo',
        CalendarFormat.week: 'Semana',
      },
      calendarStyle: CalendarStyle(
        weekdayStyle: TextStyle(color: Colors.white60),
        selectedColor: Theme.of(context).primaryColor,
        todayColor: Colors.deepOrange[200],
        markersColor: Colors.red[900],
        outsideDaysVisible: false,
      ),
      headerStyle: HeaderStyle(
        titleTextStyle: TextStyle(color: Colors.white),
        leftChevronIcon: Icon(
          Icons.chevron_left,
          color: Colors.white,
        ),
        rightChevronIcon: Icon(
          Icons.chevron_right,
          color: Colors.white,
        ),
        formatButtonVisible: true,
        centerHeaderTitle: false,
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      onDaySelected: (date, events) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  // More advanced TableCalendar configuration (using Builders & Styles)
  Widget _buildTableCalendarWithBuilders() {
    return TableCalendar(
      locale: 'pt_BR',
      calendarController: _calendarController,
      events: _events,
      holidays: _holidays,
      initialCalendarFormat: CalendarFormat.month,
      formatAnimation: FormatAnimation.slide,
      startingDayOfWeek: StartingDayOfWeek.sunday,
      availableGestures: AvailableGestures.all,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Mês',
        CalendarFormat.week: '',
      },
      calendarStyle: CalendarStyle(
        outsideDaysVisible: false,
        weekendStyle: TextStyle().copyWith(color: Colors.blue[800]),
        holidayStyle: TextStyle().copyWith(color: Colors.blue[800]),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekendStyle: TextStyle().copyWith(color: Colors.blue[600]),
      ),
      headerStyle: HeaderStyle(
        formatButtonVisible: false,
        centerHeaderTitle: true,
        formatButtonTextStyle:
            TextStyle().copyWith(color: Colors.white, fontSize: 15.0),
        formatButtonDecoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
      ),
      builders: CalendarBuilders(
        selectedDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Theme.of(context).primaryColor,
            width: 100,
            height: 100,
            child: Text(
              '${date != null ? date.day : "0"}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        todayDayBuilder: (context, date, _) {
          return Container(
            margin: const EdgeInsets.all(4.0),
            padding: const EdgeInsets.only(top: 5.0, left: 6.0),
            color: Colors.red,
            width: 100,
            height: 100,
            child: Text(
              '${date.day}',
              style: TextStyle().copyWith(fontSize: 16.0),
            ),
          );
        },
        markersBuilder: (context, date, events, holidays) {
          final children = <Widget>[];

          if (events.isNotEmpty) {
            children.add(
              Positioned(
                right: 1,
                bottom: 1,
                child: _buildEventsMarker(date, events),
              ),
            );
          }

          // if (holidays.isNotEmpty) {
          //   children.add(
          //     Positioned(
          //       right: -2,
          //       top: -2,
          //       child: _buildHolidaysMarker(),
          //     ),
          //   );
          // }

          return children;
        },
      ),
      onDaySelected: (date, events) {
        _onDaySelected(date, events);
        _animationController.forward(from: 0.0);
      },
      onVisibleDaysChanged: _onVisibleDaysChanged,
    );
  }

  Widget _buildEventsMarker(DateTime date, List events) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _calendarController.isSelected(date)
            ? Colors.brown[500]
            : _calendarController.isToday(date)
                ? Colors.brown[300]
                : Theme.of(context).primaryColor,
      ),
      width: 16.0,
      height: 16.0,
      child: Center(
        child: Text(
          '${events.length}',
          style: TextStyle().copyWith(
            color: Colors.white,
            fontSize: 12.0,
          ),
        ),
      ),
    );
  }

  Widget _buildHolidaysMarker() {
    return Icon(
      Icons.add_box,
      size: 20.0,
      color: Colors.blueGrey[800],
    );
  }

  Widget _buildButtons() {
    final dateTime = _events.keys.elementAt(_events.length - 2);

    return Column(
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            RaisedButton(
              child: Text('Month'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.month);
                });
              },
            ),
            RaisedButton(
              child: Text('2 weeks'),
              onPressed: () {
                setState(() {
                  _calendarController
                      .setCalendarFormat(CalendarFormat.twoWeeks);
                });
              },
            ),
            RaisedButton(
              child: Text('Week'),
              onPressed: () {
                setState(() {
                  _calendarController.setCalendarFormat(CalendarFormat.week);
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8.0),
        RaisedButton(
          child: Text(
              'Set day ${dateTime.day}-${dateTime.month}-${dateTime.year}'),
          onPressed: () {
            _calendarController.setSelectedDay(
              DateTime(dateTime.year, dateTime.month, dateTime.day),
              runCallback: true,
            );
          },
        ),
      ],
    );
  }

  Widget _buildEventList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      padding: EdgeInsets.only(left: 0, right: 0),
      itemCount: _eventsList.length,
      itemBuilder: (BuildContext context, int index) {
        return eventTile(_eventsList[index]);
      },
    );
  }

  Future<void> getAllEvents() async {
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
            isLessThan: DateTime(DateTime.now().year + 2, 1, 1),
          )
          .getDocuments()
          .then((result) {
        setState(() {
          _allEventsForUser = result.documents;
          _allEventsForUser.forEach((event) {
            _markedDates.add(event.data["date"].toDate());
            Map<DateTime, List<dynamic>> newEntry = {
              event.data["date"].toDate(): ["teste"]
            };
            _events.addAll(newEntry);
          });
          _isLoadingEvents = false;
        });
      });
    } else {
      Firestore.instance
          .collection("agenda")
          // .where(
          //   "date",
          //   isGreaterThanOrEqualTo: DateTime(DateTime.now().year - 1, 1, 1),
          // )
          // .where(
          //   "date",
          //   isLessThan: DateTime(DateTime.now().year + 1, 1, 1),
          // )
          .where("students_id", arrayContains: _user.uid)
          .getDocuments()
          .then((result) {
        setState(() {
          _allEventsForUser = result.documents;
          _allEventsForUser.forEach((event) {
            _markedDates.add(event.data["date"].toDate());
            DateTime date = event.data["date"].toDate();
            DateTime dateKey = DateTime(date.year, date.month, date.day);
            Map<DateTime, List<dynamic>> newEntry = {
              dateKey: [event.data["status"]]
            };

            _events.containsKey(dateKey)
                ? _events[dateKey].add(event.data["status"])
                : _events.addAll(newEntry);
          });

          _isLoadingEvents = false;
        });
      });
    }
  }

  void getEventsForSelectedPeriod(DateTime startDate, DateTime endDate) async {
    _isLoadingSelectedEvents = true;

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
          _isLoadingSelectedEvents = false;
        });
      });
    } else {
      Firestore.instance
          .collection("agenda")
          //.where("students_id", arrayContains: _user.uid)
          .where(
            "date",
            isGreaterThanOrEqualTo:
                DateTime(startDate.year, startDate.month, startDate.day),
          )
          .where(
            "date",
            isLessThan: DateTime(endDate.year, endDate.month, endDate.day),
          )
          .where("students_id", arrayContains: _user.uid)
          .getDocuments()
          .then((result) {
        setState(() {
          _eventsList = result.documents;
          _isLoadingSelectedEvents = false;
        });
      });
    }
  }

  String eventTypeIcon(String eventType) {
    switch (eventType) {
      case "Bateria":
        return "assets/icons/drum-set.png";
        break;
      case "Guitarra":
        return "assets/icons/icon_guitar.png";
        break;
      case "Baixo":
        return "assets/icons/icon_bass.png";
        break;
      case "Piano e Teclado":
        return "assets/icons/icon_keyboard.png";
        break;
      case "Piano - Externo":
        return "assets/icons/icon_piano.png";
        break;
      case "Pratica em Conjunto":
        return "assets/icons/icon_band_new.png";
        break;
      case "Canto - Tecnica Vocal":
        return "assets/icons/icon_singing.png";
        break;
      case "Canto - Externo":
        return "assets/icons/icon_singing.png";
        break;
      case "Canto em Dupla":
        return "assets/icons/icon_singing_duo.png";
        break;
      case "Violao":
        return "assets/icons/icon_acoustic_guitar.png";
        break;
      case "Violao - Externo":
        return "assets/icons/icon_acoustic_guitar.png";
        break;
      case "Ukulele":
        return "assets/icons/icon_acoustic_guitar.png";
        break;
      case "Harmonica":
        return "assets/icons/icon_harmonica.png";
        break;
      default:
        return "assets/icons/drum-set.png";
    }
  }

  Widget schoolLabel(String school) {
    return Container(
      width: MediaQuery.of(context).size.width < 350 ? 60 : 80,
      height: 18,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Theme.of(context).primaryColor),
      child: Center(
        child: Text(
          school,
          style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: MediaQuery.of(context).size.width < 350
                  ? 6
                  : (school.length > 12 ? 6 : 10)),
        ),
      ),
    );
  }

  Widget statusLabel(String label) {
    Color color = Colors.white;

    switch (label) {
      case "Prevista":
        color = Colors.yellow[800];
        break;
      case "ausente":
        color = Theme.of(context).primaryColor;
        break;
      case "Confirmada pelo aluno":
        color = Colors.blue;
        break;
      case "cancelado":
        color = Theme.of(context).primaryColor;
        break;
      case "Realizada":
        color = Colors.green[700];
        break;
      case "Realizada sem matricula":
        color = Colors.green[700];
        break;
      case "Realizada sem matricula":
        color = Colors.green[700];
        break;
      case "Realizada com matricula posterior":
        color = Colors.green[700];
        break;
      case "Realizada Online":
        color = Colors.green[700];
        break;
      case "Falta":
        color = Theme.of(context).primaryColor;
        break;
      case "Cancelada pelo aluno":
        color = Theme.of(context).primaryColor;
        break;
      case "Cancelada pelo professor":
        color = Theme.of(context).primaryColor;
        break;
      case "aguardando":
        color = Theme.of(context).primaryColor;
        break;
      default:
        color = Colors.grey[800];
    }

    return Container(
      //width: MediaQuery.of(context).size.width < 350 ? 60 : 80,
      height: 18,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(2), color: color),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Text(
            label,
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                //fontSize: MediaQuery.of(context).size.width < 350 ? 10 : 14),
                fontSize: 14),
          ),
        ),
      ),
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
                  )),
        );
      },
      child: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[700], Colors.grey[800]]),
              // colors: [
              //   Theme.of(context).backgroundColor,
              //   Color(0xFF191919)
              // ]),
            ),
            width: double.infinity,
            height: 100,
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          Padding(
                            padding:
                                const EdgeInsets.only(top: 10.0, bottom: 5.0),
                            child: Container(
                              padding: EdgeInsets.all(8),
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.transparent,
                                image: DecorationImage(
                                  image: AssetImage(
                                    eventTypeIcon(document['class']),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          schoolLabel(document['unit_name'] ?? '-'),
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
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: AutoSizeText(
                                      document["name"],
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                    ),
                                  ),
                                  eventTimeLabel(
                                    document["date"].toDate(),
                                    document["duration"],
                                  ),
                                ],
                              ),
                              Row(
                                children: <Widget>[
                                  statusLabel(document["status"]),
                                  Expanded(
                                    child: Container(),
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
                                    child: labelStudentProfessor(document),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Icon(
                                      Icons.place,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8),
                                    child: Text(
                                      document["room"],
                                      style: TextStyle(
                                        color: Colors.white60,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: Colors.grey[800]),
        ],
      ),
    );
  }

  Widget labelStudentProfessor(DocumentSnapshot document) {
    if (_isTeacher) {
      if (document["students_id"].length > 1) {
        return Text(
          document["students_id"].length.toString() + " alunos",
          style: TextStyle(
            color: Colors.white60,
          ),
        );
      } else {
        if (document["students_id"][0].toString().isEmpty) {
          AutoSizeText(
            "*Aluno não cadastrado*",
            style: TextStyle(
              color: Colors.white60,
            ),
            maxFontSize: 14,
            maxLines: 1,
          );
        } else {
          return FutureBuilder<DocumentSnapshot>(
              future: Firestore.instance
                  .collection("users")
                  .document(document["students_id"][0])
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<DocumentSnapshot> snapshot) {
                if (snapshot.hasData) {
                  return AutoSizeText(
                    snapshot.data["display_name"].toString().length > 20
                        ? "${snapshot.data['display_name'].toString().substring(0, 15)}..."
                        : snapshot.data["display_name"].toString(),
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                    maxFontSize: 14,
                    maxLines: 1,
                  );
                }
                if (snapshot.hasError)
                  return Text(
                    " - ",
                    style: TextStyle(
                      color: Colors.white60,
                    ),
                  );
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    //return Text("");
                    return Container(
                      color: Colors.transparent,
                      width: 30,
                      height: 20,
                      child: Center(
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.transparent,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor),
                        ),
                      ),
                    );
                  default:
                    return Text(
                      "",
                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    );
                }
              });
        }
      }
    } else {
      return Text(
        document["teacher_name"],
        style: TextStyle(
          color: Colors.white60,
        ),
      );
    }
  }

  Widget eventTimeLabel(DateTime dateTime, int duration) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 5),
      child: Text(
        //"${dateTime.day}/${dateTime.month}/${dateTime.year} das ${dateTime.hour}:00-${dateTime.add(Duration(minutes: duration)).hour}:00",
        "${dateTime.hour}:00-${dateTime.add(Duration(minutes: duration)).hour}:00",
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MediaQuery.of(context).size.width < 350 ? 9 : 14,
            color: Colors.white),
      ),
    );
  }

  Future<void> reloadData() async {
    await getAllEvents();
    getEventsForSelectedPeriod(DateTime.now(), DateTime.now());
    _isLoading = false;
  }

  Future<void> syncAgenda() async {
    // primeiro: pegar os dados do usuário
    // segundo: checar se o usuário é s ou t (student ou teacher)
    // Caminho do student:
    // fazer um foreach para cada unidade que o aluno está cadastrado
    // depois pegamos a ID da unidade e a ID do usuário naquela unidade
    // faz um http request para trazer a agenda daquele aluno naquela unidade
    // remove o primeiro item da resposta do http request (API)
    // faz um foreach na lista de registros da agenda do usuário
    // pega a data da aula
    // Verifica se a data é posterior à data atual menos 14 dias
    // Pega os dados do professor usando o teacher_id que veio na requisição http (API)
    // Atualiza a agenda do aluno

    //_isLoading = true;

    print("Getting user data...");

    DocumentSnapshot user = await getUser();

    print("User: ${user.documentID}");

    if (user.data["type"] == "s") {
      print("Synching student agenda...");
      await syncStudentAgenda(user);
      print("Agenda synching success!");
    } else if (user.data["type"] == "t") {
      print("Synching teacher agenda...");
      await syncTeacherAgenda(user);
      print("Teacher Agenda synching success!");
    } else {
      print("Not a student nor teacher!");
    }

    _eventsList.clear();
    _allEventsForUser.clear();
    _markedDates.clear();
    _events.clear();

    await getAllEvents();
    getEventsForSelectedPeriod(DateTime.now(), DateTime.now());

    setState(() {
      _isSynchingAgenda = false;
    });

    // await Firestore.instance
    //     .collection("users")
    //     .document(_user.uid)
    //     .get()
    //     .then((u) {
    //   if (u.data["type"] == "s") {
    //     u.data["units"].forEach((unit) async {
    //       String userAPIKey = u.data["unity_key_${getUnitID(unit)}"][0];
    //       final response = await http.get(
    //           'https://extranet.academiadorock.com.br/app/lista_agenda_aluno.php?uni=${getUnitID(unit)}&chave=$userAPIKey');
    //       if (response.statusCode == 200) {
    //         // If the server did return a 200 OK response,
    //         // then parse the JSON.
    //         dynamic result = json.decode(response.body);
    //         List<dynamic> listAgenda = result["aulas"];
    //         if (listAgenda[0] == "") {
    //           // Primeiro item do array vem sempre em branco
    //           listAgenda.removeAt(0);
    //         }
    //         listAgenda.forEach((aula) async {
    //           Agenda agendaObject = Agenda.fromJson(aula);
    //           DateTime dateTime = DateTime.parse(
    //               "${agendaObject.dtAula} ${agendaObject.horaIni}");

    //           if (dateTime
    //               .isBefore(new DateTime.now().subtract(Duration(days: 30)))) {
    //             print("antes");
    //           } else {
    //             print("${agendaObject.classID}");
    //             var agenda = await Firestore.instance
    //                 .collection("agenda")
    //                 .where("class_id", isEqualTo: agendaObject.classID)
    //                 .getDocuments();

    //             if (agenda == null) {
    //               QuerySnapshot teacher = await Firestore.instance
    //                   .collection("users")
    //                   .where("unity_key_${getUnitID(unit)}",
    //                       arrayContains: agendaObject.teacherID)
    //                   .getDocuments();
    //               String teacherID = teacher.documents.length > 0
    //                   ? teacher.documents[0].documentID
    //                   : "";
    //               await Firestore.instance.collection("agenda").add({
    //                 "class_id": agendaObject.classID,
    //                 "class": agendaObject.className,
    //                 "duration": 60,
    //                 "room": agendaObject.room,
    //                 "status": agendaObject.status,
    //                 "student_finish": false,
    //                 "teacher_finish": false,
    //                 "students_id": FieldValue.arrayUnion([_user.uid]),
    //                 "teacher_id": teacherID,
    //                 "teacher_name": agendaObject.teacherName,
    //                 "name": agendaObject.className,
    //                 "unit_name": unit,
    //                 "date": DateTime.parse(
    //                     "${agendaObject.dtAula} ${agendaObject.horaIni}")
    //               });
    //             } else {
    //               await Firestore.instance
    //                   .collection("agenda")
    //                   .document(agenda.documents[0].documentID)
    //                   .setData(
    //                 {
    //                   "class_id": agendaObject.classID,
    //                   "class": agendaObject.className,
    //                   //"duration": minutes,
    //                   "room": agendaObject.room,
    //                   "status": agendaObject.status,
    //                   "student_finish": false,
    //                   "teacher_finish": false,
    //                   "students_id": FieldValue.arrayUnion([_user.uid]),
    //                   //"teacher_id": teacherID,
    //                   "teacher_name": agendaObject.teacherName,
    //                   "name": agendaObject.className,
    //                   "unit_name": unit,
    //                   "date": DateTime.parse(
    //                       "${agendaObject.dtAula} ${agendaObject.horaIni}"),
    //                 },
    //                 merge: true,
    //               );
    //             }
    //           }
    //         });
    //         print("fim");
    //       } else {
    //         // If the server did not return a 200 OK response,
    //         // then throw an exception.
    //         throw Exception('Failed to load data');
    //       }
    //     });
    //   } else if (u.data["type"] == "t") {
    //     print("professor");
    //     syncTeacherAgenda(u);
    //   } else {
    //     print("another user");
    //   }
    // });
  }

  Future<DocumentSnapshot> getUser() async {
    return await Firestore.instance
        .collection("users")
        .document(_user.uid)
        .get();
  }

  Future<String> getTeacherUID(
      {@required int unitID, @required String teacherID}) async {
    QuerySnapshot teacher = await Firestore.instance
        .collection("users")
        .where("unity_key_$unitID", arrayContains: teacherID)
        .getDocuments();
    return teacher.documents.length > 0 ? teacher.documents[0].documentID : "";
  }

  Future<List<dynamic>> getAgendaList(
      {@required int unitID, @required String userAPIKey}) async {
    final response = await http.get(
        'http://extranet.academiadorock.com.br/app/lista_agenda_aluno.php?uni=$unitID&chave=$userAPIKey');
    print(
        'http://extranet.academiadorock.com.br/app/lista_agenda_aluno.php?uni=$unitID&chave=$userAPIKey');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      dynamic result = json.decode(response.body);
      List<dynamic> listAgenda = result["aulas"];
      if (listAgenda[0] == "") {
        // Primeiro item do array vem sempre em branco
        listAgenda.removeAt(0);
      }
      return listAgenda;
    } else {
      throw Exception('Failed to load data');
    }
  }

  Future<void> createStudentAgenda(
      {@required Agenda agenda,
      @required String unit,
      @required String teacherUID}) async {
    print("Creating student agenda item...");
    DocumentReference createdAgenda =
        await Firestore.instance.collection("agenda").add({
      "class_id": agenda.classID,
      "class": agenda.className,
      "duration": 60,
      "room": agenda.room,
      "status": agenda.status,
      "student_finish": false,
      "teacher_finish": false,
      "students_id": [_user.uid],
      "teacher_id": teacherUID,
      "teacher_name": agenda.teacherName,
      "name": agenda.className,
      "unit_name": unit,
      "date": DateTime.parse("${agenda.dtAula} ${agenda.horaIni}")
    });
    await Firestore.instance
        .collection("agenda")
        .document(createdAgenda.documentID)
        .collection("students")
        .document(_user.uid)
        .setData({"instrument": agenda.className, "name": _user.displayName},
            merge: true);
    print("Student agenda item created!");
  }

  Future<void> updateStudentAgenda(
      {@required Agenda agenda,
      @required String agendaID,
      @required String unit,
      @required String teacherUID}) async {
    print("Updating student agenda item...");
    await Firestore.instance.collection("agenda").document(agendaID).setData(
      {
        "class_id": agenda.classID,
        "class": agenda.className,
        //"duration": minutes,
        "room": agenda.room,
        "status": agenda.status,
        "student_finish": false,
        "teacher_finish": false,
        "students_id": FieldValue.arrayUnion([_user.uid]),
        "teacher_id": teacherUID,
        "teacher_name": agenda.teacherName,
        "name": agenda.className,
        "unit_name": unit,
        "date": DateTime.parse("${agenda.dtAula} ${agenda.horaIni}"),
      },
      merge: true,
    );
    await Firestore.instance
        .collection("agenda")
        .document(agendaID)
        .collection("students")
        .document(_user.uid)
        .setData({"instrument": agenda.className, "name": _user.displayName},
            merge: true);
    print("student agenda item updated!");
  }

  Future<String> getAgendaID({@required String classID}) async {
    var agenda = await Firestore.instance
        .collection("agenda")
        .where("class_id", isEqualTo: classID)
        .getDocuments();

    return agenda != null && agenda.documents.length > 0
        ? agenda.documents[0].documentID
        : "";
  }

  Future<void> iterateAgendaList(
      {@required List<dynamic> agendaList,
      @required int unitID,
      @required String unit}) async {
    for (var aula in agendaList) {
      //agendaList.forEach((aula) async {
      print("Getting class data for aula: $aula...");
      Agenda agendaObject = Agenda.fromJson(aula);
      DateTime dateTime =
          DateTime.parse("${agendaObject.dtAula} ${agendaObject.horaIni}");
      print("Class datetime: $dateTime");
      print("Checking if class is in range...");
      if (dateTime.isAfter(new DateTime.now().subtract(Duration(days: 14)))) {
        print("Getting teacher UID...");
        String teacherUID = await getTeacherUID(
            unitID: unitID, teacherID: agendaObject.teacherID);
        print("Teacher UID: $teacherUID");
        print("Getting agenda ID...");
        String agendaID = await getAgendaID(classID: agendaObject.classID);
        print("Agenda ID: $agendaID");
        agendaID.isEmpty
            ? await createStudentAgenda(
                agenda: agendaObject, unit: unit, teacherUID: teacherUID)
            : await updateStudentAgenda(
                agenda: agendaObject,
                agendaID: agendaID,
                unit: unit,
                teacherUID: teacherUID);
      }
    }
  }

  Future<void> syncStudentAgenda(DocumentSnapshot user) async {
    print("Iterating user Units...");
    for (String unit in user.data["units"]) {
      //user.data["units"].forEach((unit) async {
      print("Unit: $unit");
      int unitID = getUnitID(unit);
      String userAPIKey = user.data["unity_key_$unitID"][0];

      print("UserAPIKey for unit: $userAPIKey");

      print("Getting Agenda list...");

      List<dynamic> agendaList =
          await getAgendaList(unitID: unitID, userAPIKey: userAPIKey);

      print("Agenda list OK!");

      print("Iterating agenda list...");
      await iterateAgendaList(
          agendaList: agendaList, unitID: unitID, unit: unit);
      print("Iteration agenda list completed!");
    }
  }

  Future<void> syncTeacherAgenda(DocumentSnapshot u) async {
    // Itera as unidades nas quais o professor trabalha
    // Dentro da unicade, itera todas as IDs que o professor tem na unidade
    // Faz http request para buscar a agenda do professor usando sua chave e o número da unidade
    // Traduz a lista que chegou para JSON
    // Remove o primeiro item da lista
    // Itera a lista de aulas que chegou pela API
    // Traduz a aula para objeto Agenda
    // Verifica se a data da aula é maior que 14 dias atrás
    // Pega os dados do aluno da aula
    // Seta dados do curso que o aluno faz
    // Salva dados do curso que o aluno faz
    // Verifica se a aula já está salva no banco de dados
    // Se a aula não existe, cria no Firebase
    // Salva dados do aluno na aula criada
    // Se a aula existe, atualiza os dados no Firebase
    // Salva dados do aluno na aula criada

    print("Iterating units for teacher...");
    for (var unit in u.data["units"]) {
      int unitID = getUnitID(unit);
      print("Get unitID: $unitID");

      print("Getting user API keys...");

      await iterateTeacherUnitIDs(u: u, unitID: unitID, unit: unit);
    }

    // u.data["units"].forEach((unit) async {
    //   u.data["unity_key_${getUnitID(unit)}"].forEach((unitUser) async {
    //     String userAPIKey = unitUser;
    //     final response = await http.get(
    //         'https://extranet.academiadorock.com.br/app/lista_agenda_profe.php?uni=${getUnitID(unit)}&chave=$userAPIKey');
    //     if (response.statusCode == 200) {
    //       // If the server did return a 200 OK response,
    //       // then parse the JSON.
    //       dynamic result = json.decode(response.body);
    //       List<dynamic> listAgenda = result["aulas"];
    //       if (listAgenda[0] == "") {
    //         // Primeiro item do array vem sempre em branco
    //         listAgenda.removeAt(0);
    //       }
    //       listAgenda.forEach((aula) {
    //         Timer(const Duration(milliseconds: 400), () async {
    //           await loadData(aula, unit);
    //         });
    //       });
    //       print("fim2");
    //     } else {
    //       // If the server did not return a 200 OK response,
    //       // then throw an exception.
    //       throw Exception('Failed to load data');
    //     }
    //   });
    // });
  }

  Future<void> iterateTeacherUnitIDs(
      {@required DocumentSnapshot u,
      @required int unitID,
      @required String unit}) async {
    for (var unitUser in u.data["unity_key_$unitID"]) {
      String userAPIKey = unitUser;
      print("userAPIKey: $userAPIKey");
      List<dynamic> listAgenda =
          await getTeacherAgendaList(unitID: unitID, userAPIKey: userAPIKey);

      print("Teacher agenda loaded!");

      print("Iterating teacher agenda list...");
      await iterateTeacherAgendaList(
          agendaList: listAgenda, unitID: unitID, unit: unit);
      print("Teacher agenda iterated!");
    }
  }

  Future<List<dynamic>> getTeacherAgendaList(
      {@required int unitID, @required String userAPIKey}) async {
    final response = await http.get(
        'http://extranet.academiadorock.com.br/app/lista_agenda_profe.php?uni=$unitID&chave=$userAPIKey');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      dynamic result = json.decode(response.body);
      List<dynamic> listAgenda = result["aulas"];
      if (listAgenda[0] == "") {
        // Primeiro item do array vem sempre em branco
        listAgenda.removeAt(0);
        print("Removido o primeiro item da lista.");
      }
      return listAgenda;
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load data');
    }
  }

  Future<void> iterateTeacherAgendaList(
      {@required List<dynamic> agendaList,
      @required int unitID,
      @required String unit}) async {
    for (var aula in agendaList) {
      Agenda agendaObject = Agenda.fromJson(aula);

      DateTime dateTime =
          DateTime.parse("${agendaObject.dtAula} ${agendaObject.horaIni}");

      if (dateTime.isAfter(new DateTime.now().subtract(Duration(days: 14))) &&
          dateTime.isBefore(new DateTime.now().add(Duration(days: 45)))) {
        print("Data da aula maior que 14 dias atrás!");

        print("Buscando dados do aluno que pertence à aula...");

        QuerySnapshot studentSnapshot = await getStudentData(
            unitID: unitID, studentAPIKey: aula["chave_aluno"]);

        DocumentSnapshot student =
            studentSnapshot == null || studentSnapshot.documents.length == 0
                ? null
                : studentSnapshot.documents[0];

        print("Student: $student");

        print("Criando dados de aula que o aluno faz...");
        dynamic addClass = {
          "api_id": instrumentID(agendaObject.className) ?? 0,
          "code": instrumentCode(agendaObject.className) ?? "MUSIC",
          "name": agendaObject.className ?? "Música"
        };

        String studentID = "";
        String studentName = "";

        if (student != null) {
          studentID = student.documentID;
          studentName = student.data["display_name"].toString();

          await Firestore.instance
              .collection("users")
              .document(student.documentID)
              .setData({
            "classes": FieldValue.arrayUnion([addClass])
          }, merge: true);
        }
        String agendaID = await getClassID(agendaObject: agendaObject);
        if (agendaID.isEmpty) {
          print("Creating teacher agenda entry...");
          await createTeacherAgenda(
              agendaID: agendaID,
              agendaObject: agendaObject,
              studentID: studentID,
              studentName: studentName,
              unit: unit);
          print("Teacher agenda entry created!");
        } else {
          print("Updating teacher agenda...");
          await updateTeacherAgenda(
              agendaID: agendaID,
              agendaObject: agendaObject,
              studentID: studentID,
              studentName: studentName,
              unit: unit);
          print("Teacher agenda updated!");
        }
      }
    }
  }

  Future<QuerySnapshot> getStudentData(
      {@required int unitID, @required String studentAPIKey}) async {
    QuerySnapshot student = await Firestore.instance
        .collection("users")
        .where("unity_key_$unitID", arrayContains: studentAPIKey)
        .getDocuments();

    return student != null && student.documents.length > 0 ? student : null;
  }

  Future<String> getClassID({@required Agenda agendaObject}) async {
    var firebaseAgenda = await Firestore.instance
        .collection("agenda")
        .where("class_id", isEqualTo: agendaObject.classID)
        .getDocuments();

    return firebaseAgenda != null && firebaseAgenda.documents.length > 0
        ? firebaseAgenda.documents[0].documentID
        : "";
  }

  Future<void> createTeacherAgenda(
      {@required String agendaID,
      @required Agenda agendaObject,
      @required String studentID,
      @required String studentName,
      @required String unit}) async {
    print("Preparing to create agenda entry...");
    var newAgenda = await Firestore.instance.collection("agenda").add({
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
      "date": DateTime.parse("${agendaObject.dtAula} ${agendaObject.horaIni}")
    });
    print("New agenda entry created");
    print("Creating instruments for student...");
    if (studentID.length > 0) {
      await Firestore.instance
          .collection("agenda")
          .document(newAgenda.documentID)
          .collection("students")
          .document(studentID)
          .setData({"instrument": agendaObject.className, "name": studentName},
              merge: true);
    }
  }

  Future<void> updateTeacherAgenda(
      {@required String agendaID,
      @required Agenda agendaObject,
      @required String studentID,
      @required String studentName,
      @required String unit}) async {
    await Firestore.instance.collection("agenda").document(agendaID).setData(
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
        "date":
            DateTime.parse("${agendaObject.dtAula} ${agendaObject.horaIni}"),
      },
      merge: true,
    );
    if (studentID.length > 0) {
      await Firestore.instance
          .collection("agenda")
          .document(agendaID)
          .collection("students")
          .document(studentID)
          .setData({"instrument": agendaObject.className, "name": studentName},
              merge: true);
    }
  }

  Future<void> loadData(dynamic aula, dynamic unit) async {
    Agenda agendaObject = Agenda.fromJson(aula);
    DateTime dateTime =
        DateTime.parse("${agendaObject.dtAula} ${agendaObject.horaIni}");

    if (dateTime.isBefore(new DateTime.now().subtract(Duration(days: 30)))) {
      //print("antes");
    } else {
      //print("unidade: unity_key_${getUnitID(unit)}");
      await Firestore.instance
          .collection("users")
          .where("unity_key_${getUnitID(unit)}",
              arrayContains: aula["chave_aluno"])
          .getDocuments()
          .then((student) async {
        String studentID =
            student.documents.length > 0 ? student.documents[0].documentID : "";

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

        var firebaseAgenda = await Firestore.instance
            .collection("agenda")
            .where("class_id", isEqualTo: agendaObject.classID)
            .getDocuments();

        if (firebaseAgenda != null) {
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
          );
          await Firestore.instance
              .collection("agenda")
              .document(firebaseAgenda.documents[0].documentID)
              .collection("students")
              .document(studentID)
              .setData({
            "instrument": agendaObject.className,
            "name": student.documents[0].data["display_name"].toString()
          }, merge: true);
        } else {
          QuerySnapshot student = await Firestore.instance
              .collection("users")
              .where("unity_key_${getUnitID(unit)}",
                  arrayContains: aula["chave_aluno"])
              .getDocuments();
          String studentID = student.documents.length > 0
              ? student.documents[0].documentID
              : "";
          var newAgenda = await Firestore.instance.collection("agenda").add({
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
            "date":
                DateTime.parse("${agendaObject.dtAula} ${agendaObject.horaIni}")
          });
          await Firestore.instance
              .collection("agenda")
              .document(newAgenda.documentID)
              .collection("students")
              .document(studentID)
              .setData({
            "instrument": agendaObject.className,
            "name": student.documents[0].data["display_name"].toString()
          }, merge: true);
        }
        return student;
      }).catchError((error) {
        print("${error.toString()}");
      });
    }
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
      case "Ukulele":
        return 33;
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
      case "Ukulele":
        return "UKE";
        break;
      default:
        return "MUSIC";
    }
  }

  @override
  void dispose() {
    // _animationController.dispose();
    // _calendarController.dispose();
    // super.dispose();
  }
}
