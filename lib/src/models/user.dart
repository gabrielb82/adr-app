import 'package:academia_do_rock_app/src/models/app_keys.dart';
import 'package:academia_do_rock_app/src/models/classess.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class User extends ChangeNotifier {
  String uid;
  String displayName;
  String email;
  String unitName;
  bool isActive;
  bool isTeacher;
  String type;
  List<Classess> classess;
  List<AppKeys> appKeys;

  User(
      {this.uid,
      this.displayName,
      this.email,
      this.unitName,
      this.isActive,
      this.isTeacher,
      this.type,
      this.appKeys,
      this.classess});

  factory User.fromFirestore(DocumentSnapshot documentSnapshot) {
    Map data = documentSnapshot.data;

    List<AppKeys> listAppKeys = [];
    if (data['app_key'] != null) {
      Map<dynamic, dynamic> appKeys = data['app_key'];

      appKeys.forEach((key, value) {
        listAppKeys.add(AppKeys.fromValues(key, value));
      });
    }

    return User(
      uid: documentSnapshot.documentID,
      displayName: data['display_name'] ?? 'Anônimo',
      email: data['email'] ?? 'anonimo@academiadorock.com.br',
      unitName: data['unit_name'] ?? '',
      isActive: data['is_active'] ?? false,
      isTeacher: data['is_teacher'] ?? false,
      type: data['type'] ?? 's',
      appKeys: listAppKeys,
      // classess: data<List>['classess'].forEach(f) Classess.fromArray(data['classess']) ?? Classess(),
    );
  }
}
