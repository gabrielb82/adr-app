import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Notifications extends ChangeNotifier {
  String uid;
  String title;
  String message;
  String type;
  String reference;

  Notifications(
      {this.uid, this.title, this.message, this.type, this.reference});

  factory Notifications.fromFirestore(DocumentSnapshot documentSnapshot) {
    Map data = documentSnapshot.data;

    return Notifications(
      uid: documentSnapshot.documentID,
      title: data['title'] ?? '-',
      message: data['message'] ?? '',
      type: data['type'] ?? '',
      reference: data['reference'] ?? '',
    );
  }
}
