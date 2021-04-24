import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailFieldController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isButtonDisabled = true;

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _emailFieldController.addListener(() {
      setState(() {
        if (_emailFieldController.text.length > 0) {
          _isButtonDisabled = false;
        } else {
          _isButtonDisabled = true;
        }
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailFieldController.dispose();
    super.dispose();
  }

  void requestRecoverPassword(BuildContext context) {
    _auth
        .sendPasswordResetEmail(email: _emailFieldController.text)
        .then((response) {
      showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
          title: Text('Viva!'),
          content: Text(
              'Enviamos um e-mail para você com as instruções para gerar uma nova senha!'),
          actions: <Widget>[
            PlatformDialogAction(
              child: Text("ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
      _emailFieldController.text = "";
    }).catchError((error) {
      showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
          title: Text('Oops!'),
          content: Text(
              'Alguma coisa deu errado! Tem certeza que seu e-mail está correto?'),
          actions: <Widget>[
            PlatformDialogAction(
              child: Text("ok"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "Recuperar senha",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme:
              IconThemeData(color: Theme.of(context).unselectedWidgetColor),
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                "Esqueceu sua senha? Não tem o problema, nós estamos aqui para te ajudar a recuperá-la! Basta digitar o seu email e clicar no botão 'Recuperar senha' e voilà! Você recebera uma nova senha no seu e-mail.",
                style: TextStyle(color: Colors.black),
                textAlign: TextAlign.center,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  width: double.infinity,
                  height: 40,
                  child: TextField(
                    controller: _emailFieldController,
                    autocorrect: false,
                    autofocus: false,
                    showCursor: true,
                    cursorColor: Colors.black,
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                        hintText: "meu@email.com",
                        filled: false,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Theme.of(context).unselectedWidgetColor),
                            borderRadius: BorderRadius.circular(10))),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Container(
                  width: double.infinity,
                  height: 40,
                  child: RaisedButton(
                    elevation: 0,
                    color: _isButtonDisabled
                        ? Theme.of(context).unselectedWidgetColor
                        : Theme.of(context).primaryColor,
                    child: Text(
                      "Recuperar Senha",
                      style: TextStyle(color: Colors.white),
                    ),
                    shape: RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0)),
                    onPressed: () {
                      if (!_isButtonDisabled) {
                        requestRecoverPassword(context);
                      }
                    },
                  ),
                ),
              )
            ],
          ),
        ));
  }
}
