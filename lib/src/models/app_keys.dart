import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppKeys {
  String franchiseID;
  String userAPPID;

  AppKeys({this.franchiseID, this.userAPPID});

  factory AppKeys.fromValues(String key, value) {
    return AppKeys(
      franchiseID: key ?? '',
      userAPPID: value ?? '',
    );
  }
}
