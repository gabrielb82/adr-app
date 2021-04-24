import 'dart:io';

import 'package:academia_do_rock_app/src/login/login_screen.dart';
import 'package:academia_do_rock_app/src/main_tab/profile_screen/animation_profile.dart';
import 'package:academia_do_rock_app/src/main_tab/profile_screen/help_screen/help_screen.dart';
import 'package:academia_do_rock_app/src/main_tab/profile_screen/image_picker_handler.dart';
import 'package:academia_do_rock_app/src/models/user.dart';
import 'package:badges/badges.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin, ImagePickerListener {
  ScrollController _scrollController;
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser _user;

  Widget _panel = Container();

  int _selectedCard = 0;
  bool _isloading = false;

  ImagePickerHandler imagePicker;
  AnimationController animController;
  ProfileAnimations anim;
  File _image;

  final storage = new FlutterSecureStorage();
  bool _isFacebookUser = false;
  bool _isGooglePlusUser = false;

  User _userData;

  void getUser() async {
    _user = await _auth.currentUser();
    var facebookToken = await storage.read(key: "facebookAccessToken");
    var googleToken = await storage.read(key: "googleAccessToken");

    facebookToken != null ? _isFacebookUser = true : _isFacebookUser = false;
    googleToken != null ? _isGooglePlusUser = true : _isGooglePlusUser = false;
  }

  @override
  void initState() {
    getUser();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    _panel = Container();

    animController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));
    anim = ProfileAnimations(control: animController);

    imagePicker = new ImagePickerHandler(this, animController);
    imagePicker.init();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return _isloading
        ? Center(
            child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ))
        : Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.grey[800], Colors.grey[850]]),
              // colors: [
              //   Theme.of(context).backgroundColor,
              //   Color(0xFF191919)
              // ]),
            ),
            width: double.infinity,
            height: double.infinity,
            child: FutureBuilder(
              future: _auth.currentUser(),
              builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    _user = snapshot.data;
                    return futureUser();
                  }
                }
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Colors.grey[800], Colors.grey[850]]),
                    // colors: [
                    //   Theme.of(context).backgroundColor,
                    //   Color(0xFF191919)
                    // ]),
                  ),
                  width: double.infinity,
                  height: double.infinity,
                  child: Center(
                      child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor),
                  )),
                );
              },
            ),
          );

    // return Scaffold(
    //   appBar: AppBar(
    //     title: Text(
    //       'Perfil',
    //       style: TextStyle(color: Colors.black),
    //     ),
    //   ),
    //   body: FutureBuilder(
    //     future: _auth.currentUser(),
    //     builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
    //       if (snapshot.hasData) {
    //         if (snapshot.connectionState == ConnectionState.done) {
    //           _user = snapshot.data;
    //           return futureUser();
    //         }
    //       }
    //       return Container(
    //         color: Colors.white,
    //         width: double.infinity,
    //         height: double.infinity,
    //         child: Center(
    //             child: CircularProgressIndicator(
    //           valueColor:
    //               AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
    //         )),
    //       );
    //     },
    //   ),
    // );
  }

  Widget futureUser() {
    return FutureBuilder(
      future: Firestore.instance.collection("users").document(_user.uid).get(),
      builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasData) {
          if (snapshot.connectionState == ConnectionState.done) {
            _userData = User.fromFirestore(snapshot.data);
            //_panel = MyData(userData: _userData);
            return profileScreen();
          }
        }
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[800], Colors.grey[800]]),
            //colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
          ),
          width: double.infinity,
          height: double.infinity,
          child: Center(
              child: CircularProgressIndicator(
            valueColor:
                AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          )),
        );
      },
    );
  }

  Widget profileScreen() {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.grey[800], Colors.grey[800]]),
            //colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
          ),
          width: double.infinity,
          height: (MediaQuery.of(context).size.height * 0.35),
          child: Stack(
            children: <Widget>[
              Stack(
                children: <Widget>[
                  CachedNetworkImage(
                    imageUrl:
                        "https://firebasestorage.googleapis.com/v0/b/academia-do-rock.appspot.com/o/profile%2Fdefault%2Facademia-do-rock.jpg?alt=media&token=ef18b48b-0062-44ed-a505-0cb79999acd4",
                    imageBuilder: (context, imageProvider) {
                      return Container(
                        height: (MediaQuery.of(context).size.height * 0.35) -
                            ((MediaQuery.of(context).size.width * 0.40) / 2) -
                            10,
                        alignment: Alignment.topCenter,
                        decoration: BoxDecoration(
                          //borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                              image: imageProvider, fit: BoxFit.cover),
                        ),
                      );
                    },
                  ),
                  // Container(
                  //   padding: const EdgeInsets.only(right: 10.0, top: 30.0),
                  //   alignment: Alignment.topRight,
                  //   child: GestureDetector(
                  //     onTap: () {},
                  //     child: Container(
                  //       height: 40.0,
                  //       width: 40.0,
                  //       child: Icon(
                  //         Icons.more_horiz,
                  //         color: Colors.white,
                  //         size: 40,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10.0),
                alignment: Alignment.bottomCenter,
                child: FutureBuilder(
                  future: _auth.currentUser(),
                  builder: (context, AsyncSnapshot<FirebaseUser> snapshot) {
                    if (snapshot.hasData) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return avatar(snapshot.data.uid);
                      }
                    }
                    return avatarImage('no url', "FP");
                  },
                ),
              ),
            ],
          ),
        ),
        userName(),
        menuList(),
      ],
    );
  }

  Widget userName() {
    return Container(
      color: Colors.grey[800],
      // decoration: BoxDecoration(
      //   gradient: LinearGradient(
      //       begin: Alignment.topLeft,
      //       end: Alignment.bottomRight,
      //       colors: [Colors.grey[850], Colors.grey[900]]),
      //   //colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
      // ),
      padding: const EdgeInsets.only(bottom: 15.0),
      width: double.infinity,
      child: Text(
        _userData.displayName,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget avatar(String uid) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.40,
        height: MediaQuery.of(context).size.width * 0.40,
        child: Stack(
          children: <Widget>[
            FutureBuilder<dynamic>(
              future: FirebaseStorage.instance
                  .ref()
                  .child("profile/${_user.uid}/avatar.jpg")
                  .getDownloadURL(),
              builder: (context, AsyncSnapshot<dynamic> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    return avatarImage(
                        snapshot.data.toString() != null
                            ? snapshot.data.toString()
                            : 'https://firebasestorage.googleapis.com/v0/b/academia-do-rock.appspot.com/o/profile%2Fdefault%2Fno-photo.jpg?alt=media&token=2afb3f5a-fff8-405d-bddb-0679d9c2c1bc',
                        "");
                  }
                }
                return avatarImage(
                    'https://firebasestorage.googleapis.com/v0/b/academia-do-rock.appspot.com/o/profile%2Fdefault%2Fno-photo.jpg?alt=media&token=2afb3f5a-fff8-405d-bddb-0679d9c2c1bc',
                    "FP");
              },
            ),
            // Container(
            //   padding: const EdgeInsets.all(4.0),
            //   alignment: Alignment.bottomRight,
            //   child: GestureDetector(
            //     onTap: () {},
            //     child: Container(
            //       //color: Theme.of(context).primaryColor,
            //       height: 40.0,
            //       width: 40.0,
            //       decoration: new BoxDecoration(
            //         color: Theme.of(context).primaryColor,
            //         borderRadius:
            //             new BorderRadius.all(new Radius.circular(50.0)),
            //         border: new Border.all(
            //           color: Colors.white,
            //           width: 4.0,
            //         ),
            //       ),
            //       child: Icon(
            //         Icons.linked_camera,
            //         color: Colors.white,
            //         size: 20,
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget avatarImage(String url, String displayNameInitials) {
    return CircularProfileAvatar(
      url,
      radius: (MediaQuery.of(context).size.width * 0.40) / 2,
      backgroundColor: Colors.transparent,
      borderWidth: 10,
      initialsText: Text(
        displayNameInitials,
        style: TextStyle(fontSize: 40, color: Theme.of(context).primaryColor),
      ),
      borderColor: Theme.of(context).backgroundColor,
      elevation: 0,
      cacheImage: true,
    );
  }

  // final FirebaseAuth _auth = FirebaseAuth.instance;

  // @override
  // void initState() {
  //   super.initState();
  // }

  void signOut() {
    showPlatformDialog(
      context: context,
      builder: (_) => PlatformAlertDialog(
        title: Text('Atenção!'),
        content: Text('Tem certeza que deseja sair?'),
        actions: <Widget>[
          PlatformDialogAction(
            child: Text(
              "Sair",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onPressed: () {
              _auth.signOut();
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) => LoginScreen()));
            },
          ),
          PlatformDialogAction(
            child: Text("Cancelar"),
            onPressed: () {
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }

  Widget menuList() {
    return Expanded(
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: ListView(
          children: <Widget>[
            //!_isFacebookUser ? changeProfilePicture() : Container(),
            changeProfilePicture(),
            !_isFacebookUser && !_isGooglePlusUser
                ? changePassword()
                : Container(),
            helpCenterButton(),
            visitSite(),
            privacyPolicyButton(),
            signOutButton(),
          ],
        ),
      ),
    );
    // return Column(
    //   mainAxisAlignment: MainAxisAlignment.start,
    //   children: <Widget>[
    //     Expanded(
    //       child: MediaQuery.removePadding(
    //         context: context,
    //         removeTop: true,
    //         child: ListView(
    //           children: <Widget>[
    //             // myCuponsButton(),
    //             // helpCenterButton(),
    //             // userTermsButton(),
    //             // privacyPolicyButton(),
    //             // signOutButton(),
    //           ],
    //         ),
    //       ),
    //     ),
    //   ],
    // );
  }

  // @override
  // Widget build(BuildContext context) {
  //   return SafeArea(
  //     child: Stack(
  //       children: <Widget>[
  //         Align(
  //           alignment: Alignment.bottomRight,
  //           child: Padding(
  //             padding: const EdgeInsets.all(20.0),
  //             child: Text(
  //               'ver. 1.0.1',
  //               style: TextStyle(
  //                   fontSize: 14,
  //                   color: Theme.of(context).unselectedWidgetColor),
  //             ),
  //           ),
  //         ),
  //         Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: <Widget>[
  //             profileTop(),
  //             Expanded(
  //               child: MediaQuery.removePadding(
  //                 context: context,
  //                 removeTop: true,
  //                 child: ListView(
  //                   children: <Widget>[
  //                     myCuponsButton(),
  //                     helpCenterButton(),
  //                     userTermsButton(),
  //                     privacyPolicyButton(),
  //                     signOutButton(),
  //                   ],
  //                 ),
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Widget signOutButton() {
    return optionButton(
      Icon(
        MdiIcons.logout,
        color: Theme.of(context).primaryColor,
      ),
      'Sair',
      false,
      textColor: Theme.of(context).primaryColor,
      onPressed: () {
        signOut();
      },
    );
  }

  Widget visitSite() {
    return optionButton(
      Icon(
        MdiIcons.web,
        color: Colors.white60,
      ),
      'Visite o nosso site',
      false,
      onPressed: () {
        _launchURL('https://www.academiadorock.com.br');
      },
    );
  }

  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget privacyPolicyButton() {
    return optionButton(
        Icon(
          MdiIcons.serverSecurity,
          color: Colors.white60,
        ),
        'Termos e Política de privacidade',
        false,
        onPressed: () {});
  }

  Widget helpCenterButton() {
    return optionButton(
        Icon(
          MdiIcons.helpCircleOutline,
          color: Colors.white60,
        ),
        'Central de Ajuda',
        false, onPressed: () {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(builder: (context) => HelpScreen()),
      // );
    });
  }

  Widget myCuponsButton() {
    return optionButton(
        Icon(
          MdiIcons.ticketPercent,
          color: Colors.white60,
        ),
        'Cupons e promoções',
        false,
        onPressed: () {});
  }

  Widget changeProfilePicture() {
    return optionButton(
        Icon(
          MdiIcons.camera,
          color: Colors.white60,
        ),
        'Alterar foto de perfil',
        false, onPressed: () {
      imagePicker.showDialog(context);
    });
  }

  Widget changePassword() {
    return optionButton(
        Icon(
          MdiIcons.keyVariant,
          color: Colors.white60,
        ),
        'Alterar Senha',
        false, onPressed: () {
      changePasswordConfirmation();
    });
  }

  void changePasswordConfirmation() {
    Alert(
      context: context,
      type: AlertType.info,
      title: "Você deseja realmente alterar a sua senha?",
      desc: "Um e-mail será enviado com as instruções.",
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
          onPressed: () => sendChangePasswordEmail(),
          width: 120,
        ),
      ],
    ).show();
  }

  void sendChangePasswordEmail() {
    Navigator.pop(context);
    setState(() {
      _isloading = true;
    });

    _auth.sendPasswordResetEmail(email: _user.email).then((v) {
      setState(() {
        _isloading = false;
      });
      Alert(
        context: context,
        type: AlertType.success,
        title: "Alterar Senha",
        desc:
            "Um e-mail foi enviado com as instruções para prossegir com a sua solicitação.",
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
    }).catchError((error) {
      Alert(
        context: context,
        type: AlertType.error,
        title: "ERRO",
        desc:
            "Ocorreu um erro ao processar sua solicitação. Por favor, tente novamente.",
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
    });
  }

  Widget myPlimPoints() {
    return optionButton(Icon(MdiIcons.starBoxOutline), 'Meus plins', true,
        badgeLabel: '150', onPressed: () {});
  }

  Widget optionButton(Icon icon, String label, bool shouldDisplayBadge,
      {Color textColor = Colors.white60,
      String badgeLabel = '-',
      Function onPressed}) {
    return Container(
      decoration: BoxDecoration(
        gradient:
            LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
                //colors: [Colors.grey[800], Colors.grey[850]]),
                colors: [Theme.of(context).backgroundColor, Color(0xFF191919)]),
      ),
      width: double.infinity,
      height: 45,
      child: Align(
        alignment: Alignment.centerLeft,
        child: RaisedButton(
          color: Colors.transparent,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              icon,
              Padding(
                padding: const EdgeInsets.only(left: 15),
                child: Text(
                  label,
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
              shouldDisplayBadge
                  ? Expanded(
                      child: Container(
                        alignment: Alignment.centerRight,
                        child: Badge(
                          badgeColor: Theme.of(context).primaryColor,
                          shape: BadgeShape.square,
                          borderRadius: 10,
                          toAnimate: false,
                          badgeContent: Text(badgeLabel,
                              style:
                                  TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                      ),
                    )
                  : Container(),
            ],
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }

  @override
  userImage(File _image) {
    print(_image);
    setState(() {
      this._image = _image;
      _isloading = true;
      changeAvatar();
    });
  }

  Future changeAvatar() async {
    var image = this._image;
    //File f = await FilePicker.getFile(type: FileType.IMAGE);
    List<String> aux = image.path.split(".");
    String ext = aux[aux.length - 1];

    if (ext == "jpg" || ext == "jpeg" || ext == "png" || ext == "bmp") {
      setState(() {
        //_waitingUploadImage = true;
      });
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .child("profile/${_user.uid}/avatar.jpg");
      StorageUploadTask uploadTask = storageReference.putFile(image);
      await uploadTask.onComplete;
      print('File Uploaded');
      storageReference.getDownloadURL().then((fileURL) {
        setState(() {
          //_uploadedFileURL = fileURL;
          _isloading = false;
        });
      });
      //String base64Image = base64Encode(image.readAsBytesSync());
      // providers.changeAvatar(base64Image, ext).then((s) {
      //   setState(() {
      //     _waitingUploadImage = false;
      //   });
      //   if (s == 200) {
      //     getProfile();
      //   } else
      //     MainScreen.alert(
      //         text: strings.errors.get("error_unknow"),
      //         textColor: Colors.white,
      //         backgroundColor: Colors.red);
      // }).catchError((error) {
      //   MainScreen.alert(
      //       text: strings.errors.get("error_upload_image"),
      //       textColor: Colors.white,
      //       backgroundColor: Colors.red);
      //   setState(() {
      //     _waitingUploadImage = false;
      //   });
      // });
    } else {
      Alert(
        context: context,
        type: AlertType.error,
        title: "ERRO",
        desc: "Este tipo de mídia não é permitido para foto de perfil.",
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
  }

  // Widget profileTop() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       boxShadow: [
  //         BoxShadow(
  //           blurRadius: 0.0,
  //           color: Colors.black.withOpacity(.1),
  //           offset: Offset(0, 0),
  //         ),
  //       ],
  //       //shape: BoxShape.rectangle,
  //       //border: Border.all(),
  //       color: Colors.white,
  //     ),
  //     width: double.infinity,
  //     height: 120,
  //     child: Row(
  //       children: <Widget>[
  //         avatar(),
  //         userData(),
  //       ],
  //     ),
  //   );
  // }

  // Widget userData() {
  //   return Expanded(
  //     child: FutureBuilder(
  //       future: _auth.currentUser(),
  //       builder: (context, snapshot) {
  //         if (snapshot.hasData) {
  //           if (snapshot.connectionState == ConnectionState.done) {
  //             FirebaseUser user = snapshot.data;
  //             if (user.displayName == null) {
  //               return Container();
  //             }
  //             return Column(
  //               mainAxisAlignment: MainAxisAlignment.center,
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: <Widget>[
  //                 Text(
  //                   user.displayName,
  //                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //                 ),
  //                 Container(
  //                   height: 10,
  //                 ),
  //                 Text(
  //                   user.email,
  //                   style: TextStyle(
  //                       fontSize: 12,
  //                       color: Theme.of(context).unselectedWidgetColor),
  //                 )
  //               ],
  //             );
  //           } else {
  //             return Container();
  //           }
  //         }
  //         return Container();
  //       },
  //     ),
  //   );
  // }

  // Widget avatar() {
  //   return Padding(
  //     padding: const EdgeInsets.only(left: 25, right: 25),
  //     child: Center(
  //       child: Container(
  //         width: 80,
  //         height: 80,
  //         child: FutureBuilder(
  //           future: _auth.currentUser(),
  //           builder: (context, snapshot) {
  //             if (snapshot.hasData) {
  //               if (snapshot.connectionState == ConnectionState.done) {
  //                 FirebaseUser user = snapshot.data;
  //                 if (user.photoUrl != null) {
  //                   return avatarImage(user.photoUrl, user.displayName[0]);
  //                 }
  //                 return avatarImage('no url', user.displayName[0]);
  //               }
  //             }
  //             return avatarImage('no url', "FP");
  //           },
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget avatarImage(String url, String displayNameInitials) {
  //   return CircularProfileAvatar(
  //     url,
  //     radius: 50,
  //     backgroundColor: Colors.transparent,
  //     borderWidth: 3,
  //     initialsText: Text(
  //       displayNameInitials,
  //       style: TextStyle(fontSize: 40, color: Colors.white),
  //     ),
  //     borderColor: Theme.of(context).primaryColor,
  //     elevation: 5,
  //     cacheImage: true,
  //   );
  // }

  // Widget myWallet() {
  //   return Padding(
  //     padding: const EdgeInsets.only(top: 50),
  //     child: Container(
  //       width: double.infinity,
  //       height: 230,
  //       child: Padding(
  //         padding: const EdgeInsets.all(15),
  //         child: Container(
  //           width: double.infinity,
  //           height: double.infinity,
  //           decoration: BoxDecoration(
  //             borderRadius: BorderRadius.circular(18),
  //             color: Theme.of(context).primaryColor,
  //           ),
  //           child: Stack(
  //             fit: StackFit.expand,
  //             children: <Widget>[
  //               ClipRRect(
  //                 borderRadius: BorderRadius.circular(18),
  //                 child: Image.asset(
  //                   'assets/images/fada_card.jpg',
  //                   fit: BoxFit.fitWidth,
  //                 ),
  //               ),
  //               Padding(
  //                 padding: const EdgeInsets.all(15),
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment.center,
  //                   crossAxisAlignment: CrossAxisAlignment.stretch,
  //                   children: <Widget>[
  //                     Expanded(
  //                       child: Align(
  //                         alignment: Alignment.centerLeft,
  //                         child: Text(
  //                           'Saldo em\nsua carteira',
  //                           style: TextStyle(
  //                             color: Colors.white,
  //                             fontSize: 14,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                     Expanded(
  //                       child: Align(
  //                         alignment: Alignment.centerRight,
  //                         child: Column(
  //                           mainAxisAlignment: MainAxisAlignment.center,
  //                           crossAxisAlignment: CrossAxisAlignment.end,
  //                           children: <Widget>[
  //                             Text(
  //                               'R\$ 3.421,17',
  //                               style: TextStyle(
  //                                 color: Colors.white,
  //                                 fontSize: 28.0,
  //                               ),
  //                             ),
  //                             ButtonTheme(
  //                               height: 30,
  //                               child: RaisedButton(
  //                                 shape: RoundedRectangleBorder(
  //                                   borderRadius: BorderRadius.circular(18),
  //                                 ),
  //                                 textColor: Colors.black,
  //                                 color: Colors.white,
  //                                 child: Text(
  //                                   'ADICIONAR',
  //                                   style: TextStyle(fontSize: 10),
  //                                 ),
  //                                 onPressed: () {},
  //                               ),
  //                             ),
  //                           ],
  //                         ),
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //               )
  //             ],
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
