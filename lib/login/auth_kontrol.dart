import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicotantic/login/google_giris.dart';

import '../akis/anasayfa.dart';

class AuthKontrol extends StatefulWidget {
  const AuthKontrol({Key? key}) : super(key: key);

  @override
  State<AuthKontrol> createState() => _AuthKontrolState();
}

class _AuthKontrolState extends State<AuthKontrol> {
  // final _service = FirebaseNotification();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const DoluAkisAnaSayfa();
          } else {
            return const EmailGiris.GoogleGiris();
          }
        },
      ),
    );
  }
}
