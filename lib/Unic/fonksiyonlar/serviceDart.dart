import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:grock/grock.dart';

class FirebaseNotification {
  late final FirebaseMessaging messaging;

  void settingNotification() async {
    await messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );
  }

  void connectNotifi() async {
    // Firebase main.dart içinde başlatıldığı için burada tekrar başlatmaya gerek yok.
    // await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;
    messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
      badge: true,
    );

    settingNotification();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      Grock.snackBar(
          title: '${event.notification?.title}',
          description: '${event.notification?.body}',
          leading: event.notification?.android?.imageUrl == null
              ? null
              : Image.network(
                  '${event.notification?.android?.imageUrl}',
                  width: 80,
                  height: 80,
                ),
          opacity: 0.5,
          position: SnackbarPosition.top);
    });
    String? token = await messaging.getToken();
    if (token != null) {
      log('token: $token', name: 'fcm tken');
      FirebaseFirestore.instance
          .collection("token")
          .doc(token)
          .set({'token': token});
    }
  }
}
