import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class CreateAccountScreen extends StatefulWidget {
  _CreateAccountScreenState createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _firstNameFieldController = TextEditingController();
  final _lastNameFieldController = TextEditingController();
  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isButtonDisabled = true;
  final _lastNameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _createAccountFocus = FocusNode();
  bool _isPasswordObscure = true;

  TapGestureRecognizer _useTermsTap;
  TapGestureRecognizer _privacyPolicyTap;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _firstNameFieldController.addListener(validateFields);
    _lastNameFieldController.addListener(validateFields);
    _emailFieldController.addListener(validateFields);
    _passwordFieldController.addListener(validateFields);
    _useTermsTap = TapGestureRecognizer()..onTap = loadUseTerms;
    _privacyPolicyTap = TapGestureRecognizer()..onTap = loadPrivacyPolicy;
  }

  void loadUseTerms() {
    // TODO: Fazer o carregamento
    print("Fazer o carregamento dos termos de uso!");
  }

  void loadPrivacyPolicy() {
    // TODO: Fazer o carregamento
    print("Fazer o carregamento da politica de privacidade!");
  }

  void validateFields() {
    setState(() {
      if (_firstNameFieldController.text.isNotEmpty &&
          _lastNameFieldController.text.isNotEmpty &&
          _emailFieldController.text.isNotEmpty &&
          _emailFieldController.text.contains("@", 0) &&
          !_emailFieldController.text.contains(" ", 0) &&
          _passwordFieldController.text.length >= 6) {
        _isButtonDisabled = false;
      } else {
        _isButtonDisabled = true;
      }
    });
  }

  @override
  void dispose() {
    _firstNameFieldController.dispose();
    _lastNameFieldController.dispose();
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    _useTermsTap.dispose();
    _privacyPolicyTap.dispose();
    super.dispose();
  }

  void createNewAccount(BuildContext context) {
    _auth
        .createUserWithEmailAndPassword(
            email: _emailFieldController.text,
            password: _passwordFieldController.text)
        .then((result) {
      UserUpdateInfo userInfo = UserUpdateInfo();
      userInfo.displayName =
          "${_firstNameFieldController.text} ${_lastNameFieldController.text}";
      result.user.updateProfile(userInfo).then((value) {
        Firestore.instance
            .collection('users')
            .document(result.user.uid)
            .setData({
          "display_name": userInfo.displayName,
          "email": result.user.email,
          "is_active": true,
          "is_teacher": false,
          "type": "s",
          "credits": 0,
        }).then((v) {
          Navigator.pop(context, true);
        });
      });
    }).catchError((error) {
      switch (error.code) {
        case "ERROR_INVALID_EMAIL":
          return showAlertError(context, "Email inválido!",
              "Verifique se o email foi digitado corretamente.");
        case "ERROR_EMAIL_ALREADY_IN_USE":
          return showAlertError(context, "Email inválido!",
              "Já existe uma conta cadastrada com esse email!");
        case "ERROR_WEAK_PASSWORD":
          return showAlertError(context, "Senha muito fraca!",
              "Ah, eu sei que você consegue criar uma senha melhor que essa!");
        default:
          return showAlertError(context, "Oops",
              "Não foi possível criar a conta, veja se os campos estão preenchidos corretamente!");
      }
    });
  }

  void showAlertError(BuildContext context, String title, String content) {
    showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: <Widget>[
                PlatformDialogAction(
                  child: Text("ok"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            "Cadastre-se",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          iconTheme:
              IconThemeData(color: Theme.of(context).unselectedWidgetColor),
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.only(left: 25, right: 25, top: 50, bottom: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              firstNameField(),
              lastNameField(),
              emailField(),
              passwordField(),
              Align(
                alignment: Alignment.topLeft,
                child: Text(
                  "mínimo de 6 caracteres",
                  style:
                      TextStyle(color: Theme.of(context).unselectedWidgetColor),
                ),
              ),
              createAccountAndCheckPolicies()
            ],
          ),
        ));
  }

  Widget firstNameField() {
    return TextField(
      controller: _firstNameFieldController,
      autocorrect: false,
      autofocus: true,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onSubmitted: (v) {
        FocusScope.of(context).requestFocus(_lastNameFocus);
      },
      decoration: InputDecoration(hintText: "Nome*"),
      cursorColor: Colors.black,
      showCursor: true,
    );
  }

  Widget lastNameField() {
    return TextField(
      controller: _lastNameFieldController,
      autocorrect: false,
      autofocus: false,
      focusNode: _lastNameFocus,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.next,
      onSubmitted: (v) {
        FocusScope.of(context).requestFocus(_emailFocus);
      },
      decoration: InputDecoration(hintText: "Sobrenome*"),
      cursorColor: Colors.black,
      showCursor: true,
    );
  }

  Widget emailField() {
    return TextField(
      controller: _emailFieldController,
      autocorrect: false,
      autofocus: false,
      focusNode: _emailFocus,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      onSubmitted: (v) {
        if (!_emailFieldController.text.contains("@", 0) ||
            _emailFieldController.text.contains(" ", 0)) {
          showAlertError(
              context, "Email inválido!", "O campo de Email é obrigatório.");
          FocusScope.of(context).requestFocus(_emailFocus);
        } else {
          FocusScope.of(context).requestFocus(_passwordFocus);
        }
      },
      decoration: InputDecoration(hintText: "Email*"),
      cursorColor: Colors.black,
      showCursor: true,
    );
  }

  Widget passwordField() {
    return Padding(
      padding: const EdgeInsets.only(top: 15),
      child: Stack(
        children: <Widget>[
          TextField(
            controller: _passwordFieldController,
            autocorrect: false,
            autofocus: false,
            obscureText: _isPasswordObscure,
            focusNode: _passwordFocus,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onSubmitted: (v) {
              FocusScope.of(context).requestFocus(_createAccountFocus);
            },
            decoration: InputDecoration(hintText: "Senha*"),
            cursorColor: Colors.black,
            showCursor: true,
            maxLength: 18,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              alignment: Alignment.centerRight,
              icon: Icon(
                  _isPasswordObscure ? Icons.visibility_off : Icons.visibility),
              color: Theme.of(context).unselectedWidgetColor,
              onPressed: () {
                setState(() {
                  _isPasswordObscure = !_isPasswordObscure;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget createAccountAndCheckPolicies() {
    return Expanded(
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            RaisedButton(
              elevation: 0,
              color: _isButtonDisabled
                  ? Theme.of(context).unselectedWidgetColor
                  : Theme.of(context).primaryColor,
              child: Text(
                "Criar conta",
                style: TextStyle(color: Colors.white),
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              onPressed: () {
                if (!_isButtonDisabled) {
                  createNewAccount(context);
                }
              },
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(children: [
                  TextSpan(
                      text: "Ao se cadastrar, você aceita os ",
                      style: TextStyle(
                          color: Theme.of(context).unselectedWidgetColor)),
                  TextSpan(
                    text: "Termos de Uso",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                    recognizer: _useTermsTap,
                  ),
                  TextSpan(
                      text: " e ",
                      style: TextStyle(
                          color: Theme.of(context).unselectedWidgetColor)),
                  TextSpan(
                    text: "Política de Privacidade",
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold),
                    recognizer: _privacyPolicyTap,
                  ),
                  TextSpan(
                      text: ", além de receber novidades do Fada.",
                      style: TextStyle(
                          color: Theme.of(context).unselectedWidgetColor)),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
