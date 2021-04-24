import 'dart:async';
import 'dart:convert';

import 'package:academia_do_rock_app/src/main_tab/agenda_screen/agenda_details/comments_panel.dart';
import 'package:academia_do_rock_app/src/main_tab/agenda_screen/agenda_details/content_panel.dart';
import 'package:academia_do_rock_app/src/main_tab/agenda_screen/agenda_details/details_panel.dart';
import 'package:academia_do_rock_app/src/services/firebase_cloud_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as prefix0;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:http/http.dart' as http;

class AgendaDetail extends StatefulWidget {
  final DocumentSnapshot userData;
  final DocumentSnapshot classData;

  AgendaDetail({
    Key key,
    @required this.userData,
    @required this.classData,
  }) : super(key: key);

  @override
  _AgendaDetailState createState() => _AgendaDetailState();
}

class _AgendaDetailState extends State<AgendaDetail> {
  ScrollController _scrollController;
  ScrollController _listScrollController;
  final _commentFieldController = TextEditingController();
  final _contentFieldController = TextEditingController();
  FocusNode _commentFieldFocus = FocusNode();
  FocusNode _contentFieldFocus = FocusNode();
  DocumentSnapshot _classData;

  bool _isLoading = false;

  FirebaseUser _user;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _listScrollController = ScrollController();
    super.initState();
    getUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void getUser() async {
    _user = await _auth.currentUser();
    getClassData();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      controller: _scrollController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          SliverAppBar(
            actions: <Widget>[
              PopupMenuButton(
                color: Theme.of(context).backgroundColor,
                itemBuilder: (_) => widget.classData.data["status"] ==
                        "Prevista"
                    ? _waitingMenu()
                    : <PopupMenuEntry<Object>>[
                        widget.userData.data["type"] == "t"
                            ? PopupMenuItem<String>(
                                child: Row(
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Icon(Icons.note_add),
                                    ),
                                    Text('Adicionar Conteúdo'),
                                  ],
                                ),
                                value: 'content',
                              )
                            : null,
                        PopupMenuItem<String>(
                          child: Row(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(Icons.add_comment),
                              ),
                              Text(
                                'Adicionar Comentário',
                                style: TextStyle(color: Colors.white60),
                              ),
                            ],
                          ),
                          value: 'comment',
                        ),
                        PopupMenuDivider(height: 1),
                        cancelClassMenu(),
                        PopupMenuDivider(height: 1),
                        widget.userData.data["is_teacher"] == true &&
                                _classData.data["student_finish"] == false &&
                                _classData.data["teacher_finish"] == false
                            ? studentSkippedClass()
                            : null,
                        PopupMenuDivider(height: 1),
                        finishClassMenu(),
                      ],
                onSelected: (value) {
                  switch (value) {
                    case "confirm_class":
                      showConfirmClassDialog(true);
                      break;
                    case "reject_class":
                      showConfirmClassDialog(false);
                      break;
                    case "absent":
                      showStudentAbsentDialog();
                      break;
                    case "cancel":
                      showCancelClassDialog();
                      break;
                    case "cant_cancel":
                      showCantCancelClassDialog();
                      break;
                    case "comment":
                      showAddDataDialog("Comentário", "comments");
                      break;
                    case "content":
                      showAddDataDialog("Conteúdo", "content");
                      break;
                    case "finish":
                      showFinishClassDialog();
                      break;
                    default:
                    //finishClass();
                  }
                },
              ),
            ],
            centerTitle: false,
            backgroundColor: Theme.of(context).backgroundColor,
            title: Text(
              "Detalhes",
              style: TextStyle(color: Colors.white60),
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
      body: _agendaDetailsBody(),
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

  List<PopupMenuEntry<Object>> _waitingMenu() {
    if (widget.userData.data["type"] == "s") {
      return [
        PopupMenuItem<String>(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.thumb_up,
                  color: Colors.green[400],
                ),
              ),
              Text(
                'Confirmar aula',
                style: TextStyle(
                  color: Colors.green[400],
                ),
              ),
            ],
          ),
          value: 'confirm_class',
        ),
        PopupMenuDivider(height: 1),
        PopupMenuItem<String>(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.thumb_down,
                  color: Colors.red[300],
                ),
              ),
              Text(
                'Não posso neste horário',
                style: TextStyle(
                  color: Colors.red[300],
                ),
              ),
            ],
          ),
          value: 'reject_class',
        ),
      ];
    } else {
      return [
        PopupMenuItem<String>(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.access_time,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Aguardando aluno',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          value: '-',
        ),
        PopupMenuDivider(height: 1),
        cancelClassMenu(),
      ];
    }
  }

  Future<void> getClassData() async {
    await Firestore.instance
        .collection("agenda")
        .document(widget.classData.documentID)
        .get()
        .then((document) {
      _classData = document;
    });
  }

  Widget cancelClassMenu() {
    return PopupMenuItem<String>(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.block,
              color: Colors.red[300],
            ),
          ),
          Text(
            'Cancelar Aula',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red[300],
            ),
          ),
        ],
      ),
      value: 'cancel',
    );
    if (_classData.data["teacher_finish"] == false &&
        _classData.data["student_finish"] == false &&
        DateTime.now()
            .add(Duration(hours: 1))
            .isBefore(_classData.data["date"].toDate())) {
      return PopupMenuItem<String>(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.block,
                color: Colors.red[300],
              ),
            ),
            Text(
              'Cancelar Aula',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red[300],
              ),
            ),
          ],
        ),
        value: 'cancel',
      );
    }

    return PopupMenuItem<String>(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.block,
              color: Colors.grey,
            ),
          ),
          Text(
            'Cancelar Aula',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        ],
      ),
      value: 'cant_cancel',
    );
  }

  Widget studentSkippedClass() {
    return PopupMenuItem<String>(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.directions_run,
              color: Colors.red[300],
            ),
          ),
          Text(
            'Aluno ausente',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red[300],
            ),
          ),
        ],
      ),
      value: 'absent',
    );
  }

  Widget finishClassMenu() {
    String userType =
        widget.userData.data["type"] == "s" ? "student" : "teacher";
    if (userType == "teacher") {
      if (_classData.data["teacher_finish"] == true &&
          _classData.data["student_finish"] == false) {
        return PopupMenuItem<String>(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.access_time,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Aguardando aluno',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          value: '-',
        );
      }
    } else {
      if (_classData.data["teacher_finish"] == false &&
          _classData.data["student_finish"] == true) {
        return PopupMenuItem<String>(
          child: Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(
                  Icons.access_time,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Aguardando professor',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          value: '-',
        );
      }
    }

    if (_classData.data["teacher_finish"] == true &&
        _classData.data["student_finish"] == true) {
      return PopupMenuItem<String>(
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.check,
                color: Colors.grey,
              ),
            ),
            Text(
              'Aula encerrada',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        value: '-',
      );
    }

    return PopupMenuItem<String>(
      child: Row(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(
              Icons.check_circle,
              color: Colors.green[800],
            ),
          ),
          Text(
            'Encerrar Aula',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green[800],
            ),
          ),
        ],
      ),
      value: 'finish',
    );
  }

  Widget _agendaDetailsBody() {
    return FutureBuilder<DocumentSnapshot>(
      future: Firestore.instance
          .collection("agenda")
          .document(widget.classData.documentID)
          .get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) return Text("Erro ao buscar aula");
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
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
              child: Center(
                  child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor),
              )),
            );
          default:
            if (snapshot.hasData) {
              //_classData = snapshot.data;
              return MediaQuery.removePadding(
                context: context,
                removeTop: true,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        //colors: [Colors.grey[850], Colors.grey[900]]),
                        colors: [
                          Theme.of(context).backgroundColor,
                          Color(0xFF191919)
                        ]),
                  ),
                  child: Column(
                    children: <Widget>[
                      _topPanel(),
                      _listContent(),
                      //CommentsPanel(),
                      //DetailsPanel(agendaID: "byLqqa4iteW4v05Uyslf"),
                    ],
                  ),
                ),
              );
            } else {
              return Container(
                padding: const EdgeInsets.all(18.0),
                width: MediaQuery.of(context).size.width,
                child: Text(
                  "Nenhum dado encontrado",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              );
            }
        }
      },
    );
  }

  Widget _topPanel() {
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
          //colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
        ),
        height: 169,
        child: Padding(
          padding: const EdgeInsets.only(top: 18.0, right: 18.0, left: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: AutoSizeText(
                      _classData["name"] == null ? "Aula" : _classData["name"],
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                    ),
                  ),
                  statusLabel(_classData["status"]),
                ],
              ),
              Container(
                height: 20,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      "Prof: ${_classData["teacher_name"]}",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, bottom: 10.0),
                child: Container(
                  height: 2,
                  width: MediaQuery.of(context).size.width * 0.99,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                //crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: FlatButton(
                      onPressed: () {
                        _listScrollController.animateTo(0,
                            duration: new Duration(seconds: 1),
                            curve: Curves.ease);
                      },
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.all(1.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Replace with a Row for horizontal icon + text
                        children: <Widget>[
                          Icon(
                            Icons.details,
                            color: Colors.white60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Detalhes",
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 350
                                          ? 8
                                          : 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    //color: Colors.grey[700],
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.grey[700],
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    //color: Colors.grey[700],
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: () {
                        _listScrollController.animateTo(
                            1 * MediaQuery.of(context).size.width,
                            duration: new Duration(seconds: 1),
                            curve: Curves.ease);
                      },
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.all(1.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        // Replace with a Row for horizontal icon + text
                        children: <Widget>[
                          Icon(
                            Icons.assignment,
                            color: Colors.white60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "Conteúdo",
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 350
                                          ? 8
                                          : 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    //color: Colors.grey[700],
                  ),
                  Container(
                    width: 1,
                    height: 20,
                    color: Colors.grey[700],
                  ),
                  Container(
                    width: 2,
                    height: 20,
                    //color: Colors.grey[700],
                  ),
                  Expanded(
                    child: FlatButton(
                      onPressed: () {
                        _listScrollController.animateTo(
                            2 * MediaQuery.of(context).size.width,
                            duration: new Duration(seconds: 1),
                            curve: Curves.ease);
                      },
                      color: Theme.of(context).primaryColor,
                      padding: EdgeInsets.all(1.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.message,
                            color: Colors.white60,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Text(
                              "( ${_classData["comments_count"] != null ? _classData["comments_count"] : 0} )",
                              style: TextStyle(
                                  color: Colors.white60,
                                  fontSize:
                                      MediaQuery.of(context).size.width < 350
                                          ? 12
                                          : 16),
                            ),
                          ),
                        ],
                      ),
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

  Widget _listContent() {
    return Expanded(
      child: ListView.builder(
        controller: _listScrollController,
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        itemExtent: MediaQuery.of(context).size.width,
        itemBuilder: (BuildContext context, int index) {
          switch (index) {
            case 0:
              return DetailsPanel(
                classData: _classData,
                userData: widget.userData,
              );
              break;
            case 1:
              return ContentPanel(
                classData: _classData,
                user: widget.userData,
              );
              break;
            case 2:
              return CommentsPanel(
                classData: _classData,
                user: widget.userData,
              );
              break;
            default:
              return DetailsPanel(
                classData: _classData,
                userData: widget.userData,
              );
          }
        },
      ),
    );
  }

  void cancelClass() {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text('Atenção!'),
        content: Text('Deseja realmente cancelar esta aula?'),
        actions: <Widget>[
          PlatformDialogAction(
            child: Text(
              "Sim",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              sendCancelStatus();
            },
          ),
          PlatformDialogAction(
            child: Text("Não"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Widget commentField() {
    return TextField(
      controller: _commentFieldController,
      autocorrect: false,
      autofocus: false,
      focusNode: _commentFieldFocus,
      keyboardType: TextInputType.multiline,
      maxLines: null,
      //textInputAction: TextInputAction.next,
      onSubmitted: (v) {
        //FocusScope.of(context).requestFocus(_lastNameFocus);
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.all(8.0),
        border: OutlineInputBorder(
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(color: Colors.grey),
        ),
        hintText: "Digite aqui...",
        filled: true,
        fillColor: Colors.white,
      ),
      cursorColor: Colors.black,
      showCursor: true,
    );
  }

  void showAddDataDialog(String name, String type) {
    //FocusScope.of(context).requestFocus(_commentFieldFocus);
    Alert(
        context: context,
        title: name,
        content: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: commentField(),
        ),
        buttons: [
          DialogButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancelar",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ),
          DialogButton(
            color: Theme.of(context).primaryColor,
            onPressed: () {
              type == "comments" ? sendComment() : sendContent();
              _commentFieldController.text = "";
              _contentFieldController.text = "";
              //Navigator.pop(context);
            },
            child: Text(
              "Enviar",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          )
        ]).show();
  }

  void showCancelClassDialog() {
    Alert(
      context: context,
      type: AlertType.error,
      title: "CANCELAR AULA",
      desc: "Você deseja realmente cancelar esta aula?",
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
          onPressed: () {
            sendCancelStatus();
          },
          width: 120,
        )
      ],
    ).show();
  }

  void showCantCancelClassDialog() {
    Alert(
      context: context,
      type: AlertType.error,
      title: "CANCELAR AULA",
      desc:
          "Desculpa, não é possível cancelar a aula no momento. Por favor, entre em contato com a sua escola. Obrigado!",
      buttons: [
        DialogButton(
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

  void showConfirmClassDialog(bool confirm) {
    Alert(
      context: context,
      type: AlertType.info,
      title: "CONFIRMAÇÃO DE AULA",
      desc: confirm
          ? "Você deseja realmente confirmar o agendamento desta aula?"
          : "Deseja realmente informar que não estará disponível para esta aula?",
      buttons: [
        DialogButton(
          child: Text(
            "CANCELAR",
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
          onPressed: () => sendConfirmStatus(confirm),
          width: 120,
        )
      ],
    ).show();
  }

  void sendConfirmStatus(bool confirm) async {
    Navigator.pop(context);
    Alert(
      context: context,
      type: AlertType.info,
      title: "AGUARDE",
      desc: "Enviando dados.",
      buttons: [],
    ).show();

    String messageFromAPI = "";

    if (widget.classData.data["class_id"].toString != "0") {
      int unitID = getUnitID(widget.classData.data["unit_name"]);
      messageFromAPI = await sendCancelClassToAPI(
          unitID: unitID,
          userAPIKey: widget.userData.data["unity_key_$unitID"],
          aulaID: widget.classData.data["class_id"]);
    }

    Navigator.pop(context);

    if (messageFromAPI == "ok") {
// REMOVENDO NOTIFICAÇÕES
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .collection("notifications")
          .where("type", isEqualTo: "class")
          .where("reference", isEqualTo: widget.classData.documentID)
          .getDocuments()
          .then((notifications) {
        notifications.documents.forEach((notification) {
          Firestore.instance
              .collection("users")
              .document(_user.uid)
              .collection("notifications")
              .document(notification.documentID)
              .delete();
        });
      });

      //NOTIFICANDO PROFESSOR
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .collection("notifications")
          .add({
        "date": DateTime.now(),
        "title": confirm ? "Confirmação de aula" : "Aula rejeitada",
        "message":
            "${widget.userData.data["display_name"]} ${confirm ? "confirmou" : "rejeitou"} uma aula marcada.",
        "reference": widget.classData.documentID,
        "type": "class_${confirm ? "confirm" : "reject"}"
      }).then((notification) {
        Firestore.instance
            .collection("users")
            .document(widget.classData.data["teacher_id"])
            .collection("notification_tokens")
            .getDocuments()
            .then((notificationTokens) {
          List<String> tokens = [];
          notificationTokens.documents.forEach((doc) {
            tokens.add(doc.data["token"].toString());
          });
          Firestore.instance
              .collection("users")
              .document(_user.uid)
              .collection("activities")
              .add({
            "activity": confirm
                ? "Confirmou presença em uma aula"
                : "Rejeitou uma aula.",
            "title": confirm ? "Aula confirmada." : "Aula rejeitada",
            "type": confirm ? "class-confirm" : "class-rejected",
            "date": DateTime.now()
          });
          FirebaseCloudMessage.send(
              confirm ? "Confirmação de aula" : "Aula rejeitada",
              "${widget.userData.data["display_name"]} ${confirm ? "confirmou" : "rejeitou"} uma aula marcada.",
              tokens);
        });
      });

      // ATUALIZANDO AGENDA
      Firestore.instance
          .collection("users")
          .document(_user.uid)
          .get()
          .then((user) {
        String userType = user.data["type"] == "s" ? "student" : "teacher";
        Firestore.instance
            .collection("agenda")
            .document(widget.classData.documentID)
            .setData({
          userType + "_finish": confirm ? false : true,
          "status": confirm
              ? "Prevista"
              : "Cancelada pelo " +
                  (userType == "student" ? "aluno" : "professor"),
        }, merge: true).then((v) {
          getClassData();
          setState(() {
            _isLoading = false;
          });
          Navigator.pop(context);
          Alert(
            context: context,
            type: AlertType.success,
            title: confirm ? "AULA AGENDADA" : "AULA REJEITADA",
            desc: confirm
                ? "Sua aula foi agendada com sucesso."
                : "Você marcou a aula como rejeitada. Aguarde que seu professor marcar outra data.",
            buttons: [
              DialogButton(
                color: Theme.of(context).primaryColor,
                child: Text(
                  "OK",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                onPressed: () => Navigator.pop(context),
                width: 120,
              )
            ],
          ).show();
        });
      });
    } else {
      Alert(
        context: context,
        type: AlertType.error,
        title: "ERRO",
        desc: messageFromAPI,
        buttons: [
          DialogButton(
            color: Theme.of(context).primaryColor,
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    }
  }

  void showStudentAbsentDialog() {
    Alert(
      context: context,
      type: AlertType.error,
      title: "ENCERRAR AULA",
      desc:
          "Você deseja realmente encerrar esta aula informando que o aluno não compareceu?",
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
          onPressed: () => sendAbsentStatus(),
          width: 120,
        )
      ],
    ).show();
  }

  void showFinishClassDialog() {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "ENCERRAR AULA",
      desc: "Você deseja realmente encerrar esta aula?",
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
          child: _isLoading
              ? Text(
                  "AGUARDE...",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                )
              : Text(
                  "SIM",
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
          onPressed: () => sendFinishStatus(),
          width: 120,
        )
      ],
    ).show();
  }

  // void finishClass() {
  //   showPlatformDialog(
  //     context: context,
  //     builder: (_) => PlatformAlertDialog(
  //       title: Text('Atenção!'),
  //       content: Text('Deseja realmente encerrar a aula?'),
  //       actions: <Widget>[
  //         PlatformDialogAction(
  //           child: Text(
  //             "Sim",
  //             style: TextStyle(
  //               color: Colors.green[800],
  //               fontWeight: FontWeight.bold,
  //             ),
  //           ),
  //           onPressed: () {
  //             sendFinishStatus();
  //           },
  //         ),
  //         PlatformDialogAction(
  //           child: Text("Cancelar"),
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //         )
  //       ],
  //     ),
  //   );
  // }

  void sendFinishStatus() {
    String status = _classData.data["status"];

    if (widget.userData.data["type"] == "s" &&
        _classData.data["teacher_finish"] == true) {
      status = "concluído";
    }

    if (widget.userData.data["is_teacher"] == true &&
        _classData.data["student_finish"] == true) {
      status = "concluído";
    }

    Navigator.pop(context);
    Alert(
      context: context,
      type: AlertType.info,
      title: "AGUARDE",
      desc: "Sua aula está sendo encerrada.",
      buttons: [],
    ).show();
    Firestore.instance
        .collection("users")
        .document(_user.uid)
        .get()
        .then((user) {
      String userType = user.data["type"] == "s" ? "student" : "teacher";
      Firestore.instance
          .collection("agenda")
          .document(widget.classData.documentID)
          .setData({
        userType + "_finish": true,
        "status": status,
      }, merge: true).then((v) {
        getClassData();
        setState(() {
          _isLoading = false;
        });
        Navigator.pop(context);
        Alert(
          context: context,
          type: AlertType.success,
          title: "AULA ENCERRADA",
          desc: "Sua aula foi marcada como encerrada com sucesso.",
          buttons: [
            DialogButton(
              color: Theme.of(context).primaryColor,
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
        // showPlatformDialog(
        //   context: context,
        //   builder: (_) => PlatformAlertDialog(
        //     title: Text('Atenção!'),
        //     content: Text('Aula marcada como encerrada'),
        //     actions: <Widget>[
        //       PlatformDialogAction(
        //         child: Text("OK"),
        //         onPressed: () {
        //           Navigator.pop(context);
        //         },
        //       )
        //     ],
        //   ),
        // );
      });
    });
    // Firestore.instance
    //     .collection("agenda")
    //     .document(_classData.documentID).setData({})
    //     .collection("contents")
    //     .add({
    //   "user_id": widget.user.uid,
    //   "name": widget.user.displayName,
    //   "text": _contentFieldController.text,
    //   "comment_date": DateTime.now()
    // }).then((value) {
    //   _contentFieldController.text = "";
    //   setState(() {});
    // });
  }

  Future<String> sendCancelClassToAPI(
      {@required int unitID,
      @required String userAPIKey,
      @required String aulaID}) async {
    final response = await http.get(
        'https://extranet.academiadorock.com.br/app/alterar_statusaula_aluno.php?uni=2&chave=be6340bb546&aula=50882&status=310');
    print(
        'https://extranet.academiadorock.com.br/app/alterar_statusaula_aluno.php?uni=$unitID&chave=$userAPIKey&aula=$aulaID&status=310');
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.

      dynamic result = json
          .decode("[" + response.body.replaceFirst('}]}{', '}]},{', 0) + "]");
      List<dynamic> listAgenda = result[0]["aula"];

      if (listAgenda[0]["erro"] != null) {
        return listAgenda[0]["erro"].toString();
      }

      return "ok";
    } else {
      return "Não foi possível cancelar sua aula. Por favor, entre em contato com sua escola!";
    }
  }

  void sendCancelStatus() async {
    Navigator.pop(context);
    Alert(
      context: context,
      type: AlertType.info,
      title: "AGUARDE",
      desc: "Aguarde um instante enquanto cancelamos sua aula.",
      buttons: [],
    ).show();
    String messageFromAPI = "";
    if (widget.classData.data["class_id"].toString != "0") {
      int unitID = getUnitID(widget.classData.data["unit_name"]);
      messageFromAPI = await sendCancelClassToAPI(
          unitID: unitID,
          userAPIKey: widget.userData.data["unity_key_$unitID"],
          aulaID: widget.classData.data["class_id"]);
    }
    if (messageFromAPI == "ok") {
      await Firestore.instance.collection("users").document(_user.uid).get();
      await Firestore.instance
          .collection("agenda")
          .document(widget.classData.documentID)
          .setData({
        "status": "cancelado",
        "student_finish": true,
        "teacher_finish": true,
      }, merge: true);

      await getClassData();
      Alert(
        context: context,
        type: AlertType.success,
        title: "AULA CANCELADA",
        desc:
            "Sua aula foi cancelada com sucesso. Por favor, entre em contato com a sua escola para remarcar um novo horário.",
        buttons: [
          DialogButton(
            color: Theme.of(context).primaryColor,
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    } else {
      Alert(
        context: context,
        type: AlertType.error,
        title: "ERRO",
        desc: messageFromAPI,
        buttons: [
          DialogButton(
            color: Theme.of(context).primaryColor,
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    }

    setState(() {
      _isLoading = false;
    });
    Navigator.pop(context);
  }

  void sendAbsentStatus() {
    Navigator.pop(context);
    Alert(
      context: context,
      type: AlertType.info,
      title: "AGUARDE",
      desc: "Alterando status da aula.",
      buttons: [],
    ).show();
    Firestore.instance
        .collection("agenda")
        .document(widget.classData.documentID)
        .setData(
            {"student_finish": true, "teacher_finish": true, "status": "Falta"},
            merge: true).then((v) async {
      setState(() {
        _isLoading = false;
      });
      await getClassData();
      Navigator.pop(context);
      Alert(
        context: context,
        type: AlertType.success,
        title: "AULA ENCERRADA",
        desc: "Aula encerrada devido a ausência do aluno.",
        buttons: [
          DialogButton(
            color: Theme.of(context).primaryColor,
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
    });
  }

  void sendComment() {
    String comment = _commentFieldController.text;
    Navigator.pop(context);
    Alert(
      context: context,
      type: AlertType.info,
      title: "AGUARDE",
      desc: "Aguarde enquantos estamos salvando o seu comentário.",
      buttons: [],
    ).show();
    Firestore.instance
        .collection("agenda")
        .document(widget.classData.documentID)
        .collection("comments")
        .add({
      "user_id": _user.uid,
      "name": widget.userData.data["display_name"],
      "text": _commentFieldController.text,
      "comment_date": DateTime.now()
    }).then((value) {
      Firestore.instance
          .collection("agenda")
          .document(widget.classData.documentID)
          .setData(
        {
          "comments_count": FieldValue.increment(1),
        },
        merge: true,
      ).then((value) {
        _classData["students_id"].forEach((studentID) {
          Firestore.instance
              .collection("users")
              .document(studentID)
              .collection("notifications")
              .add({
            "date": DateTime.now(),
            "title": "Novo comentário",
            "message": comment,
            "reference": widget.classData.documentID,
            "type": "comment"
          }).then((notification) {
            Firestore.instance
                .collection("users")
                .document(studentID)
                .collection("notification_tokens")
                .getDocuments()
                .then((notificationTokens) {
              List<String> tokens = [];
              notificationTokens.documents.forEach((doc) {
                tokens.add(doc.data["token"].toString());
              });
              Firestore.instance
                  .collection("users")
                  .document(widget.userData.documentID)
                  .collection("activities")
                  .add({
                "activity": comment,
                "title": "Adicionou um comentário a uma aula.",
                "type": "class-comment",
                "date": DateTime.now()
              }).then((onValue) {
                FirebaseCloudMessage.send(
                  "Novo comentário",
                  comment,
                  tokens,
                );
              });
            });
          });
        });
      }).catchError((error) {
        Navigator.pop(context);
        Alert(
          context: context,
          type: AlertType.error,
          title: "Erro",
          desc:
              "Erro ao enviar seu comentário. Por favor, tente novamente mais tarde.",
          buttons: [
            DialogButton(
              color: Theme.of(context).primaryColor,
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
        setState(() {});
      }).whenComplete(() {
        _commentFieldController.text = "";
        Navigator.pop(context);
        Alert(
          context: context,
          type: AlertType.success,
          title: "SUCESSO",
          desc: "Seu comentário foi adicionado com sucesso.",
          buttons: [
            DialogButton(
              color: Theme.of(context).primaryColor,
              child: Text(
                "OK",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
              onPressed: () => Navigator.pop(context),
              width: 120,
            )
          ],
        ).show();
        setState(() {});
      });
    });
  }

  void sendContent() {
    Navigator.pop(context);
    Alert(
      context: context,
      type: AlertType.info,
      title: "AGUARDE",
      desc:
          "Aguarde enquantos estamos salvando os dados do conteúdo informado.",
      buttons: [],
    ).show();
    Firestore.instance
        .collection("agenda")
        .document(_classData.documentID)
        .collection("contents")
        .add({
      "user_id": _user.uid,
      "name": _user.displayName,
      "text": _commentFieldController.text,
      "comment_date": DateTime.now()
    }).then((value) {
      _classData.data["students_id"].forEach((studentID) {
        Firestore.instance
            .collection("users")
            .document(studentID)
            .collection("notifications")
            .add({
          "date": DateTime.now(),
          "title": "Novo conteúdo",
          "message": _commentFieldController.text,
          "reference": widget.classData.documentID,
          "type": "content"
        }).then((notification) {
          Firestore.instance
              .collection("users")
              .document(studentID)
              .collection("notification_tokens")
              .getDocuments()
              .then((notificationTokens) {
            List<String> tokens = [];
            notificationTokens.documents.forEach((doc) {
              tokens.add(doc.data["token"].toString());
            });
            Firestore.instance
                .collection("users")
                .document(_user.uid)
                .collection("activities")
                .add({
              "activity": _commentFieldController.text,
              "title": "Adicionou um conteúdo a uma aula.",
              "type": "class-content",
              "date": DateTime.now()
            });
            FirebaseCloudMessage.send(
              "Novo conteúdo",
              _commentFieldController.text,
              tokens,
            );
          });
        });
      });
    }).whenComplete(() {
      _commentFieldController.text = "";
      Navigator.pop(context);
      Alert(
        context: context,
        type: AlertType.success,
        title: "SUCESSO",
        desc: "Seu conteúdo foi adicionado com sucesso.",
        buttons: [
          DialogButton(
            color: Theme.of(context).primaryColor,
            child: Text(
              "OK",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            onPressed: () => Navigator.pop(context),
            width: 120,
          )
        ],
      ).show();
      setState(() {});
    });
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
      height: 18,
      decoration:
          BoxDecoration(borderRadius: BorderRadius.circular(2), color: color),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 8.0, right: 8.0),
          child: Text(
            label,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
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
}
