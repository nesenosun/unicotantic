import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:unicotantic/login/yeniKayitEkrani.dart';
import 'package:unicotantic/Unic/sosyalMedya/YouTube.dart';
import 'package:unicotantic/Unic/sosyalMedya/facebook.dart';
import 'package:unicotantic/Unic/sosyalMedya/googleiwebview.dart';
import 'package:unicotantic/Unic/sosyalMedya/instagram.dart';
import 'package:unicotantic/Unic/sosyalMedya/twitter.dart';

import '../login/auth_kontrol.dart';
import '../login/email_giris.dart';

class bosBenDrawer extends StatefulWidget {
  const bosBenDrawer({Key? key}) : super(key: key);

  @override
  State<bosBenDrawer> createState() => _bosBenDrawerState();
}

class _bosBenDrawerState extends State<bosBenDrawer> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.black87,
      child: SingleChildScrollView(
        child: Column(
          children: [
            //const SizedBox(height: 10),
            DrawerHeader(
                decoration: const BoxDecoration(),
                child: SizedBox(
                  height: 200,
                  width: 200,
                  child: GestureDetector(
                      onTap: () {
                        //Get.off(const ProfilBilgilerim());
                      },
                      child: SizedBox(
                        child: Image.asset('assets/images/icon/icon256.png'),
                        height: 200,
                      )),
                )),
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return const Center();
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          Get.to(const YeniKayitEkrani());
                        },
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Text(
                              'Üye Ol',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Avenir',
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          Get.to(EmailGiris());
                        },
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            child: Text(
                              'Giriş',
                              style: TextStyle(
                                color: Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Avenir',
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Get.to(const Facebook());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 50,
                            child:
                                Image.asset('assets/images/png/facebook.png')),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.to(const Instagram());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 50,
                            child:
                                Image.asset('assets/images/png/instagram.png')),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.to(const Twitter());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 50,
                            child: Image.asset('assets/images/png/x.png')),
                      ),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        Get.to(const YouTube());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 50,
                            child:
                                Image.asset('assets/images/png/youtube.png')),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.to(const GoogleiWeb());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 50,
                            child:
                                Image.asset('assets/images/png/googlei.png')),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        Get.to(const AuthKontrol());

                        setState(() {});
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Image.asset('assets/images/png/akis.png')),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            GestureDetector(
              onTap: () async {
                SystemNavigator.pop();

                setState(() {});
              },
              child: const Card(
                color: Colors.white10,
                elevation: 10,
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Text(
                      'Çıkış',
                      style: TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Avenir',
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            const Align(
              alignment: Alignment.bottomCenter,
              child: Card(
                color: Colors.white24,
                elevation: 10,
                margin: EdgeInsets.all(15),
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Text(
                      ' v1.0\n  @nesenosun',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Avenir',
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
