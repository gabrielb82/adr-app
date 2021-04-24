import 'dart:async';
import 'dart:io';
import 'package:academia_do_rock_app/src/login/create_account_screen.dart';
import 'package:academia_do_rock_app/src/main_tab/main_tab_screen.dart';
import 'package:academia_do_rock_app/src/services/firebase_cloud_messaging.dart';
import 'package:academia_do_rock_app/src/transitions/fade_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
//import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'forgot_password_screen.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  double _elementsOpacity = 0;
  double _elementsElevation = 10;
  double _elementsHeight = 40;
  ActorAnimation flow;
  ActorAnimation shrink;
  ActorAnimation expand;
  double timer = 0;

  double _animationPaddingPosition = 50;
  bool _hasLoaded = false;
  double _exploreButtonFieldOpacityValue = 0;
  bool _exploreButtonEnabled = false;
  double _emailFieldPaddingPosition = 30;
  double _emailFieldOpacityValue = 0;
  double _passwordFieldPaddingPosition = 30;
  double _passwordFieldOpacityValue = 0;
  double _submitButtonPaddingPosition = 30;
  double _submitButtonOpacityValue = 0;
  bool _submitButtonEnabled = true;
  double _separatorLabelPaddingPosition = 10;
  double _separatorLabelOpacityValue = 0;
  double _socialLoginPaddingPosition = 10;
  double _socialLoginOpacityValue = 0;

  double _bottomMenuItensOpacityValue = 0;

  int _inputFieldsPaddingAnimationDuration = 1000;
  int _inputFieldsOpacityAnimationDuration = 500;

  bool _isWaiting = true;

  final _focus = FocusNode();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email'],
  );

  //final facebookLogin = FacebookLogin();

  final storage = new FlutterSecureStorage();

  final _emailFieldController = TextEditingController();
  final _passwordFieldController = TextEditingController();

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.initState();
    animateInitialState();
  }

  void animateInitialState() {
    if (!_hasLoaded) {
      setState(() {
        _elementsOpacity = 1;
        _animationPaddingPosition = 0;
        Timer(const Duration(milliseconds: 1000), () {
          setState(() {
            _emailFieldPaddingPosition = 30;
            _emailFieldOpacityValue = 1;
          });
        });
        Timer(const Duration(milliseconds: 1200), () {
          setState(() {
            _passwordFieldPaddingPosition = 15;
            _passwordFieldOpacityValue = 1;
          });
        });
        Timer(const Duration(milliseconds: 1400), () {
          setState(() {
            _submitButtonPaddingPosition = 30;
            _submitButtonOpacityValue = 1;
          });
        });
        Timer(const Duration(milliseconds: 1500), () {
          setState(() {
            _separatorLabelPaddingPosition = 0;
            _separatorLabelOpacityValue = 1;
            _socialLoginPaddingPosition = 0;
            _socialLoginOpacityValue = 1;
          });
        });
        Timer(const Duration(milliseconds: 2000), () {
          setState(() {
            _exploreButtonFieldOpacityValue = 1;
            _exploreButtonEnabled = true;
            _bottomMenuItensOpacityValue = 1;
          });
        });
      });
      _hasLoaded = true;
      _isWaiting = false;
    }
  }

  @override
  void dispose() {
    _emailFieldController.dispose();
    _passwordFieldController.dispose();
    super.dispose();
  }

  void startLoginAnimation(bool expand) {
    _elementsOpacity = 0;
    _emailFieldOpacityValue = 0;
    _passwordFieldOpacityValue = 0;
    _submitButtonOpacityValue = 0;
    _separatorLabelOpacityValue = 0;
    _socialLoginOpacityValue = 0;
    _exploreButtonFieldOpacityValue = 0;
    _bottomMenuItensOpacityValue = 0;
  }

  void customLogin(BuildContext context) async {
    startLoginAnimation(true);
    Timer(const Duration(milliseconds: 1000), () {
      _auth.signInAnonymously().then((user) {
        FirebaseCloudMessage.saveNotificationToken(user.user.uid).then((v) {
          pushMainTabScreen(context);
        });
      }).catchError((e) {
        showPlatformDialog(
          context: context,
          builder: (_) => PlatformAlertDialog(
            title: Text('Oops!'),
            content: Text('Alguma coisa deu errado!'),
            actions: <Widget>[
              PlatformDialogAction(
                child: Text("ok"),
                onPressed: () {
                  _isWaiting = false;
                  _hasLoaded = false;
                  Navigator.pop(context);
                  animateInitialState();
                },
              ),
            ],
          ),
        );
      });
    });
  }

  void loginUsingEmailAndPassword(BuildContext context) async {
    startLoginAnimation(true);
    Timer(const Duration(milliseconds: 1000), () {
      _auth
          .signInWithEmailAndPassword(
        email: _emailFieldController.text,
        password: _passwordFieldController.text,
      )
          .then((result) {
        storage.write(key: "password", value: _passwordFieldController.text);
        storage.write(key: "email", value: _emailFieldController.text);

        FirebaseCloudMessage.saveNotificationToken(result.user.uid);

        pushMainTabScreen(context);
      }).catchError((e) {
        failToLogin(context);
      }).whenComplete(() {
        _submitButtonEnabled = true;
      });
    });
  }

  // void loginUsingFacebook(BuildContext context) async {
  //   startLoginAnimation(true);
  //   setState(() {
  //     _isWaiting = true;
  //   });
  //   Timer(const Duration(milliseconds: 1000), () {
  //     facebookLogin.logIn(['email']).then((result) {
  //       //final token = result.accessToken.token;
  //       switch (result.status) {
  //         case FacebookLoginStatus.loggedIn:
  //           //FacebookAccessToken facebookAccessToken = result.accessToken;
  //           final AuthCredential credential =
  //               FacebookAuthProvider.getCredential(
  //                   accessToken: result.accessToken.token);
  //           _auth.signInWithCredential(credential).then((profile) async {
  //             print(profile);
  //             storage.write(
  //                 key: "facebookAccessToken", value: result.accessToken.token);
  //             Firestore.instance
  //                 .collection("users")
  //                 .document(profile.user.uid)
  //                 .setData(
  //               {
  //                 "display_name": profile.user.displayName,
  //                 "email": profile.user.email,
  //                 "is_active": true,
  //                 "is_teacher": false,
  //                 "type": "s",
  //               },
  //               merge: true,
  //             ).then((value) async {
  //               // *************************************************************
  //               // Commented section for uploading profile picture from Facebook
  //               // *************************************************************
  //               // var response =
  //               //     await http.get('${profile.user.photoUrl}?type=large');
  //               // String dir = (await getApplicationDocumentsDirectory()).path;

  //               // StorageReference storageReference = FirebaseStorage.instance
  //               //     .ref()
  //               //     .child("profile/${profile.user.uid}/avatar.jpg");

  //               // File file = new File('$dir/avatar.jpg');
  //               // await file.writeAsBytes(response.bodyBytes);

  //               // StorageUploadTask uploadTask = storageReference.putFile(file);
  //               // await uploadTask.onComplete;
  //               // *************************************************************
  //               // *************************************************************

  //               pushMainTabScreen(context);
  //             });
  //           }).catchError((error) {
  //             customLogin(context);
  //           });
  //           break;
  //         case FacebookLoginStatus.cancelledByUser:
  //           _isWaiting = false;
  //           _hasLoaded = false;
  //           animateInitialState();
  //           break;
  //         case FacebookLoginStatus.error:
  //           _isWaiting = false;
  //           _hasLoaded = false;
  //           animateInitialState();
  //           break;
  //       }
  //     });

  //     //   _googleSignIn.signIn().then((googleUser) {
  //     //     googleUser.authentication.then((googleAuth) {
  //     //       _auth
  //     //           .signInWithCredential(GoogleAuthProvider.getCredential(
  //     //         idToken: googleAuth.idToken,
  //     //         accessToken: googleAuth.accessToken,
  //     //       ))
  //     //           .then((result) {
  //     //         storage.write(key: "googleIdToken", value: googleAuth.idToken);
  //     //         storage.write(
  //     //             key: "googleAccessToken", value: googleAuth.accessToken);
  //     //         pushMainTabScreen(context);
  //     //       }).catchError((e) {
  //     //         failToLogin(context);
  //     //       });
  //     //     }).catchError((onError) {
  //     //       _isWaiting = false;
  //     //       _hasLoaded = false;
  //     //       animateInitialState();
  //     //     });
  //     //   }).catchError((onError) {
  //     //     _isWaiting = false;
  //     //     _hasLoaded = false;
  //     //     animateInitialState();
  //     //   });
  //   });
  // }

  void loginUsingGooglePlus(BuildContext context) async {
    startLoginAnimation(true);
    setState(() {
      _isWaiting = true;
    });

    Timer(const Duration(milliseconds: 1000), () {
      _googleSignIn.signIn().then((googleUser) {
        googleUser.authentication.then((googleAuth) {
          _auth
              .signInWithCredential(GoogleAuthProvider.getCredential(
            idToken: googleAuth.idToken,
            accessToken: googleAuth.accessToken,
          ))
              .then((result) {
            storage.write(key: "googleIdToken", value: googleAuth.idToken);
            storage.write(
                key: "googleAccessToken", value: googleAuth.accessToken);
            Firestore.instance
                .collection("users")
                .document(result.user.uid)
                .setData(
              {
                "display_name": result.user.displayName,
                "email": result.user.email,
                "is_active": true,
                "is_teacher": false,
                "type": "s",
              },
              merge: true,
            ).then((onValue) {
              pushMainTabScreen(context);
            });
          }).catchError((e) {
            failToLogin(context);
          });
        }).catchError((onError) {
          _isWaiting = false;
          _hasLoaded = false;
          animateInitialState();
        });
      }).catchError((onError) {
        _isWaiting = false;
        _hasLoaded = false;
        animateInitialState();
      });
    });
  }

  void failToLogin(BuildContext context) {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text('Oops!'),
        content: Text('Seu usuário ou senha estão errados!'),
        actions: <Widget>[
          PlatformDialogAction(
            child: Text("ok"),
            onPressed: () {
              _isWaiting = false;
              _hasLoaded = false;
              Navigator.pop(context);
              animateInitialState();
            },
          ),
        ],
      ),
    );
  }

  void pushMainTabScreen(BuildContext context) async {
    Navigator.push(context, FadeRoute(page: MainTabScreen())).then((route) {
      setInitialFieldsState();
    });
  }

  void pushForgotPasswordScreen(BuildContext context) async {
    startLoginAnimation(false);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
    ).whenComplete(() {
      setInitialFieldsState();
      animateInitialState();
    });
  }

  void pushCreateAccountScreen(BuildContext context) async {
    startLoginAnimation(false);
    var accountCreated = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateAccountScreen()),
    ).whenComplete(() {
      setInitialFieldsState();
      animateInitialState();
    });

    if (accountCreated != null && accountCreated) {
      pushMainTabScreen(context);
    }
  }

  void setInitialFieldsState() {
    _emailFieldController.clear();
    _passwordFieldController.clear();
    _hasLoaded = false;
    _elementsOpacity = 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
        ),
        // decoration: BoxDecoration(
        //   image: DecorationImage(
        //     image: AssetImage("assets/images/fundo-pedra.jpg"),
        //     fit: BoxFit.cover,
        //   ),
        // ),
        //color: Theme.of(context).primaryColor,
        child: Stack(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 18, right: 12, top: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Container(
                    height: 40,
                  ),
                  // AnimatedOpacity(
                  //   duration: Duration(milliseconds: 500),
                  //   opacity: _exploreButtonFieldOpacityValue,
                  //   child: Align(
                  //     alignment: Alignment.centerRight,
                  //     child: FlatButton(
                  //       splashColor: Colors.transparent,
                  //       highlightColor: Colors.transparent,
                  //       child: Text(
                  //         "Explorar o app",
                  //         style: TextStyle(color: Colors.white),
                  //       ),
                  //       onPressed: () {
                  //         if (_exploreButtonEnabled) {
                  //           setState(() {
                  //             customLogin(context);
                  //           });
                  //         }
                  //       },
                  //     ),
                  //   ),
                  // ),
                  Padding(
                    padding: const EdgeInsets.only(top: 0),
                    child: AnimatedOpacity(
                        duration: Duration(milliseconds: 500),
                        opacity: _elementsOpacity,
                        child: Align(
                          alignment: Alignment.center,
                          child: Container(
                            height: MediaQuery.of(context).size.height * 0.15,
                            child: Image.asset(
                                "assets/images/academia-do-rock-logo-branca.png"),
                          ),
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.10,
                      child: AnimatedOpacity(
                          duration: Duration(milliseconds: 500),
                          opacity: _elementsOpacity,
                          child: loginText()),
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(minHeight: 350),
                    child: Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.40,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          emailField(),
                          passwordField(),
                          submitButton(),
                          // orLabelSeparator(),
                          // socialLogin()
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedOpacity(
              duration: Duration(milliseconds: 500),
              opacity: _bottomMenuItensOpacityValue,
              child: Padding(
                padding: const EdgeInsets.only(left: 4, right: 0, bottom: 30),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    height: 30,
                    child: Row(
                      children: <Widget>[
                        Expanded(
                            //flex: 2,
                            child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Esqueci minha senha!",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              pushForgotPasswordScreen(context);
                            });
                          },
                        )),
                        Expanded(
                            //flex: 2,
                            child: FlatButton(
                          splashColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              "Criar conta.",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              pushCreateAccountScreen(context);
                            });
                          },
                        )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            _isWaiting
                ? Center(
                    //child: CupertinoActivityIndicator(),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  Widget loginText() {
    return AnimatedPadding(
      duration: Duration(milliseconds: _inputFieldsPaddingAnimationDuration),
      padding: EdgeInsets.only(left: _animationPaddingPosition),
      curve: Curves.easeOutCubic,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Bem-vindo(a),",
              style: TextStyle(
                fontSize: 30.0,
                color: Colors.white,
              )),
          AnimatedPadding(
            duration:
                Duration(milliseconds: _inputFieldsPaddingAnimationDuration),
            padding: EdgeInsets.only(left: _animationPaddingPosition),
            curve: Curves.easeOutCubic,
            child: Text(
              "Let´s rock!",
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget emailField() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: _inputFieldsOpacityAnimationDuration),
      curve: Curves.easeOutCubic,
      opacity: _emailFieldOpacityValue,
      child: AnimatedPadding(
        duration: Duration(milliseconds: _inputFieldsPaddingAnimationDuration),
        padding: EdgeInsets.only(top: _emailFieldPaddingPosition),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          elevation: _elementsElevation,
          shadowColor: Colors.black,
          child: Container(
            height: _elementsHeight,
            child: TextField(
              controller: _emailFieldController,
              autocorrect: false,
              autofocus: false,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onSubmitted: (v) {
                FocusScope.of(context).requestFocus(_focus);
              },
              decoration: InputDecoration(
                hintText: "email",
                filled: true,
                fillColor: Colors.white,
                hintStyle: TextStyle(color: Colors.grey[500]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              cursorColor: Colors.black,
              showCursor: true,
            ),
          ),
        ),
      ),
    );
  }

  Widget passwordField() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: _inputFieldsOpacityAnimationDuration),
      curve: Curves.easeOutCubic,
      opacity: _passwordFieldOpacityValue,
      child: AnimatedPadding(
        duration: Duration(milliseconds: _inputFieldsPaddingAnimationDuration),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(top: _passwordFieldPaddingPosition),
        child: Material(
          color: Colors.transparent,
          elevation: _elementsElevation,
          shadowColor: Colors.black,
          child: Container(
            height: _elementsHeight,
            child: TextField(
              controller: _passwordFieldController,
              decoration: InputDecoration(
                hintText: "senha",
                filled: true,
                fillColor: Colors.white,
                hintStyle: TextStyle(color: Colors.grey[500]),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              obscureText: true,
              focusNode: _focus,
            ),
          ),
        ),
      ),
    );
  }

  Widget submitButton() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: _inputFieldsOpacityAnimationDuration),
      curve: Curves.easeOutCubic,
      opacity: _submitButtonOpacityValue,
      child: AnimatedPadding(
        duration: Duration(milliseconds: _inputFieldsPaddingAnimationDuration),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.only(top: _submitButtonPaddingPosition),
        child: Container(
          height: _elementsHeight,
          width: double.infinity,
          child: RaisedButton(
            elevation: 0,
            //color: Theme.of(context).unselectedWidgetColor.withOpacity(0.8),
            color: Theme.of(context).primaryColor,
            highlightColor: Theme.of(context).unselectedWidgetColor,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(10.0)),
            child: Text(
              "Entrar",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            onPressed: () {
              if (_submitButtonEnabled) {
                setState(() {
                  _isWaiting = true;
                  _submitButtonEnabled = false;
                  loginUsingEmailAndPassword(context);
                });
              }
            },
          ),
        ),
      ),
    );
  }

  Widget orLabelSeparator() {
    return AnimatedOpacity(
      duration: Duration(milliseconds: _inputFieldsOpacityAnimationDuration),
      curve: Curves.easeOutCubic,
      opacity: _separatorLabelOpacityValue,
      child: AnimatedPadding(
          duration:
              Duration(milliseconds: _inputFieldsPaddingAnimationDuration),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.only(top: _separatorLabelPaddingPosition),
          child: Container(
            width: double.infinity,
            height: _elementsHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Expanded(
                    child: Container(
                  color: Colors.white,
                  height: 2,
                )),
                Container(
                  height: double.infinity,
                  width: 40,
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      "ou",
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                Expanded(
                    child: Container(
                  color: Colors.white,
                  height: 2,
                )),
              ],
            ),
          )),
    );
  }

  // Widget socialLogin() {
  //   return AnimatedOpacity(
  //     duration: Duration(milliseconds: _inputFieldsOpacityAnimationDuration),
  //     curve: Curves.easeOutCubic,
  //     opacity: _socialLoginOpacityValue,
  //     child: AnimatedPadding(
  //         duration:
  //             Duration(milliseconds: _inputFieldsPaddingAnimationDuration),
  //         curve: Curves.easeOutCubic,
  //         padding: EdgeInsets.only(top: _socialLoginPaddingPosition),
  //         child: Container(
  //           width: double.infinity,
  //           height: _elementsHeight,
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.center,
  //             children: <Widget>[
  //               Expanded(
  //                 flex: 5,
  //                 child: FlatButton.icon(
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10)),
  //                   color: Color(0xff3B5998),
  //                   icon: Image.asset(
  //                     "assets/icons/facebook_f_logo.png",
  //                     width: 22,
  //                     height: _elementsHeight,
  //                   ),
  //                   label: Text(
  //                     "Facebook",
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                   onPressed: () {
  //                     setState(() {
  //                       loginUsingFacebook(context);
  //                       //startLoginAnimation(true);
  //                     });
  //                   },
  //                 ),
  //               ),
  //               Spacer(),
  //               Expanded(
  //                 flex: 5,
  //                 child: FlatButton.icon(
  //                   shape: RoundedRectangleBorder(
  //                       borderRadius: BorderRadius.circular(10)),
  //                   color: Color(0xffDE5246),
  //                   icon: Image.asset(
  //                     "assets/icons/google_g_logo.png",
  //                     width: 35,
  //                     height: _elementsHeight,
  //                   ),
  //                   label: Text(
  //                     "Google",
  //                     style: TextStyle(color: Colors.white),
  //                   ),
  //                   onPressed: () {
  //                     setState(() {
  //                       loginUsingGooglePlus(context);
  //                     });
  //                   },
  //                 ),
  //               ),
  //             ],
  //           ),
  //         )),
  //   );
  // }
}
