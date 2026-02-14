import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:unicotantic/features/feed/anasayfa.dart';
import 'package:unicotantic/features/auth/google_giris.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  final puanSa = Hive.box('unicotantic');

  @override
  initState() {
    if (puanSa.get('uygulama') == null) {
      puanSa.put('uygulama', 26);
      puanSa.put('yeniAyarlar', 'yeniAyarlar001');
      puanSa.put('uygulamaSurumu', 26);
      puanSa.put('guncellemeYayinlandi', 27);
    }

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return const Anasayfa();
              } else {
                return const GoogleGiris();
              }
            },
          ),
        ),
        (Route<dynamic> route) => false,
      );
    });
    //uygulamaAyarlari();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      body: Center(
        child: Container(
          constraints: const BoxConstraints.expand(),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/gif/lemat.gif"),
              fit: BoxFit.cover,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 200),
                SizedBox(
                  height: 200,
                  width: 200,
                  child: Image.asset("assets/images/icon/icon256.png"),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 5,
                        right: 10,
                        left: 10,
                        bottom: 5,
                      ),
                      child: SizedBox(
                        height: 500,
                        child: DefaultTextStyle(
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            backgroundColor: Colors.black54,
                            color: Colors.limeAccent,
                            fontSize: 30.0,
                            fontFamily: 'Chivo',
                            fontWeight: FontWeight.bold,
                          ),
                          child: AnimatedTextKit(
                            pause: const Duration(seconds: 3),
                            stopPauseOnTap: true,
                            isRepeatingAnimation: false,
                            animatedTexts: [
                              TypewriterAnimatedText(
                                curve: Curves.decelerate,
                                ".......",
                                textAlign: TextAlign.center,
                                speed: const Duration(milliseconds: 200),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
