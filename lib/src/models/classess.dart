import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Classess extends ChangeNotifier {
  String uid;
  String name;
  String code;
  String apiID;

  Classess({this.uid, this.name, this.code, this.apiID});

  factory Classess.fromFirestore(DocumentSnapshot documentSnapshot) {
    Map data = documentSnapshot.data;

    return Classess(
      uid: documentSnapshot.documentID ?? "",
      name: data['name'].toString() ?? '-',
      code: data['code'].toString() ?? '',
      apiID: data['api_id'].toString() ?? '',
    );
  }

  factory Classess.fromArray(Map data) {
    return Classess(
      uid: data['uid'].toString() ?? "",
      name: data['name'].toString() ?? '-',
      code: data['code'].toString() ?? '-',
      apiID: data['api_id'].toString() ?? '',
    );
  }
}
