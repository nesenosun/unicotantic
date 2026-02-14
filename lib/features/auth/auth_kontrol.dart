import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:unicotantic/features/auth/google_giris.dart';

import '../feed/anasayfa.dart';

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
            return const Anasayfa();
          } else {
            return const GoogleGiris();
          }
        },
      ),
    );
  }
}
