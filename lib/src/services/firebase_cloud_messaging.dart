import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;

class FirebaseCloudMessage {
  static final app = "academia-do-rock";

  static final serverKey =
      "AAAATDMzQuM:APA91bHdhafpjmxdbK22W3HEcQjyo9tbQtm4Od4b45iYHwrC_GjnGkN5r3DcUawRhKDgNgRCP8KI5jsmZAEyHwZWDcwvO8yuu2JgANS2X5hDb9sZoR3HRmOiJxC_dUVY-WitmxlcmKhH";
  static final FirebaseMessaging _fcm = FirebaseMessaging();
  static send(String title, String body, List<String> tokens) {
    tokens.forEach((t) {
      http
          .post("https://fcm.googleapis.com/fcm/send",
              headers: {
                "Content-Type": "application/json",
                "Authorization": "key=" + serverKey
              },
              body: jsonEncode({
                "notification": {"body": body, "title": title},
                "priority": "high",
                "data": {
                  "click_action": "FLUTTER_NOTIFICATION_CLICK",
                  "id": "1",
                  "status": "done"
                },
                "to": t
              }))
          .then((e) {
        print("sendend to" + t);
        print(e.body);
      }).catchError((e) {
        print(e);
      });
    });
  }

  static Future<String> getToken() async {
    return await _fcm.getToken();
  }

  static Future<void> saveNotificationToken(String userId) async {
    String token = await _fcm.getToken();
    if (token != null)
      await Firestore.instance
          .collection("users/$userId/notification_tokens")
          .document(token)
          .setData({
        'token': token,
        'createdAt': FieldValue.serverTimestamp(),
        'platform': Platform.operatingSystem,
        "app": app
      }, merge: true);
  }

  static Future<void> removeNotificationToken(String userId) async {
    String token = await _fcm.getToken();
    if (token != null)
      await Firestore.instance
          .collection("users/$userId/notification_tokens")
          .document(token)
          .delete();
  }

  static Future<List<String>> getNotificationTokens(String userId) async {
    QuerySnapshot qs = await Firestore.instance
        .collection("users/$userId/notification_tokens")
        .where("app", isEqualTo: app)
        .getDocuments();
    List<String> list = List<String>();
    qs.documents.forEach((doc) {
      list.add(doc.data["token"]);
    });
    return list;
  }
}
