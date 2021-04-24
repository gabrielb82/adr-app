import 'package:academia_do_rock_app/src/common_widgets/avatar_widget.dart';
import 'package:academia_do_rock_app/src/main_tab/calendar_screen/user_list_screen.dart';
import 'package:academia_do_rock_app/src/models/classess.dart';
import 'package:academia_do_rock_app/src/models/user.dart';
import 'package:academia_do_rock_app/src/services/firebase_cloud_messaging.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:calendar_strip/calendar_strip.dart';
import 'package:flutter_xlider/flutter_xlider.dart';

class AddClassScreen extends StatefulWidget {
  final DocumentSnapshot userData;

  AddClassScreen({
    Key key,
    @required this.userData,
  }) : super(key: key);

  @override
  _AddClassScreenState createState() => _AddClassScreenState();
}

class _AddClassScreenState extends State<AddClassScreen> {
  ScrollController _scrollController;

  final _hourFieldController = TextEditingController();
  final _minutesFieldController = TextEditingController();

  int _minimunTime = 0;
  DateTime _startDate = DateTime.now();
  DateTime _selectedDate = DateTime.now().add(Duration(days: 1));
  int _currentTimeRange = 0;

  int _classHour = 0;
  double _maxHour = 20;
  double _myHour = 9;

  User _user;
  List<Widget> _listClassess = [];
  List<Widget> _listPlaces = [];
  String _selectedInstrument = "";
  String _selectedPlace = "On-line";

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    setState(() {
      _myHour = 9;
      _selectedInstrument = "";
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              centerTitle: true,
              backgroundColor: Theme.of(context).backgroundColor,
              title: Text(
                "Agendar Aula",
                style: TextStyle(
                  fontSize: 24,
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
                  colors: [
                    Theme.of(context).backgroundColor,
                    Color(0xFF191919)
                  ]),
            ),
            child: ListView(
              children: <Widget>[
                _studentCard(),
                _classCard(),
                _placeCard(),
                _dateCard(),
                _timeCard(),
                _saveClass(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _studentCard() {
    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[800], Colors.grey[850]],
          ),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0, right: 18.0, left: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Aluno",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Theme.of(context).primaryColor,
              ),
              Container(
                height: 20,
              ),
              _studentDataWidget(),
              _user != null ? _userDataPanel() : Container(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _studentDataWidget() {
    return GestureDetector(
      onTap: () async {
        _user = await Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => UserListScreen(userData: widget.userData)),
        );
        DocumentSnapshot tempUser = await Firestore.instance
            .collection("users")
            .document(_user.uid)
            .get();
        if (tempUser.data["classes"] != null) {
          List tempClassess = tempUser.data["classes"].toList();
          tempClassess.forEach((c) {
            _user.classess.add(Classess.fromArray(c));
          });
        }
        _listClassess.clear();
        _user.classess.forEach((c) {
          if (_selectedInstrument == "") {
            _selectedInstrument = c.code;
          }
          _listClassess.add(_instrumentButton(c));
        });
        setState(() {});
      },
      child: Container(
        child: Padding(
          padding: const EdgeInsets.only(left: 0, right: 0, bottom: 24),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              height: 50,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        child: AutoSizeText(
                          "Buscar aluno",
                          maxLines: 1,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _saveClass() {
    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[800], Colors.grey[850]]),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          child: GestureDetector(
            onTap: () {
              if (_selectedDate.day == null ||
                  _selectedInstrument == "" ||
                  _minutesFieldController.text == "" ||
                  _hourFieldController.text == "" ||
                  _user == null) {
                errorAlert();
              } else {
                showConfirmDialog();
              }
            },
            child: Container(
              child: Padding(
                padding: const EdgeInsets.only(left: 12, right: 12),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Theme.of(context).primaryColor,
                    ),
                    child: Center(
                      child: Text(
                        "Agendar",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loadPlaces() {
    _listPlaces.clear();
    widget.userData.data["units"].forEach((unit) {
      _listPlaces.add(_placeButton(unit));
    });

    _listPlaces.add(_placeButton("On-line"));

    setState(() {});
  }

  Widget _placeCard() {
    _loadPlaces();
    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[800], Colors.grey[850]]),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0, right: 18.0, left: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 20,
              ),
              Text(
                "Local",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Theme.of(context).primaryColor,
              ),
              Container(
                height: 20,
              ),
              Column(
                children: _listPlaces,
              ),
              //_timeSlider(),
              Container(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dateCard() {
    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.grey[800], Colors.grey[850]],
          ),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0, right: 8.0, left: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                "Dia",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Theme.of(context).primaryColor,
              ),
              Container(
                height: 20,
              ),
              CalendarStrip(
                iconColor: Colors.white,
                startDate: _startDate,
                endDate: _startDate.add(Duration(days: 30)),
                addSwipeGesture: true,
                dateTileBuilder: dateTileBuilder,
                monthNameWidget: monthNameWidget,
                onDateSelected: (date) {
                  //print("click $date");
                  _selectedDate = date;

                  //print(DateTime.now().day);
                  print(date.day);

                  // if (date.day == DateTime.now().day) {
                  //   _minimunTime = _currentTimeRange + 8;
                  //   _lowerValue = (_currentTimeRange + 10).toDouble();
                  //   _upperValue = (_currentTimeRange + 18).toDouble();
                  // }

                  setState(() {});
                },
              ),
              Container(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeCard() {
    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
      elevation: 1,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[800], Colors.grey[850]]),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0, right: 18.0, left: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 20,
              ),
              Text(
                "Horário",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Theme.of(context).primaryColor,
              ),
              Container(
                height: 20,
              ),
              _classTime(),
              //_timeSlider(),
              Container(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _classCard() {
    return Card(
      color: Colors.transparent,
      margin: const EdgeInsets.only(top: 12.0, right: 12.0, left: 12.0),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[800], Colors.grey[850]]),
        ),
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0, right: 18.0, left: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 20,
              ),
              Text(
                "Instrumento",
                style: TextStyle(
                  color: Colors.white60,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: double.infinity,
                height: 1,
                color: Theme.of(context).primaryColor,
              ),
              Container(
                height: 20,
              ),
              // Text("Selecione um aluno primeiro..."),
              Container(
                child: _listClassess.length == 0
                    ? Text(
                        "Nenhuma aula selecionada...",
                        style: TextStyle(
                          color: Colors.white60,
                        ),
                      )
                    : Column(
                        children: _listClassess,
                      ),
              ),
              Container(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  dateTileBuilder(
      date, selectedDate, rowIndex, dayName, isDateMarked, isDateOutOfRange) {
    bool isSelectedDate = date.compareTo(selectedDate) == 0;
    Color fontColor = isDateOutOfRange ? Colors.black26 : Colors.white60;
    TextStyle normalStyle =
        TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: fontColor);
    TextStyle selectedStyle = TextStyle(
        fontSize: 17, fontWeight: FontWeight.w800, color: Colors.white);
    TextStyle dayNameStyle = isSelectedDate
        ? TextStyle(fontSize: 14.5, color: Colors.white)
        : TextStyle(fontSize: 14.5, color: fontColor);
    List<Widget> _children = [
      Text(convertWeekDayToPortuguese(dayName), style: dayNameStyle),
      Text(date.day.toString(),
          style: !isSelectedDate ? normalStyle : selectedStyle),
    ];

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

  monthNameWidget(monthName) {
    return Container(
      child: Text(
        convertMonthNameToPortuguese(monthName),
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w600,
          color: Colors.white60,
          fontStyle: FontStyle.normal,
        ),
      ),
      padding: EdgeInsets.only(top: 8, bottom: 4),
    );
  }

  String convertMonthNameToPortuguese(String monthName) {
    if (monthName.contains('January'))
      return monthName.replaceFirst('January', 'Janeiro');
    if (monthName.contains('February'))
      return monthName.replaceFirst('February', 'Fevereiro');
    if (monthName.contains('March'))
      return monthName.replaceFirst('March', 'Março');
    if (monthName.contains('April'))
      return monthName.replaceFirst('April', 'Abril');
    if (monthName.contains('May')) return monthName.replaceFirst('May', 'Maio');
    if (monthName.contains('June'))
      return monthName.replaceFirst('June', 'Junho');
    if (monthName.contains('July'))
      return monthName.replaceFirst('July', 'Julho');
    if (monthName.contains('August'))
      return monthName.replaceFirst('August', 'Agosto');
    if (monthName.contains('September'))
      return monthName.replaceFirst('September', 'Setembro');
    if (monthName.contains('October'))
      return monthName.replaceFirst('October', 'Outubro');
    if (monthName.contains('November'))
      return monthName.replaceFirst('November', 'Novembro');
    if (monthName.contains('December'))
      return monthName.replaceFirst('December', 'Dezembro');
    return monthName;
  }

  String convertWeekDayToPortuguese(String weekDay) {
    switch (weekDay) {
      case 'Mon':
        return 'Seg';
        break;
      case 'Tue':
        return 'Ter';
        break;
      case 'Wed':
        return 'Qua';
        break;
      case 'Thr':
        return 'Qui';
        break;
      case 'Fri':
        return 'Sex';
        break;
      case 'Sat':
        return 'Sab';
        break;
      case 'Sun':
        return 'Dom';
        break;
      default:
        return 'Dia';
    }
  }

  Widget _timeSlider() {
    return FlutterSlider(
      values: [_myHour],
      min: 9,
      max: _maxHour,
      step: FlutterSliderStep(step: 1),
      rangeSlider: false,
      trackBar: FlutterSliderTrackBar(
        activeTrackBar: BoxDecoration(
          color: Colors.grey[200],
          // color: Theme.of(context).primaryColor,
        ),
      ),
      tooltip: FlutterSliderTooltip(
        disabled: true,
        alwaysShowTooltip: false,
        custom: (value) {
          return Text(
            value.round().toString(),
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
      handlerHeight: 30,
      handlerWidth: 30,
      handler: FlutterSliderHandler(
        child: Text("$_classHour",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            )),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          shape: BoxShape.circle,
        ),
      ),
      onDragging: (handlerIndex, lowerValue, upperValue) {
        setState(() {
          _myHour = lowerValue.toDouble();
          _classHour = lowerValue.toInt();
        });
      },
      onDragCompleted: (handlerIndex, lowerValue, upperValue) {
        setState(() {
          _myHour = lowerValue.toDouble();
          _maxHour = _maxHour == 20 ? 20.1 : 20;
        });
      },
    );
  }

  Widget _userDataPanel() {
    return Container(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: Column(
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: AvatarWidget(
                      userID: _user.uid, userName: _user.displayName),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                    child: AutoSizeText(
                      _user.displayName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.normal,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  child: _user.unitName == ""
                      ? Container()
                      : RaisedButton(
                          child: AutoSizeText(
                            '${_user.unitName}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.white60,
                            ),
                            maxLines: 1,
                          ),
                          onPressed: () {},
                          color: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(
                                (MediaQuery.of(context).size.width * 0.3) / 4),
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
          ],
        ),
      ),
    );
  }

  Widget _classTime() {
    return Row(
      children: <Widget>[
        Flexible(
          child: TextField(
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
            controller: _hourFieldController,
            keyboardType: TextInputType.number,
            maxLength: 2,
            maxLines: 1,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              helperStyle: TextStyle(color: Colors.white60),
              focusColor: Colors.white,
              //hintText: "14",
            ),
          ),
        ),
        Text(
          " : ",
          style: TextStyle(
            fontSize: 24,
            color: Colors.white60,
          ),
        ),
        Flexible(
          child: TextField(
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
            ),
            controller: _minutesFieldController,
            keyboardType: TextInputType.number,
            maxLength: 2,
            maxLines: 1,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterStyle: TextStyle(color: Colors.white60),
              helperStyle: TextStyle(color: Colors.white60),
              focusColor: Colors.white,
              //hintText: "14",
            ),
          ),
        ),
      ],
    );
  }

  Widget _instrumentButton(Classess instrument) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: RaisedButton(
        color: instrument.code == _selectedInstrument
            ? Theme.of(context).primaryColor
            : Colors.grey[800],
        onPressed: () {
          _selectedInstrument = instrument.code;
          _listClassess.clear();
          _user.classess.forEach((c) {
            if (_selectedInstrument == "") {
              _selectedInstrument = c.code;
            }
            _listClassess.add(_instrumentButton(c));
          });
          setState(() {});
        },
        child: Container(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                child: Container(
                  padding: EdgeInsets.all(8),
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.transparent,
                    image: DecorationImage(
                      image: AssetImage(
                        eventTypeIcon(instrument.code),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutoSizeText(
                    instrument.name,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: instrument.code == _selectedInstrument
                          ? Colors.white
                          : Colors.white60,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeButton(String place) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
      child: RaisedButton(
        color: _selectedPlace == place
            ? Theme.of(context).primaryColor
            : Colors.grey[800],
        onPressed: () {
          _selectedPlace = place;
          // _listClassess.clear();
          // _user.classess.forEach((c) {
          //   if (_selectedInstrument == "") {
          //     _selectedInstrument = c.code;
          //   }
          //   _listClassess.add(_instrumentButton(c));
          // });
          setState(() {});
        },
        child: Container(
          width: double.infinity,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: AutoSizeText(
                    place,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _selectedPlace == place
                          ? Colors.white
                          : Colors.white60,
                    ),
                  ),
                ),
              ),
              _selectedPlace == place
                  ? Icon(
                      Icons.check,
                      color: Colors.white,
                    )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }

  String eventTypeIcon(String eventType) {
    switch (eventType) {
      case "DRUM":
        return "assets/icons/drum-set.png";
        break;
      case "GUIT":
        return "assets/icons/icon_guitar.png";
        break;
      case "BASS":
        return "assets/icons/icon_bass.png";
        break;
      case "PET":
        return "assets/icons/icon_keyboard.png";
        break;
      case "PSC":
        return "assets/icons/icon_piano.png";
        break;
      case "PCJ":
        return "assets/icons/icon_band_new.png";
        break;
      case "VOCAL":
        return "assets/icons/icon_singing.png";
        break;
      case "CTUR":
        return "assets/icons/icon_singing_duo.png";
        break;
      case "HAR":
        return "assets/icons/icon_harmonica.png";
        break;
      default:
        return "assets/icons/icon_default.png";
    }
  }

  String instrumentTranslatedName(String instrumentID) {
    switch (instrumentID) {
      case "DRUM":
        return "drums";
        break;
      case "GUIT":
        return "guitar";
        break;
      case "BASS":
        return "bass";
        break;
      case "PET":
        return "keyboard";
        break;
      case "PSC":
        return "piano";
        break;
      case "PCJ":
        return "band";
        break;
      case "VOCAL":
        return "vocal";
        break;
      case "CTUR":
        return "vocal-duo";
        break;
      case "HAR":
        return "harmonica";
        break;
      default:
        return "music";
    }
  }

  String classTranslatedName(String instrumentID) {
    switch (instrumentID) {
      case "DRUM":
        return "Aula de bateria";
        break;
      case "GUIT":
        return "Aula de guitarra";
        break;
      case "BASS":
        return "Aula de baixo";
        break;
      case "PET":
        return "Aula de teclado";
        break;
      case "PSC":
        return "Aula de piano";
        break;
      case "PCJ":
        return "Prática de banda";
        break;
      case "VOCAL":
        return "Aula de vocal";
        break;
      case "CTUR":
        return "Aula de vocal em dupla";
        break;
      case "HAR":
        return "Aula de gaita";
        break;
      case "VIOL":
        return "Aula de violão";
        break;
      case "V-ISC":
        return "Aula de violão - externo";
        break;
      default:
        return "Aula de música";
    }
  }

  //DIALOGS ***************************
  void errorAlert() {
    Alert(
      context: context,
      type: AlertType.error,
      title: "ERRO!",
      desc: "Preencha o formulário corretamente.",
      buttons: [
        DialogButton(
          color: Theme.of(context).primaryColor,
          child: Text(
            "OK",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        ),
      ],
    ).show();
  }

  void showConfirmDialog() {
    Alert(
      context: context,
      type: AlertType.info,
      title: "AGENDAR AULA",
      desc: "Você deseja realmente agendar esta aula?",
      buttons: [
        DialogButton(
          child: Text(
            "NÃO",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          width: 120,
        ),
        DialogButton(
          color: Theme.of(context).primaryColor,
          child: Text(
            "SIM",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => scheduleClass(),
          // onPressed: () => sendAbsentStatus(),
          width: 120,
        )
      ],
    ).show();
  }

  void scheduleClass() {
    Navigator.pop(context);
    Alert(
      context: context,
      type: AlertType.info,
      title: "AGUARDE",
      desc: "Espere enquanto a aula está sendo agendada.",
      buttons: [],
    ).show();

    String month = _selectedDate.month.toString().length == 1
        ? "0${_selectedDate.month.toString()}"
        : _selectedDate.month.toString();
    String day = _selectedDate.day.toString().length == 1
        ? "0${_selectedDate.day.toString()}"
        : _selectedDate.day.toString();

    Firestore.instance.collection("agenda").add({
      "class_id": "0",
      "class": instrumentTranslatedName(_selectedInstrument),
      "duration": 60,
      "room": "-",
      "status": "aguardando",
      "student_finish": false,
      "teacher_finish": false,
      "students_id": [_user.uid],
      "unit_name": _selectedPlace,
      "teacher_id": widget.userData.documentID,
      "teacher_name": widget.userData.data["display_name"],
      "name": classTranslatedName(_selectedInstrument),
      "date": DateTime.parse(
          "${_selectedDate.year.toString()}-$month-$day ${_hourFieldController.text}:${_minutesFieldController.text}:00")
    }).then((agenda) {
      Firestore.instance
          .collection("agenda")
          .document(agenda.documentID)
          .collection("students")
          .document(_user.uid)
          .setData({
        "instrument": instrumentTranslatedName(_selectedInstrument),
        "name": _user.displayName
      }, merge: true).then((student) {
        Firestore.instance
            .collection("users")
            .document(_user.uid)
            .collection("notifications")
            .add({
          "date": DateTime.now(),
          "title": "Nova aula agendada",
          "message":
              "Uma nova aula foi agendada para o dia $day/$month/${_selectedDate.year.toString()} às ${_hourFieldController.text}:${_minutesFieldController.text}. Acesse seu calendário para confirmar a data marcada.",
          "reference": agenda.documentID,
          "type": "class"
        }).then((notification) {
          Firestore.instance
              .collection("users")
              .document(_user.uid)
              .collection("notification_tokens")
              .getDocuments()
              .then((notificationTokens) {
            List<String> tokens = [];
            notificationTokens.documents.forEach((doc) {
              tokens.add(doc.data["token"].toString());
            });
            FirebaseCloudMessage.send(
                "Nova aula agendada",
                "Uma nova aula foi agendada para o dia $day/$month/${_selectedDate.year.toString()} às ${_hourFieldController.text}:${_minutesFieldController.text}. Acesse o apicativo para confirmar a data marcada.",
                tokens);
          }).whenComplete(() {
            Firestore.instance
                .collection("users")
                .document(widget.userData.documentID)
                .collection("activities")
                .add({
              "activity":
                  "Agendou nova aula para o dia $day/$month/${_selectedDate.year.toString()} às ${_hourFieldController.text}:${_minutesFieldController.text} com ${_user.displayName}",
              "title": "Aula agendada",
              "type": "class-create",
              "date": DateTime.now()
            }).then((onValue) {
              Navigator.pop(context);
              Alert(
                context: context,
                type: AlertType.success,
                title: "AULA AGENDADA",
                desc: "Agora aguarde pela confirmação do aluno.",
                buttons: [
                  DialogButton(
                    color: Theme.of(context).primaryColor,
                    child: Text(
                      "OK",
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    width: 120,
                  )
                ],
              ).show();
            });
          });
        });
      });
    }).catchError((onError) {
      Navigator.pop(context);
      Alert(
        context: context,
        type: AlertType.error,
        title: "ERRO",
        desc:
            "Erro ao agendar aula. Por favor, verifique as informações e tente novamente.",
        buttons: [
          DialogButton(
            color: Theme.of(context).primaryColor,
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
            width: 120,
          )
        ],
      ).show();
    });

    // Firestore.instance
    //     .collection("users")
    //     .document(_user.uid)
    //     .get()
    //     .then((user) {
    //   Firestore.instance
    //       .collection("agenda")
    //       .document(widget.classData.documentID)
    //       .setData({
    //     "status": "cancelado",
    //     "student_finish": true,
    //     "teacher_finish": true,
    //   }, merge: true).then((v) async {
    //     //await getClassData();
    //     Navigator.pop(context);
    //     Alert(
    //       context: context,
    //       type: AlertType.success,
    //       title: "AULA AGENDADA",
    //       desc:
    //           "Aula agendada com sucesso! Agora aguarde pela confirmação do aluno.",
    //       buttons: [
    //         DialogButton(
    //           color: Theme.of(context).primaryColor,
    //           child: Text(
    //             "OK",
    //             style: TextStyle(color: Colors.white, fontSize: 20),
    //           ),
    //           onPressed: () => Navigator.pop(context),
    //           width: 120,
    //         )
    //       ],
    //     ).show();
    //   });
    // });
  }
}
