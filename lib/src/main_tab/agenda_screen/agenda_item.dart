import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AgendaItem extends StatefulWidget {
  final String typeClass;
  final Timestamp date;
  final int duration;
  final String teacherName;
  final String teacherAvatar;
  final String status;

  AgendaItem({
    Key key,
    @required this.typeClass,
    @required this.date,
    @required this.duration,
    @required this.teacherName,
    @required this.teacherAvatar,
    this.status,
  }) : super(key: key);

  @override
  _AgendaItemState createState() => _AgendaItemState();
}

class _AgendaItemState extends State<AgendaItem> {
  @override
  Widget build(BuildContext context) {
    String minutes = widget.date.toDate().minute.toInt() > 10
        ? widget.date.toDate().minute.toString()
        : "0${widget.date.toDate().minute.toString()}";
    return Container(
      color: Colors.white,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey,
                image: DecorationImage(
                  image: AssetImage(classIcon()),
                  fit: BoxFit.scaleDown,
                ),
              ),
              child: Stack(
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    //color: Color(0xAA000000),
                    color: Color(0xEEFFA000),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          Text(
                            "${widget.date.toDate().day}/${widget.date.toDate().month}",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: Text(
                                "${widget.date.toDate().hour}:$minutes",
                                style: TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                personData(context, widget.teacherAvatar, widget.teacherName,
                    "Professor"),
                // Divider(
                //   indent: 15.0,
                //   color: Colors.grey,
                // ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: <Widget>[
                      Icon(
                        Icons.place,
                        color: Theme.of(context).primaryColor,
                      ),
                      Text("Sala 9"),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                RaisedButton(
                  child: Text(
                    "Prevista",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {},
                  color: Colors.green[400],
                  shape: RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(
                        (MediaQuery.of(context).size.width * 0.3) / 4),
                    side: BorderSide(
                      color: Colors.green[400],
                    ),
                  ),
                ),
                Text("1h"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget personData(BuildContext context, String personAvatar,
      String personNome, String personType) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: <Widget>[
          Container(
            child: Center(child: avatar(personAvatar, personNome)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  widget.teacherName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  personType,
                  style: TextStyle(fontSize: 12),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget avatar(String avatar, String name) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, top: 8),
      child: Center(
        child: Container(
          width: 40,
          height: 40,
          child: avatarImage(avatar, name[0]),
        ),
      ),
    );
  }

  Widget avatarImage(String url, String displayNameInitials) {
    return CircularProfileAvatar(
      url,
      radius: 50,
      backgroundColor: Colors.transparent,
      borderWidth: 1,
      initialsText: Text(
        displayNameInitials,
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
      borderColor: Theme.of(context).primaryColor,
      elevation: 1,
      cacheImage: true,
    );
  }

  String classIcon() {
    switch (widget.typeClass) {
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
