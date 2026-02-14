import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;

Widget renderGoogleButton() => web.renderButton();

void initializeWeb() {
  GoogleSignIn.instance.authenticationEvents.listen((event) async {
    // Bu mantık google_giris.dart içinde stateful widget içinde yönetiliyor,
    // ancak v7.x için gerekirse buraya taşınabilir.
  });
  GoogleSignIn.instance.initialize();
}
